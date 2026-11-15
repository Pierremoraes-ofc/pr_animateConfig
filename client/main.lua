local Lang = pr_lib.locale()
local isOpen = false
local controlsThreadRunning = false
local pauseHoldThreadRunning = false
local timelineThreadRunning = false
local gizmoActive = false
local saveRequestId = 0
local pendingSaveCallbacks = {}
local cameraTargetDummy = nil
local currentCameraTarget = "waist"
local editorSession = 0
local animationRequest = 0
local movementTesting = false
local stopMovementTest
local scene = {}
local sceneOverrides = {}
local bonePicker
local propOperation
local currentAnimation = {
    dict = nil,
    anim = nil,
    flags = 0,
    blendIn = 8.0,
    blendOut = 8.0,
    duration = -1,
    playbackRate = 1.0,
    paused = false,
    pausedTime = 0.0,
    lastTime = 0.0,
    startedAt = 0,
    startPhase = 0.0,
    effectiveRate = 1.0,
}

local savedAnimationCatalog = {}
local savedPlayback = {
    token = 0,
    ped = nil,
    dict = nil,
    anim = nil,
    props = {},
}

local editorProps = {}
local propData = {}
local nextPropId = 0

local function plainVector(value)
    return { x = value.x, y = value.y, z = value.z }
end

local function sendEditorProps(changed)
    local props = {}
    for i, prop in ipairs(editorProps) do
        props[i] = {
            id = prop.id, model = prop.model, boneId = prop.boneId, rotationOrder = prop.rotOrder,
            offset = plainVector(prop.offset), rotation = plainVector(prop.rot), visible = prop.visible,
        }
    end
    SendNUIMessage({ action = "editorProps", props = props, selectedId = propData.id, changed = changed == true })
end

local function bridgeDebug(level, message)
    if not pr_lib or not pr_lib.debug then return end

    local fn = pr_lib.debug[level]
    if type(fn) == "function" then
        fn(message)
    elseif type(pr_lib.debug) == "function" then
        pr_lib.debug(level, message)
    end
end

local function encodePayload(payload)
    if type(json) == "table" and type(json.encode) == "function" then
        return json.encode(payload or {})
    end

    return tostring(payload)
end

local function debugAction(action, payload, level)
    local message = ("[%s] %s"):format(action, encodePayload(payload or {}))

    bridgeDebug(level or "info", ("[pr_animateConfig:debug] %s"):format(message))
    SendNUIMessage({
        action = "debugLog",
        message = message,
    })
end

local function notify(title, description, notifyType)
    if not pr_lib or not pr_lib.notify or type(pr_lib.notify.Notify) ~= "function" then return end

    pr_lib.notify.Notify({
        title = title,
        description = description,
        type = notifyType or "inform",
    })
end

-- pr_lib.locale() traduz uma chave por chamada; esta lista monta o pacote
-- completo de labels que a NUI precisa receber em um unico SendNUIMessage.
local translationKeys = {
    "erro",
    "alerta",
    "sucesso",
    "error",
    "warning",
    "success",
    "info",
    "appTitle",
    "closeIcon",
    "animation",
    "animationId",
    "animationIdHint",
    "animationIdRequired",
    "propAttach",
    "close",
    "preset",
    "custom",
    "dict",
    "anim",
    "flag",
    "blendIn",
    "blendOut",
    "duration",
    "playback",
    "quickFlags",
    "play",
    "pause",
    "stop",
    "clear",
    "timeline",
    "timelineHint",
    "generatedConfig",
    "generate",
    "copy",
    "copySuccess",
    "copyFailed",
    "saveJson",
    "saveSuccess",
    "saveFailed",
    "debug",
    "prop",
    "customModel",
    "spawn",
    "delete",
    "bone",
    "boneId",
    "rotationOrder",
    "position",
    "rotation",
    "editWithGizmo",
    "captureCurrentPosition",
    "resetOffsets",
    "backspaceHint",
    "menu",
    "gizmo",
    "noProp",
    "propAttached",
    "propFree",
    "disabled",
    "gizmoMissing",
    "loop",
    "upper",
    "move",
    "stay",
    "freeze",
    "animDrinkBottle",
    "animCoffeeIdle",
    "animPhoneText",
    "animClipboard",
    "animSmoke",
    "animSit",
    "propCoffeeCup",
    "propBottle",
    "propBeer",
    "propClipboard",
    "propPhone",
    "propCigarette",
    "propBurger",
    "boneRightHand",
    "boneLeftHand",
    "boneRightWrist",
    "boneLeftWrist",
    "boneHead",
    "boneMouth",
    "boneSpine",
    "boneRightFoot",
    "boneLeftFoot",
    "camHead",
    "camWaist",
    "camFoot",
    "opened",
    "closed",
    "keybindOpenMenu",
    "keybindOpened",
    "animationLabel",
    "history",
    "restoreLast",
    "refreshCatalog",
    "savedAnimations",
    "restoreSaved",
    "chooseSaved",
    "recent",
    "catalog",
    "frameBack",
    "frameForward",
    "testAnimation",
    "testHint",
    "testUnavailable",
    "scene",
    "background",
    "backgroundColor",
    "worldScene",
    "greenScene",
    "blueScene",
    "neutralScene",
    "sceneHour",
    "sceneWeather",
    "sunny",
    "clearSky",
    "clouds",
    "overcast",
    "rain",
    "fog",
    "exportFormat",
    "exportValues",
    "exportScope",
    "allProps",
    "selectedProp",
    "attachedProps",
    "addProp",
    "replaceProp",
    "hideProp",
    "showProp",
    "hiddenProp",
    "boneRegion",
    "bodyBones",
    "leftHandBones",
    "rightHandBones",
    "allBones",
    "leftHandShort",
    "rightHandShort",
    "searchBone",
    "pickBone",
    "preserveRotation",
    "scullyRequired",
    "scullyPropFile",
    "scullyGeneralFile",
    "scullyMapping",
    "editorError",
    "busy",
    "animation_unavailable",
    "invalidModel",
    "invalidBone",
    "modelLoadFailed",
    "propLimit",
    "rotationFailed",
    "cameraUnavailable",
    "boneThumb",
    "boneIndex",
    "boneMiddle",
    "boneRing",
    "boneLittle",
    "bonePelvis",
    "boneNeck",
    "boneLeftClavicle",
    "boneRightClavicle",
    "boneLeftUpperArm",
    "boneRightUpperArm",
    "boneLeftForearm",
    "boneRightForearm",
    "boneLeftThigh",
    "boneRightThigh",
    "boneLeftCalf",
    "boneRightCalf",
    "boneLeftToe",
    "boneRightToe",
}


local function t(key, replacements)
    return Lang(key, replacements)
end

local function buildTranslations()
    local translations = {}

    for i = 1, #translationKeys do
        local key = translationKeys[i]
        translations[key] = t(key)
    end

    return translations
end

local function sendVisible(visible)
    debugAction("nui:visible", {
        visible = visible == true,
    })

    SendNUIMessage({
        action = "setVisible",
        visible = visible == true,
        translations = buildTranslations(),
        animations = Config.Animations or {},
        flags = Config.AnimationFlags or {},
        defaults = Config.DefaultAnimation or {},
        props = Config.Props or {},
        bones = Config.Bones or {},
        nudgeSteps = Config.NudgeSteps or {},
        defaultProp = Config.DefaultProp or {},
        maxProps = Config.MaxEditorProps,
    })
end

local function startControlsThread()
    if controlsThreadRunning then return end

    controlsThreadRunning = true
    CreateThread(function()
        local controls = {
            1, 2, -- look
            14, 15, 241, 242, -- mouse wheel
            24, 25, 257, 263, 264, -- attack/melee
            30, 31, 32, 33, 34, 35, -- movement
            21, 22, 36, 44, -- sprint/jump/duck/cover
            37, 45, 47, 58, -- weapon/reload/actions
            140, 141, 142, 143, -- melee
            200, 202, 322, -- pause/back
        }

        while isOpen do
            if movementTesting then
                local exit = Config.CloseKey or 177
                DisableControlAction(0, exit, true)
                if IsDisabledControlJustPressed(0, exit) or IsEntityDead(PlayerPedId()) then stopMovementTest() end
            elseif not gizmoActive then
                for i = 1, #controls do
                    DisableControlAction(0, controls[i], true)
                end
                DisablePlayerFiring(PlayerId(), true)
                SetPauseMenuActive(false)
            end
            Wait(0)
        end

        controlsThreadRunning = false
    end)
end

local function getEditorCamera()
    return pr_lib.editorCamera
        or (pr_lib.fivem and (pr_lib.fivem.editorCamera or pr_lib.fivem.editor_camera))
        or (_G and (_G.PRBridgeEditorCamera or _G.EditorCamera))
end

local function getCameraBoneId(target)
    if target == "head" then
        return 31086
    end

    if target == "foot" then return 14201 end
    if target == "leftHand" then return 18905 end
    if target == "rightHand" then return 57005 end
    return 24818
end

local function deleteEntity(entity)
    if entity and entity ~= 0 and DoesEntityExist(entity) then
        SetEntityAsMissionEntity(entity, true, true)
        DeleteEntity(entity)
    end
end

local function deleteCameraTarget()
    if cameraTargetDummy and DoesEntityExist(cameraTargetDummy) then
        debugAction("camera:dummy:delete", {
            entity = cameraTargetDummy,
        })
    end

    deleteEntity(cameraTargetDummy)
    cameraTargetDummy = nil
end

local function createCameraTarget(target)
    local ped, session = PlayerPedId(), editorSession

    if not ped or ped == 0 or not DoesEntityExist(ped) then
        bridgeDebug("warn", "[pr_animateConfig] Camera sem ped valido, usando fallback indisponivel.")
        return nil
    end

    deleteCameraTarget()

    local boneId = getCameraBoneId(target)
    local boneIndex = GetPedBoneIndex(ped, boneId)
    if boneIndex < 0 then return ped end
    local coords = GetWorldPositionOfEntityBone(ped, boneIndex)
    local modelHash = GetHashKey("prop_ld_test_01")

    RequestModel(modelHash)

    local startedAt = GetGameTimer()
    while not HasModelLoaded(modelHash) do
        Wait(0)
        if session ~= editorSession or movementTesting then
            SetModelAsNoLongerNeeded(modelHash)
            return nil
        end
        if GetGameTimer() - startedAt > 1500 then
            bridgeDebug("warn", "[pr_animateConfig] Dummy da camera nao carregou, usando ped como alvo.")
            debugAction("camera:dummy:fallback", {
                target = target,
                reason = "model_timeout",
            }, "warn")
            SetModelAsNoLongerNeeded(modelHash)
            return ped
        end
    end

    local dummy = CreateObject(modelHash, coords.x, coords.y, coords.z, false, false, false)
    SetModelAsNoLongerNeeded(modelHash)

    if not dummy or dummy == 0 or not DoesEntityExist(dummy) then
        bridgeDebug("warn", "[pr_animateConfig] Dummy da camera nao criou, usando ped como alvo.")
        debugAction("camera:dummy:fallback", {
            target = target,
            reason = "create_failed",
        }, "warn")
        return ped
    end

    SetEntityAsMissionEntity(dummy, true, true)
    SetEntityVisible(dummy, false, false)
    SetEntityCollision(dummy, false, false)
    FreezeEntityPosition(dummy, false)

    AttachEntityToEntity(
        dummy,
        ped,
        boneIndex,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        false,
        false,
        false,
        false,
        2,
        true
    )

    cameraTargetDummy = dummy
    debugAction("camera:dummy:create", {
        target = target,
        boneId = boneId,
        boneIndex = boneIndex,
        entity = dummy,
    })

    return dummy
end

local function startEditorCamera(target)
    local editorCamera = getEditorCamera()

    if not editorCamera or type(editorCamera.start) ~= "function" then
        bridgeDebug("warn", "[pr_animateConfig] editorCamera do pr_bridge indisponivel.")
        return false
    end

    currentCameraTarget = target or currentCameraTarget or "waist"

    local targetEntity = createCameraTarget(currentCameraTarget)
    if not targetEntity or targetEntity == 0 or not DoesEntityExist(targetEntity) then
        return false
    end

    local started = editorCamera.start(targetEntity)
    debugAction("camera:start", {
        target = currentCameraTarget,
        targetEntity = targetEntity,
        ok = started == true,
    }, started and "info" or "warn")

    bridgeDebug(started and "info" or "warn", ("[pr_animateConfig] editorCamera start target=%s ok=%s"):format(
        tostring(currentCameraTarget),
        tostring(started)
    ))

    return started == true
end

local function stopEditorCamera()
    local editorCamera = getEditorCamera()

    if editorCamera and type(editorCamera.stop) == "function" then
        local stopped = editorCamera.stop()
        debugAction("camera:stop", {
            ok = stopped == true,
        })
    end

    deleteCameraTarget()
end

local function vectorFromData(data, fallback)
    data = data or {}
    fallback = fallback or vector3(0.0, 0.0, 0.0)

    return vector3(
        tonumber(data.x) or fallback.x,
        tonumber(data.y) or fallback.y,
        tonumber(data.z) or fallback.z
    )
end

local function clearEditorProps()
    for _, prop in ipairs(editorProps) do deleteEntity(prop.entity) end
    editorProps, propData = {}, {}
end

local function attachEntityToPedBone(prop)
    prop = prop or propData
    local ped = PlayerPedId()
    if not prop.entity or not DoesEntityExist(prop.entity) or not DoesEntityExist(ped) then return false end

    local boneIndex = GetPedBoneIndex(ped, prop.boneId)
    if boneIndex < 0 then return false end

    AttachEntityToEntity(prop.entity, ped, boneIndex,
        prop.offset.x, prop.offset.y, prop.offset.z, prop.rot.x, prop.rot.y, prop.rot.z,
        true, true, false, true, prop.rotOrder, true)
    return true
end

local function getGizmo()
    return (pr_lib.fivem and pr_lib.fivem.gizmo) or pr_lib.gizmo
end

local function sendGizmoState(active)
    SendNUIMessage({
        action = "setGizmoState",
        active = active == true,
    })
end

local function sendCurrentOffsets()
    SendNUIMessage({
        action = "updateOffsets",
        id = propData.id,
        offset = {
            x = propData.offset.x,
            y = propData.offset.y,
            z = propData.offset.z,
        },
        rotation = {
            x = propData.rot.x,
            y = propData.rot.y,
            z = propData.rot.z,
        },
    })
end

local function quaternionMultiply(ax, ay, az, aw, bx, by, bz, bw)
    return
        aw * bx + ax * bw + ay * bz - az * by,
        aw * by - ax * bz + ay * bw + az * bx,
        aw * bz + ax * by - ay * bx + az * bw,
        aw * bw - ax * bx - ay * by - az * bz
end

local function createBoneTransformAnchor()
    local ped, session = PlayerPedId(), editorSession
    if not DoesEntityExist(ped) or not propData.boneId then return nil end

    local modelHash = GetHashKey("prop_ld_test_01")
    RequestModel(modelHash)
    local startedAt = GetGameTimer()
    while not HasModelLoaded(modelHash) do
        Wait(0)
        if session ~= editorSession or GetGameTimer() - startedAt > 1500 then
            SetModelAsNoLongerNeeded(modelHash)
            return nil
        end
    end

    local coords = GetEntityCoords(ped)
    local anchor = CreateObjectNoOffset(modelHash, coords.x, coords.y, coords.z, false, false, false)
    SetModelAsNoLongerNeeded(modelHash)
    if not anchor or anchor == 0 or not DoesEntityExist(anchor) then return nil end

    SetEntityAsMissionEntity(anchor, true, true)
    SetEntityVisible(anchor, false, false)
    SetEntityCollision(anchor, false, false)

    AttachEntityToEntity(
        anchor, ped, GetPedBoneIndex(ped, propData.boneId),
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        false, false, false, true,
        propData.rotOrder, true
    )
    Wait(0)
    return anchor
end

local function captureWorldTransformAsBoneOffset(sourceEntity, existingAnchor)
    local entity = sourceEntity or propData.entity
    if not entity or not DoesEntityExist(entity) or not propData.boneId then return false end

    local anchor = existingAnchor
    local ownsAnchor = not anchor or not DoesEntityExist(anchor)
    if ownsAnchor then anchor = createBoneTransformAnchor() end
    if not anchor or not DoesEntityExist(anchor) then return false end
    if not DoesEntityExist(entity) then
        if ownsAnchor then deleteEntity(anchor) end
        return false
    end

    local coords = GetEntityCoords(entity)
    local offset = GetOffsetFromEntityGivenWorldCoords(anchor, coords.x, coords.y, coords.z)
    local ax, ay, az, aw = GetEntityQuaternion(anchor)
    local ex, ey, ez, ew = GetEntityQuaternion(entity)
    local lx, ly, lz, lw = quaternionMultiply(-ax, -ay, -az, aw, ex, ey, ez, ew)

    SetEntityQuaternion(entity, lx, ly, lz, lw)
    local rotation = GetEntityRotation(entity, propData.rotOrder)
    SetEntityQuaternion(entity, ex, ey, ez, ew)

    propData.offset = vector3(offset.x, offset.y, offset.z)
    propData.rot = vector3(rotation.x, rotation.y, rotation.z)
    if ownsAnchor then deleteEntity(anchor) end
    return true
end

local function createGizmoHandle(entity)
    if not entity or not DoesEntityExist(entity) then return nil end

    local coords = GetEntityCoords(entity)
    local handle = CreateObjectNoOffset(GetEntityModel(entity), coords.x, coords.y, coords.z, false, false, false)
    if not handle or handle == 0 or not DoesEntityExist(handle) then return nil end

    local qx, qy, qz, qw = GetEntityQuaternion(entity)
    SetEntityQuaternion(handle, qx, qy, qz, qw)
    SetEntityAsMissionEntity(handle, true, true)
    SetEntityVisible(handle, false, false)
    SetEntityCollision(handle, false, false)
    FreezeEntityPosition(handle, true)
    return handle
end

local function syncGizmoHandleToProp(handle, entity)
    if not handle or not DoesEntityExist(handle) or not entity or not DoesEntityExist(entity) then return end

    local coords = GetEntityCoords(entity)
    local qx, qy, qz, qw = GetEntityQuaternion(entity)
    SetEntityCoordsNoOffset(handle, coords.x, coords.y, coords.z, false, false, false)
    SetEntityQuaternion(handle, qx, qy, qz, qw)
end
local function restoreAnimationEditorFocus()
    local session = editorSession
    Wait(125)
    if not isOpen or session ~= editorSession or movementTesting then return end

    startEditorCamera(currentCameraTarget)
    if not isOpen or session ~= editorSession or movementTesting then return end
    SetNuiFocus(true, true)
    if SetNuiFocusKeepInput then SetNuiFocusKeepInput(true) end
end
local function resetAll()
    debugAction("state:reset", {})
    animationRequest = animationRequest + 1
    movementTesting, bonePicker, propOperation = false, nil, nil
    clearEditorProps()
    ClearPedTasksImmediately(PlayerPedId())

    currentAnimation = {
        dict = nil,
        anim = nil,
        flags = 0,
        blendIn = 8.0,
        blendOut = 8.0,
        duration = -1,
        playbackRate = 1.0,
        paused = false,
        pausedTime = 0.0,
        lastTime = 0.0,
        startedAt = 0,
        startPhase = 0.0,
        effectiveRate = 1.0,
    }

end

local function normalizePlaybackRate(value)
    local rate = tonumber(value)
    if rate and rate > 0.0 and rate <= 3.4028234e38 then return rate end
    return 1.0
end

local function getCurrentAnimationDuration()
    if not currentAnimation.dict or not currentAnimation.anim then return 0.0 end

    local duration = GetAnimDuration(currentAnimation.dict, currentAnimation.anim)
    return tonumber(duration) or 0.0
end

local function isPlaying(ped)
    if not DoesEntityExist(ped) or not currentAnimation.dict or not currentAnimation.anim then return false end
    local active = IsEntityPlayingAnim(ped, currentAnimation.dict, currentAnimation.anim, 3)
    return active == true or active == 1
end

local function playCurrentAnimation()
    animationRequest = animationRequest + 1
    local request = animationRequest
    currentAnimation.paused = false
    currentAnimation.startedAt = 0
    currentAnimation.pausedTime = 0.0
    currentAnimation.lastTime = 0.0

    debugAction("anim:play:start", {
        dict = currentAnimation.dict,
        anim = currentAnimation.anim,
        flags = currentAnimation.flags,
        duration = currentAnimation.duration,
        playbackRate = currentAnimation.playbackRate,
    })

    if not currentAnimation.dict or currentAnimation.dict == "" or not currentAnimation.anim or currentAnimation.anim == "" then
        bridgeDebug("warn", "[pr_animateConfig] Animacao invalida: dict/anim vazio.")
        return false
    end

    local ped = PlayerPedId()
    if not ped or ped == 0 or not DoesEntityExist(ped) then
        bridgeDebug("error", "[pr_animateConfig] Ped invalido para animacao.")
        return false
    end

    ClearPedTasks(ped)
    RequestAnimDict(currentAnimation.dict)

    local startedAt = GetGameTimer()
    while not HasAnimDictLoaded(currentAnimation.dict) do
        Wait(0)
        if not isOpen or request ~= animationRequest or PlayerPedId() ~= ped then return false, "cancelled" end
        if GetGameTimer() - startedAt > 5000 then
            bridgeDebug("error", ("[pr_animateConfig] Timeout animDict: %s"):format(tostring(currentAnimation.dict)))
            debugAction("anim:play:timeout", {
                dict = currentAnimation.dict,
            }, "error")
            return false, "animation_unavailable"
        end
    end

    TaskPlayAnim(
        ped,
        currentAnimation.dict,
        currentAnimation.anim,
        8.0,
        8.0,
        -1,
        currentAnimation.flags,
        0.0,
        false,
        false,
        false
    )

    currentAnimation.startedAt = GetGameTimer()
    currentAnimation.startPhase = 0.0
    currentAnimation.effectiveRate = 1.0

    bridgeDebug("info", ("[pr_animateConfig] TaskPlayAnim original restaurado dict=%s anim=%s flags=%s"):format(
        tostring(currentAnimation.dict),
        tostring(currentAnimation.anim),
        tostring(currentAnimation.flags)
    ))
    debugAction("anim:play:result", {
        dict = currentAnimation.dict,
        anim = currentAnimation.anim,
        flags = currentAnimation.flags,
        playing = IsEntityPlayingAnim(ped, currentAnimation.dict, currentAnimation.anim, 3),
    })

    return true
end
local function awaitEditorAnimation(ped, request)
    local deadline = GetGameTimer() + 1000
    while isOpen and request == animationRequest and PlayerPedId() == ped
        and not isPlaying(ped) and GetGameTimer() < deadline
    do
        Wait(0)
    end
    if not isOpen or request ~= animationRequest or PlayerPedId() ~= ped then return false, "cancelled" end
    if not isPlaying(ped) then return false, "animation_unavailable" end
    return true
end

local function startPausedAnimationHold()
    if pauseHoldThreadRunning then return end

    pauseHoldThreadRunning = true
    CreateThread(function()
        while currentAnimation.paused do
            local ped = PlayerPedId()

            if ped and ped ~= 0 and DoesEntityExist(ped)
                and currentAnimation.dict
                and currentAnimation.anim
                and isPlaying(ped)
            then
                SetEntityAnimCurrentTime(ped, currentAnimation.dict, currentAnimation.anim, currentAnimation.pausedTime)
                SetEntityAnimSpeed(ped, currentAnimation.dict, currentAnimation.anim, 0.0)
            else
                debugAction("anim:pause:lost", {
                    dict = currentAnimation.dict,
                    anim = currentAnimation.anim,
                }, "warn")
                currentAnimation.paused = false
            end

            Wait(0)
        end

        pauseHoldThreadRunning = false
    end)
end

local function pauseCurrentAnimation()
    local ped = PlayerPedId()

    if not ped or ped == 0 or not DoesEntityExist(ped) then
        debugAction("anim:pause:failed", {
            reason = "invalid_ped",
        }, "warn")
        return false, 0.0
    end

    if not currentAnimation.dict or currentAnimation.dict == "" or not currentAnimation.anim or currentAnimation.anim == "" then
        debugAction("anim:pause:failed", {
            reason = "invalid_animation",
        }, "warn")
        return false, 0.0
    end

    local playing = isPlaying(ped)
    if not playing then
        debugAction("anim:pause:failed", {
            dict = currentAnimation.dict,
            anim = currentAnimation.anim,
            playing = playing,
        }, "warn")
        return false, 0.0
    end

    local animTime = GetEntityAnimCurrentTime(ped, currentAnimation.dict, currentAnimation.anim)
    if animTime < 0.0 then animTime = currentAnimation.lastTime or 0.0 end
    currentAnimation.paused = true
    currentAnimation.pausedTime = animTime
    currentAnimation.lastTime = animTime

    SetEntityAnimCurrentTime(ped, currentAnimation.dict, currentAnimation.anim, animTime)
    SetEntityAnimSpeed(ped, currentAnimation.dict, currentAnimation.anim, 0.0)
    startPausedAnimationHold()

    debugAction("anim:pause:result", {
        dict = currentAnimation.dict,
        anim = currentAnimation.anim,
        animTime = animTime,
    })

    return true, animTime
end

local function startTimelineThread()
    if timelineThreadRunning then return end

    timelineThreadRunning = true
    CreateThread(function()
        while isOpen do
            local phase = currentAnimation.paused and (currentAnimation.lastTime or currentAnimation.pausedTime) or currentAnimation.lastTime or 0.0
            local playing = false
            local ped = PlayerPedId()

            if ped and ped ~= 0 and DoesEntityExist(ped) and currentAnimation.dict and currentAnimation.anim then
                playing = isPlaying(ped)
                if playing and not currentAnimation.paused then
                    local duration = getCurrentAnimationDuration()
                    local now = GetGameTimer()
                    if duration > 0.0 and currentAnimation.startedAt > 0 then
                        local elapsed = (now - currentAnimation.startedAt) / 1000.0
                        phase = (currentAnimation.startPhase or 0.0)
                            + ((elapsed * (currentAnimation.effectiveRate or 1.0)) / duration)
                        if (currentAnimation.flags or 0) % 2 == 1 then
                            phase = phase % 1.0
                        else
                            phase = math.min(1.0, phase)
                        end
                    end
                    currentAnimation.lastTime = phase
                    local rate = currentAnimation.playbackRate
                    if currentAnimation.startedAt > 0 and rate ~= currentAnimation.effectiveRate then
                        SetEntityAnimSpeed(ped, currentAnimation.dict, currentAnimation.anim, rate)
                        -- Continue the timeline from the same position at the new speed.
                        currentAnimation.startPhase = phase
                        currentAnimation.startedAt = now
                        currentAnimation.effectiveRate = rate
                    end
                end
            end

            SendNUIMessage({
                action = "animationTimeline",
                phase = math.max(0.0, math.min(1.0, tonumber(phase) or 0.0)),
                durationSeconds = getCurrentAnimationDuration(),
                paused = currentAnimation.paused == true,
                playing = playing,
                dict = currentAnimation.dict,
                anim = currentAnimation.anim,
            })

            Wait(75)
        end

        timelineThreadRunning = false
    end)
end

local supportedWeather = { CLEAR = true, EXTRASUNNY = true, CLOUDS = true, OVERCAST = true, RAIN = true, FOGGY = true }

local function clearSceneOverrides()
    if sceneOverrides.clock then
        local weather = pr_lib.weather
        local clock
        if weather and weather.GetSnapshot then
            local ok, available, snapshot = pcall(weather.GetSnapshot)
            if ok and available and type(snapshot) == "table" then clock = snapshot.currentTime end
        end
        if clock and tonumber(clock.hour) and tonumber(clock.minute) then
            NetworkOverrideClockTime(clock.hour, clock.minute, 0)
        else
            NetworkClearClockTimeOverride()
        end
    end
    if sceneOverrides.weather then ClearOverrideWeather() end
    sceneOverrides = {}
end

local function applySceneWeather()
    if scene.hour then
        NetworkOverrideClockTime(scene.hour, 0, 0)
        sceneOverrides.clock = true
    end
    if scene.weather then
        SetOverrideWeather(scene.weather)
        sceneOverrides.weather = true
    end
end

local function updateScene(data)
    local color = type(data.color) == "string" and data.color:match("^#(%x%x%x%x%x%x)$") or "24c848"
    if (data.hour == nil and sceneOverrides.clock) or (not supportedWeather[data.weather] and sceneOverrides.weather) then
        clearSceneOverrides()
    end
    scene = {
        backdrop = data.backdrop == true,
        r = tonumber(color:sub(1, 2), 16), g = tonumber(color:sub(3, 4), 16), b = tonumber(color:sub(5, 6), 16),
        hour = data.hour ~= nil and math.floor(math.max(0, math.min(23, tonumber(data.hour) or 12))) or nil,
        weather = supportedWeather[data.weather] and data.weather or nil,
    }
    applySceneWeather()
end

local function drawBackdrop(ped)
    local camera = GetFinalRenderedCamCoord()
    local rotation = GetFinalRenderedCamRot(2)
    local pitch, yaw = math.rad(rotation.x), math.rad(rotation.z)
    local sinPitch, cosPitch = math.sin(pitch), math.cos(pitch)
    local sinYaw, cosYaw = math.sin(yaw), math.cos(yaw)
    local forward = vector3(-sinYaw * cosPitch, cosYaw * cosPitch, sinPitch)
    local right = vector3(cosYaw, sinYaw, 0.0)
    local up = vector3(sinYaw * sinPitch, -cosYaw * sinPitch, cosPitch)
    local delta = GetEntityCoords(ped) + vector3(0.0, 0.0, 0.85) - camera
    local depth = math.max(2.0, delta.x * forward.x + delta.y * forward.y + delta.z * forward.z + 1.8)
    local center = camera + forward * depth
    local halfHeight = depth * math.tan(math.rad(GetFinalRenderedCamFov()) * 0.5) * 1.08
    local horizontal = right * (halfHeight * GetAspectRatio(false))
    local vertical = up * halfHeight
    local a, b = center - horizontal + vertical, center - horizontal - vertical
    local c, d = center + horizontal - vertical, center + horizontal + vertical
    DrawPoly(a.x, a.y, a.z, b.x, b.y, b.z, c.x, c.y, c.z, scene.r, scene.g, scene.b, 255)
    DrawPoly(a.x, a.y, a.z, c.x, c.y, c.z, d.x, d.y, d.z, scene.r, scene.g, scene.b, 255)
end

local function startSceneThread()
    local session = editorSession
    CreateThread(function()
        local updateWeatherAt = 0
        while isOpen and session == editorSession do
            if not movementTesting then
                local now = GetGameTimer()
                if (scene.hour or scene.weather) and now >= updateWeatherAt then
                    applySceneWeather()
                    updateWeatherAt = now + 500
                end
                local ped = PlayerPedId()
                if scene.backdrop and DoesEntityExist(ped) then drawBackdrop(ped) end
            end
            Wait(scene.backdrop and not movementTesting and 0 or 100)
        end
    end)
end

stopMovementTest = function()
    if not movementTesting then return end
    movementTesting = false
    applySceneWeather()
    CreateThread(restoreAnimationEditorFocus)
    SendNUIMessage({ action = "testMode", active = false })
end

local function forceOpenUi(source)
    debugAction("ui:open", {
        source = source or "unknown",
    })

    editorSession = editorSession + 1
    isOpen = true
    SetNuiFocus(true, true)
    if SetNuiFocusKeepInput then
        SetNuiFocusKeepInput(true)
    end
    startControlsThread()
    startTimelineThread()
    startSceneThread()
    startEditorCamera(currentCameraTarget)
    if not isOpen then return false end
    sendVisible(true)
    sendEditorProps()
    bridgeDebug("info", ("[pr_animateConfig] openUi source=%s"):format(source or "unknown"))
    return true
end

local function openUi(source)
    if isOpen then return true end
    return forceOpenUi(source or "open")
end

local function closeUi()
    if not isOpen then return end

    local gizmo = getGizmo()
    if gizmoActive and gizmo and type(gizmo.cancel) == "function" then
        gizmo.cancel("editor_closed")
    end

    debugAction("ui:close", {})
    isOpen = false
    editorSession = editorSession + 1
    gizmoActive = false
    stopEditorCamera()
    clearSceneOverrides()
    scene = {}
    resetAll()
    SetNuiFocus(false, false)
    if SetNuiFocusKeepInput then
        SetNuiFocusKeepInput(false)
    end
    sendVisible(false)
end

local function stopSavedAnimation()
    savedPlayback.token = savedPlayback.token + 1

    if savedPlayback.ped and DoesEntityExist(savedPlayback.ped) and savedPlayback.dict and savedPlayback.anim then
        StopAnimTask(savedPlayback.ped, savedPlayback.dict, savedPlayback.anim, 8.0)
    end

    for i = 1, #savedPlayback.props do
        deleteEntity(savedPlayback.props[i])
    end

    savedPlayback.ped = nil
    savedPlayback.dict = nil
    savedPlayback.anim = nil
    savedPlayback.props = {}
    return true
end

local function requestRuntimeModel(modelHash, timeout)
    RequestModel(modelHash)
    local startedAt = GetGameTimer()
    while not HasModelLoaded(modelHash) do
        Wait(0)
        if GetGameTimer() - startedAt > (timeout or 5000) then return false end
    end
    return true
end

local function requestRuntimeAnimDict(dict, timeout)
    RequestAnimDict(dict)
    local startedAt = GetGameTimer()
    while not HasAnimDictLoaded(dict) do
        Wait(0)
        if GetGameTimer() - startedAt > (timeout or 5000) then return false end
    end
    return true
end

local function playSavedAnimation(id, durationSeconds)
    id = tostring(id or ""):lower():gsub("%s+", "_"):gsub("[^%w_-]", ""):sub(1, 64)
    local entry = savedAnimationCatalog[id]
    if type(entry) ~= "table" or type(entry.animation) ~= "table" then
        bridgeDebug("warn", ("[pr_animateConfig] ID de animacao nao encontrado: %s"):format(id))
        return false
    end

    local animation = entry.animation
    if type(animation.dict) ~= "string" or animation.dict == ""
        or type(animation.anim) ~= "string" or animation.anim == ""
    then
        return false
    end

    stopSavedAnimation()
    if not requestRuntimeAnimDict(animation.dict, 5000) then return false end

    local ped = PlayerPedId()
    local overrideSeconds = tonumber(durationSeconds)
    local taskDuration = tonumber(animation.duration) or -1
    if overrideSeconds and overrideSeconds > 0 then
        taskDuration = math.floor(overrideSeconds * 1000)
    end

    TaskPlayAnim(
        ped,
        animation.dict,
        animation.anim,
        math.abs(tonumber(animation.blendIn) or 8.0),
        math.abs(tonumber(animation.blendOut) or 8.0),
        taskDuration,
        math.floor(tonumber(animation.flag) or 0),
        0.0,
        false,
        false,
        false
    )

    savedPlayback.ped = ped
    savedPlayback.dict = animation.dict
    savedPlayback.anim = animation.anim
    local token = savedPlayback.token

    local props = type(entry.props) == "table" and entry.props or {}
    for i = 1, #props do
        local prop = props[i]
        local modelHash = GetHashKey(prop.model or "")
        if modelHash ~= 0 and requestRuntimeModel(modelHash, 5000) then
            local coords = GetEntityCoords(ped)
            local entity = CreateObjectNoOffset(modelHash, coords.x, coords.y, coords.z, true, true, false)
            SetModelAsNoLongerNeeded(modelHash)

            if entity and entity ~= 0 and DoesEntityExist(entity) then
                local offset = prop.offset or {}
                local rotation = prop.rotation or {}
                AttachEntityToEntity(
                    entity,
                    ped,
                    GetPedBoneIndex(ped, math.floor(tonumber(prop.boneId) or 57005)),
                    tonumber(offset.x) or 0.0,
                    tonumber(offset.y) or 0.0,
                    tonumber(offset.z) or 0.0,
                    tonumber(rotation.x) or 0.0,
                    tonumber(rotation.y) or 0.0,
                    tonumber(rotation.z) or 0.0,
                    true,
                    true,
                    false,
                    true,
                    math.floor(tonumber(prop.rotationOrder) or 2),
                    true
                )
                savedPlayback.props[#savedPlayback.props + 1] = entity
            end
        end
    end

    if taskDuration > 0 then
        SetTimeout(taskDuration, function()
            if savedPlayback.token == token then stopSavedAnimation() end
        end)
    end

    bridgeDebug("success", ("[pr_animateConfig] Animacao '%s' executada por %s segundo(s)."):format(
        id,
        overrideSeconds and tostring(overrideSeconds) or "duracao configurada"
    ))
    return true
end

RegisterNetEvent("pr_animateConfig:client:setCatalog", function(animations)
    savedAnimationCatalog = type(animations) == "table" and animations or {}
end)

RegisterNetEvent("pr_animateConfig:client:playSaved", function(id, durationSeconds)
    CreateThread(function()
        playSavedAnimation(id, durationSeconds)
    end)
end)

RegisterNetEvent("pr_animateConfig:client:stopSaved", stopSavedAnimation)

CreateThread(function()
    Wait(0)
    TriggerServerEvent("pr_animateConfig:server:requestCatalog")
end)

RegisterCommand(Config.Command or "animconfig", function()
    if isOpen then
        closeUi()
    else
        openUi("command")
    end
end, false)

pr_lib.addKeybind({
    name = "pr_animateConfig_open_menu",
    description = t("keybindOpenMenu"),
    defaultKey = Config.KeyBinds,
    onPressed = function(self)
        local combo = self and self.currentKey or (type(Config.KeyBinds) == "table" and table.concat(Config.KeyBinds, " + ") or tostring(Config.KeyBinds or ""))
        bridgeDebug("success", ("[pr_animateConfig] %s: %s"):format(t("keybindOpened"), combo))
        openUi("keybind")
        notify(t("appTitle"), t("keybindOpened"), "success")
    end,
})

RegisterNUICallback("close", function(_, cb)
    closeUi()
    cb({ ok = true })
end)

RegisterNUICallback("pageReady", function(_, cb)
    debugAction("nui:pageReady", {
        open = isOpen,
    })

    if isOpen then
        sendVisible(true)
        sendEditorProps()
        if movementTesting then SendNUIMessage({ action = "testMode", active = true }) end
    end
    cb({ ok = true })
end)

local function editorReady()
    return isOpen and not movementTesting and not gizmoActive and not propOperation
end

local function readAnimation(data)
    if type(data) ~= "table" or type(data.dict) ~= "string" or data.dict == "" or #data.dict > 200
        or type(data.anim) ~= "string" or data.anim == "" or #data.anim > 200 then return nil end
    local flags = tonumber(data.flag or data.flags) or 0
    if flags ~= flags or math.abs(flags) > 2147483647 then flags = 0 end
    return {
        dict = data.dict, anim = data.anim, flags = math.floor(flags),
        blendIn = tonumber(data.blendIn) or 8.0, blendOut = tonumber(data.blendOut) or 8.0,
        duration = tonumber(data.duration) or -1, playbackRate = normalizePlaybackRate(data.playbackRate),
    }
end

local function playEditorAnimation(data, allowResume)
    local clip = readAnimation(data)
    if not clip then return false, "animation_unavailable" end

    local ped = PlayerPedId()
    local resume = allowResume and currentAnimation.paused and currentAnimation.dict == clip.dict
        and currentAnimation.anim == clip.anim and currentAnimation.flags == clip.flags and isPlaying(ped)
    for key, value in pairs(clip) do currentAnimation[key] = value end
    if resume then
        currentAnimation.paused = false
        currentAnimation.startPhase = currentAnimation.pausedTime
        currentAnimation.lastTime = currentAnimation.startPhase
        currentAnimation.startedAt = GetGameTimer()
        currentAnimation.effectiveRate = clip.playbackRate
        SetEntityAnimSpeed(ped, clip.dict, clip.anim, clip.playbackRate)
        return true
    end
    return playCurrentAnimation()
end

RegisterNUICallback("playAnimation", function(data, cb)
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    local ok, reason = playEditorAnimation(data, true)
    cb({ ok = ok, error = reason or (not ok and "animation_unavailable" or nil) })
end)

RegisterNUICallback("testAnimation", function(data, cb)
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    local ped = PlayerPedId()
    if IsEntityDead(ped) or IsPedInAnyVehicle(ped, false) then return cb({ ok = false, error = "testUnavailable" }) end
    local session = editorSession
    local ok, reason = playEditorAnimation(data, true)
    if ok then ok, reason = awaitEditorAnimation(ped, animationRequest) end
    if not ok or editorSession ~= session then return cb({ ok = false, error = reason or "cancelled" }) end

    movementTesting = true
    bonePicker = nil
    clearSceneOverrides()
    stopEditorCamera()
    SetNuiFocus(false, false)
    if SetNuiFocusKeepInput then SetNuiFocusKeepInput(false) end
    SendNUIMessage({ action = "testMode", active = true })
    cb({ ok = true })
end)

RegisterNUICallback("setScene", function(data, cb)
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    updateScene(data)
    cb({ ok = true })
end)

RegisterNUICallback("setPlaybackRate", function(data, cb)
    if isOpen then
        currentAnimation.playbackRate = normalizePlaybackRate(data.rate)
    end
    cb({ ok = isOpen })
end)

RegisterNUICallback("stopAnimation", function(_, cb)
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    debugAction("nui:stopAnimation", {})
    animationRequest = animationRequest + 1
    currentAnimation.paused = false
    currentAnimation.pausedTime = 0.0
    currentAnimation.lastTime = 0.0
    currentAnimation.startedAt = 0
    currentAnimation.startPhase = 0.0
    ClearPedTasks(PlayerPedId())
    SendNUIMessage({
        action = "animationTimeline",
        phase = 0.0,
        durationSeconds = getCurrentAnimationDuration(),
        paused = false,
        playing = false,
    })
    cb({ ok = true })
end)

RegisterNUICallback("pauseAnimation", function(_, cb)
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    debugAction("nui:pauseAnimation", {})
    local ok, animTime = pauseCurrentAnimation()
    cb({
        ok = ok,
        error = not ok and "animation_unavailable" or nil,
        animTime = animTime,
    })
end)

local function seekPose(phase)
    if not currentAnimation.dict or not currentAnimation.anim then return false, "animation_unavailable" end
    local ped = PlayerPedId()
    if not isPlaying(ped) then
        local ok, reason = playCurrentAnimation()
        if not ok then return false, reason end

        ok, reason = awaitEditorAnimation(ped, animationRequest)
        if not ok then return false, reason end
    end

    currentAnimation.paused = true
    currentAnimation.pausedTime = phase
    currentAnimation.lastTime = phase
    SetEntityAnimCurrentTime(ped, currentAnimation.dict, currentAnimation.anim, phase)
    SetEntityAnimSpeed(ped, currentAnimation.dict, currentAnimation.anim, 0.0)
    startPausedAnimationHold()
    return true
end

RegisterNUICallback("seekAnimation", function(data, cb)
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    local phase = math.max(0.0, math.min(0.9999, tonumber(data.phase) or 0.0))
    local ok, reason = seekPose(phase)
    cb({ ok = ok, error = reason, phase = phase, durationSeconds = getCurrentAnimationDuration() })
end)

local function editorPropIndex(id)
    for index, item in ipairs(editorProps) do
        if item.id == id then return index end
    end
end

local function validBone(value, fallback)
    local boneId = math.floor(tonumber(value) or fallback)
    if boneId < 0 or boneId > 65535 or GetPedBoneIndex(PlayerPedId(), boneId) < 0 then return nil end
    return boneId
end

local function readRotationOrder(value)
    return math.floor(math.max(0, math.min(5, tonumber(value) or 2)))
end

local function createEditorProp(data, operation)
    if type(data) ~= "table" or type(data.model) ~= "string" or data.model == "" or #data.model > 80 then
        return nil, "invalidModel"
    end

    local model = GetHashKey(data.model)
    if not IsModelInCdimage(model) or not IsModelValid(model) or IsModelAPed(model) or IsModelAVehicle(model) then
        return nil, "invalidModel"
    end

    local ped = PlayerPedId()
    local boneId = validBone(data.boneId or data.bone, 57005)
    if not boneId then return nil, "invalidBone" end

    RequestModel(model)
    local startedAt = GetGameTimer()
    while propOperation == operation and not HasModelLoaded(model) and GetGameTimer() - startedAt < 5000 do
        Wait(0)
    end
    if propOperation ~= operation or PlayerPedId() ~= ped or not HasModelLoaded(model) then
        SetModelAsNoLongerNeeded(model)
        return nil, "modelLoadFailed"
    end

    local coords = GetEntityCoords(ped)
    local entity = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, false, false, false)
    SetModelAsNoLongerNeeded(model)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return nil, "modelLoadFailed" end

    nextPropId = nextPropId + 1
    local prop = {
        id = nextPropId, entity = entity, model = data.model, boneId = boneId, rotOrder = readRotationOrder(data.rotationOrder),
        offset = vectorFromData(data.offset or data.pos), rot = vectorFromData(data.rotation or data.rot),
        visible = data.visible ~= false,
    }
    SetEntityAsMissionEntity(entity, true, true)
    SetEntityCollision(entity, false, false)
    SetEntityVisible(entity, false, false)
    if not attachEntityToPedBone(prop) then
        deleteEntity(entity)
        return nil, "invalidBone"
    end
    return prop
end

local function convertPropRotation(prop, order)
    if prop.rotOrder == order then return prop.rot end
    local handle = createGizmoHandle(prop.entity)
    if not handle then return nil end
    SetEntityRotation(handle, prop.rot.x, prop.rot.y, prop.rot.z, prop.rotOrder, true)
    local rotation = GetEntityRotation(handle, order)
    deleteEntity(handle)
    return rotation
end

RegisterNUICallback("spawnProp", function(data, cb)
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    local index = data.replace and editorPropIndex(data.id)
    if data.replace and not index then return cb({ ok = false, error = "noProp" }) end
    if not index and #editorProps >= Config.MaxEditorProps then return cb({ ok = false, error = "propLimit" }) end

    if index then
        local existing = editorProps[index]
        data.boneId, data.rotationOrder, data.visible = existing.boneId, existing.rotOrder, existing.visible
        data.offset, data.rotation = plainVector(existing.offset), plainVector(existing.rot)
    end

    local operation = {}
    propOperation = operation
    local prop, reason = createEditorProp(data, operation)
    if propOperation == operation then propOperation = nil end
    if not prop then return cb({ ok = false, error = reason }) end
    if index then deleteEntity(editorProps[index].entity) end
    editorProps[index or #editorProps + 1] = prop
    propData = prop
    SetEntityVisible(prop.entity, prop.visible, false)
    sendEditorProps(true)
    cb({ ok = true })
end)

RegisterNUICallback("selectProp", function(data, cb)
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    local index = editorPropIndex(data.id)
    if not index then return cb({ ok = false, error = "noProp" }) end
    propData = editorProps[index]
    sendEditorProps()
    cb({ ok = true })
end)

RegisterNUICallback("togglePropVisibility", function(data, cb)
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    local index = editorPropIndex(data.id)
    if not index then return cb({ ok = false, error = "noProp" }) end
    local prop = editorProps[index]
    prop.visible = not prop.visible
    SetEntityVisible(prop.entity, prop.visible, false)
    sendEditorProps(true)
    cb({ ok = true })
end)

RegisterNUICallback("deleteProp", function(data, cb)
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    local index = editorPropIndex(data.id)
    if not index then return cb({ ok = false, error = "noProp" }) end
    local removed = table.remove(editorProps, index)
    deleteEntity(removed.entity)
    if removed == propData then propData = editorProps[index] or editorProps[index - 1] or {} end
    sendEditorProps(true)
    cb({ ok = true })
end)

RegisterNUICallback("updatePropOffsets", function(data, cb)
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    local index = editorPropIndex(data.id)
    if not index then return cb({ ok = false, error = "noProp" }) end
    local prop = editorProps[index]
    if data.revision and prop.revision and data.revision <= prop.revision then return cb({ ok = false, error = "cancelled" }) end
    local bone = validBone(data.boneId, prop.boneId)
    if not bone or not DoesEntityExist(prop.entity) then return cb({ ok = false, error = "invalidBone" }) end

    local order = readRotationOrder(data.rotationOrder)
    local rotation = vectorFromData(data.rotation, prop.rot)
    if order ~= prop.rotOrder and data.preserveRotation ~= false then
        rotation = convertPropRotation(prop, order)
        if not rotation then return cb({ ok = false, error = "rotationFailed" }) end
    end

    prop.revision = data.revision
    prop.boneId, prop.rotOrder, prop.rot = bone, order, rotation
    prop.offset = vectorFromData(data.offset, prop.offset)
    attachEntityToPedBone(prop)
    cb({ ok = true, rotation = plainVector(rotation), rotationOrder = order })
end)

RegisterNUICallback("setBonePicker", function(data, cb)
    if not data.active then
        bonePicker = nil
        SendNUIMessage({ action = "boneMarkers", markers = {} })
        return cb({ ok = true })
    end
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    local picker, group = {}, data.group or "body"
    bonePicker = picker
    CreateThread(function()
        local ped = PlayerPedId()
        local bones = {}
        for _, bone in ipairs(Config.Bones) do
            if group == "all" or group == bone.group or (group == "body" and not bone.finger) then
                local index = GetPedBoneIndex(ped, bone.id)
                if index >= 0 then bones[#bones + 1] = { id = bone.id, index = index } end
            end
        end
        while bonePicker == picker and ped == PlayerPedId() and DoesEntityExist(ped) do
            local markers = {}
            local pedCoords = GetEntityCoords(ped)
            local towardCamera = GetFinalRenderedCamCoord() - pedCoords
            for _, bone in ipairs(bones) do
                local coords = GetWorldPositionOfEntityBone(ped, bone.index)
                local visible, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
                if visible then
                    local delta = coords - pedCoords
                    local depth = delta.x * towardCamera.x + delta.y * towardCamera.y + delta.z * towardCamera.z
                    markers[#markers + 1] = { id = bone.id, x = x, y = y, depth = depth }
                end
            end
            table.sort(markers, function(a, b) return a.depth < b.depth end)
            SendNUIMessage({ action = "boneMarkers", group = group, markers = markers })
            Wait(40)
        end
    end)
    cb({ ok = true })
end)

RegisterNUICallback("getCatalog", function(_, cb)
    cb({ ok = isOpen, animations = savedAnimationCatalog })
end)

RegisterNUICallback("restoreSnapshot", function(data, cb)
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    if type(data.props) ~= "table" or #data.props > Config.MaxEditorProps then return cb({ ok = false, error = "propLimit" }) end

    local operation, replacement, session = {}, {}, editorSession
    propOperation = operation
    for i, item in ipairs(data.props) do
        local prop, reason = createEditorProp(item, operation)
        if not prop then
            for _, created in ipairs(replacement) do deleteEntity(created.entity) end
            if propOperation == operation then propOperation = nil end
            return cb({ ok = false, error = reason })
        end
        replacement[i] = prop
    end

    clearEditorProps()
    editorProps = replacement
    propData = replacement[tonumber(data.selectedIndex) or 1] or replacement[1] or {}
    for _, prop in ipairs(editorProps) do SetEntityVisible(prop.entity, prop.visible, false) end
    if type(data.scene) == "table" then updateScene(data.scene) end
    sendEditorProps()

    local playbackError
    if readAnimation(data.animation) then
        local ok, reason = playEditorAnimation(data.animation, false)
        if ok and data.paused == true then
            ok, reason = awaitEditorAnimation(PlayerPedId(), animationRequest)
            if ok then ok, reason = seekPose(math.max(0.0, math.min(0.9999, tonumber(data.phase) or 0.0))) end
        end
        if not ok then playbackError = reason or "animation_unavailable" end
    else
        animationRequest = animationRequest + 1
        currentAnimation.dict, currentAnimation.anim = nil, nil
        currentAnimation.paused, currentAnimation.lastTime, currentAnimation.startedAt = false, 0.0, 0
        ClearPedTasks(PlayerPedId())
    end

    if propOperation == operation then propOperation = nil end
    cb({ ok = session == editorSession, playbackError = playbackError })
end)

RegisterNUICallback("scullyRotations", function(data, cb)
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    if type(data.ids) ~= "table" or #data.ids > Config.MaxEditorProps then return cb({ ok = false, error = "propLimit" }) end
    local rotations = {}
    for i, id in ipairs(data.ids) do
        local index = editorPropIndex(id)
        if not index then return cb({ ok = false, error = "noProp" }) end
        local rotation = convertPropRotation(editorProps[index], 1)
        if not rotation then return cb({ ok = false, error = "rotationFailed" }) end
        rotations[i] = plainVector(rotation)
    end
    cb({ ok = true, rotations = rotations })
end)

RegisterNUICallback("changeCameraTarget", function(data, cb)
    if not editorReady() then return cb({ ok = false, error = "busy" }) end
    local target = data.target
    if target ~= "head" and target ~= "waist" and target ~= "foot" and target ~= "leftHand" and target ~= "rightHand" then
        return cb({ ok = false, error = "cameraUnavailable" })
    end
    local ok = startEditorCamera(target)
    cb({ ok = ok, error = not ok and "cameraUnavailable" or nil })
end)

RegisterNUICallback("toggleGizmo", function(_, cb)
    local entity = propData.entity
    local gizmo = getGizmo()

    if not editorReady() then
        cb({ ok = false, error = "busy" })
        return
    end

    if not propData.visible or not entity or not DoesEntityExist(entity) then
        cb({ ok = false, error = "noProp" })
        return
    end

    if not gizmo or type(gizmo.await) ~= "function" then
        cb({ ok = false, error = "gizmo_missing", message = t("gizmoMissing") })
        return
    end

    local operation, session = {}, editorSession
    propOperation = operation
    local handle = createGizmoHandle(entity)
    local boneAnchor = handle and createBoneTransformAnchor()
    if propOperation == operation then propOperation = nil end
    if not isOpen or session ~= editorSession or not handle or not boneAnchor or not DoesEntityExist(entity) then
        deleteEntity(handle)
        deleteEntity(boneAnchor)
        cb({ ok = false, error = "gizmo_handle_failed" })
        return
    end

    local originalOffset = vector3(propData.offset.x, propData.offset.y, propData.offset.z)
    local originalRotation = vector3(propData.rot.x, propData.rot.y, propData.rot.z)
    local handleDirty = false
    local syncActive = true
    local lastUiUpdate = 0

    bonePicker = nil
    gizmoActive = true
    sendGizmoState(true)
    cb({ ok = true, started = true })

    CreateThread(function()
        while session == editorSession and syncActive and gizmoActive and DoesEntityExist(handle) and DoesEntityExist(entity) do
            if handleDirty then
                if captureWorldTransformAsBoneOffset(handle, boneAnchor) then
                    attachEntityToPedBone()
                    local now = GetGameTimer()
                    if now - lastUiUpdate >= 80 then
                        sendCurrentOffsets()
                        lastUiUpdate = now
                    end
                end
                handleDirty = false
            elseif gizmo.isDragging ~= true then
                syncGizmoHandleToProp(handle, entity)
            end
            Wait(0)
        end
    end)

    CreateThread(function()
        if session ~= editorSession then
            deleteEntity(handle)
            deleteEntity(boneAnchor)
            return
        end
        stopEditorCamera()
        SetNuiFocus(false, false)
        if SetNuiFocusKeepInput then SetNuiFocusKeepInput(false) end

        local ok, confirmedResult, finalResult = pcall(gizmo.await, handle, {
            title = "Forge Animated - Prop",
            offset = vector3(0.0, 0.0, 0.0),
            precisionMode = false,
            precisionSpeed = 1.0,
            allowFreeCameraToggle = true,
            restoreOnCancel = true,
            useEditorCamera = true,
            editorCameraRadius = 1.4,
            ui = true,
            onUpdate = function()
                handleDirty = true
                return true
            end,
        })

        syncActive = false
        local result = ok and (confirmedResult or finalResult) or nil
        if not ok then
            bridgeDebug("error", ("[pr_animateConfig] Falha no gizmo: %s"):format(tostring(confirmedResult)))
        end

        if session == editorSession and DoesEntityExist(entity) then
            if ok and result and result.confirmed == true and DoesEntityExist(handle) then
                captureWorldTransformAsBoneOffset(handle, boneAnchor)
            else
                propData.offset = originalOffset
                propData.rot = originalRotation
            end
            attachEntityToPedBone()
        end

        deleteEntity(handle)
        deleteEntity(boneAnchor)
        if session == editorSession then
            gizmoActive = false
            sendGizmoState(false)
            sendEditorProps(true)
            restoreAnimationEditorFocus()
        end
    end)
end)
RegisterNUICallback("captureGizmo", function(_, cb)
    local entity = propData.entity
    if not editorReady() then
        cb({ ok = false, error = "busy" })
        return
    end

    if not propData.visible or not entity or not DoesEntityExist(entity) then
        cb({ ok = false, error = "noProp" })
        return
    end

    local operation = {}
    propOperation = operation
    local captured = captureWorldTransformAsBoneOffset(entity)
    if propOperation == operation then propOperation = nil end
    if captured then
        attachEntityToPedBone()
        sendEditorProps(true)
    end
    cb({ ok = captured, error = not captured and "rotationFailed" or nil })
end)

RegisterNUICallback("saveConfig", function(data, cb)
    debugAction("nui:saveConfig", data or {})

    saveRequestId = saveRequestId + 1

    local requestId = ("%s:%s"):format(GetGameTimer(), saveRequestId)
    pendingSaveCallbacks[requestId] = cb

    TriggerServerEvent("pr_animateConfig:server:saveConfig", requestId, data or {})

    SetTimeout(5000, function()
        if not pendingSaveCallbacks[requestId] then return end

        pendingSaveCallbacks[requestId] = nil
        debugAction("server:saveConfig:timeout", {
            requestId = requestId,
        }, "error")
        cb({
            ok = false,
            error = "timeout",
        })
    end)
end)

RegisterNetEvent("pr_animateConfig:client:saveConfigResult", function(requestId, result)
    local cb = pendingSaveCallbacks[requestId]
    if not cb then return end

    pendingSaveCallbacks[requestId] = nil
    debugAction("server:saveConfig:result", result or {}, result and result.ok and "info" or "error")
    cb(result or {
        ok = false,
        error = "empty_result",
    })
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    local gizmo = getGizmo()
    if gizmoActive and gizmo and type(gizmo.stop) == "function" then gizmo.stop() end
    isOpen = false
    editorSession = editorSession + 1
    gizmoActive = false
    stopSavedAnimation()
    clearSceneOverrides()
    resetAll()
    stopEditorCamera()
    SetNuiFocus(false, false)
    if SetNuiFocusKeepInput then
        SetNuiFocusKeepInput(false)
    end
end)

exports("Open", openUi)
exports("Close", closeUi)
exports("Play", playSavedAnimation)
exports("pr_animate", playSavedAnimation)
exports("Stop", stopSavedAnimation)
exports("Get", function(id)
    return savedAnimationCatalog[tostring(id or ""):lower()]
end)
exports("GetAll", function()
    return savedAnimationCatalog
end)
