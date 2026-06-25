local Lang = pr_lib.locale()
local isOpen = false
local controlsThreadRunning = false
local pauseHoldThreadRunning = false
local saveRequestId = 0
local pendingSaveCallbacks = {}
local cameraTargetDummy = nil
local currentCameraTarget = "waist"
local currentAnimation = {
    dict = nil,
    anim = nil,
    flags = 0,
    blendIn = 8.0,
    blendOut = 8.0,
    duration = -1,
    playbackRate = 0.0,
    paused = false,
    pausedTime = 0.0,
}

local propData = {
    entity = nil,
    model = nil,
    boneId = nil,
    offset = vector3(0.0, 0.0, 0.0),
    rot = vector3(0.0, 0.0, 0.0),
    rotOrder = 2,
}

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
}

local disabledCallbacks = {
    "toggleGizmo",
    "captureGizmo",
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
    })
end

local function sendPropStatus(status)
    SendNUIMessage({
        action = "propStatus",
        status = status,
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
            for i = 1, #controls do
                DisableControlAction(0, controls[i], true)
            end

            DisablePlayerFiring(PlayerId(), true)
            SetPauseMenuActive(false)
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

    if target == "foot" then
        return 14201
    end

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
    local ped = PlayerPedId()

    if not ped or ped == 0 or not DoesEntityExist(ped) then
        bridgeDebug("warn", "[pr_animateConfig] Camera sem ped valido, usando fallback indisponivel.")
        return nil
    end

    deleteCameraTarget()

    local boneId = getCameraBoneId(target)
    local boneIndex = GetPedBoneIndex(ped, boneId)
    local coords = GetWorldPositionOfEntityBone(ped, boneIndex)
    local modelHash = GetHashKey("prop_ld_test_01")

    RequestModel(modelHash)

    local startedAt = GetGameTimer()
    while not HasModelLoaded(modelHash) do
        Wait(0)

        if GetGameTimer() - startedAt > 1500 then
            bridgeDebug("warn", "[pr_animateConfig] Dummy da camera nao carregou, usando ped como alvo.")
            debugAction("camera:dummy:fallback", {
                target = target,
                reason = "model_timeout",
            }, "warn")
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

local function deletePropEntity()
    if propData.entity and DoesEntityExist(propData.entity) then
        debugAction("prop:delete", {
            entity = propData.entity,
            model = propData.model,
        })
        deleteEntity(propData.entity)
    end

    propData.entity = nil
    sendPropStatus("none")
end

local function attachEntityToPedBone()
    local ped = PlayerPedId()

    if not propData.entity or not DoesEntityExist(propData.entity) then
        return false
    end

    if not propData.boneId then
        return false
    end

    local boneIndex = GetPedBoneIndex(ped, propData.boneId)

    debugAction("prop:attach", {
        entity = propData.entity,
        boneId = propData.boneId,
        boneIndex = boneIndex,
        rotationOrder = propData.rotOrder,
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

    AttachEntityToEntity(
        propData.entity,
        ped,
        boneIndex,
        propData.offset.x,
        propData.offset.y,
        propData.offset.z,
        propData.rot.x,
        propData.rot.y,
        propData.rot.z,
        true,
        true,
        false,
        true,
        propData.rotOrder,
        true
    )

    return true
end

local function resetAll()
    debugAction("state:reset", {})
    deletePropEntity()
    ClearPedTasksImmediately(PlayerPedId())

    currentAnimation = {
        dict = nil,
        anim = nil,
        flags = 0,
        blendIn = 8.0,
        blendOut = 8.0,
        duration = -1,
        playbackRate = 0.0,
        paused = false,
        pausedTime = 0.0,
    }

    propData.model = nil
    propData.boneId = nil
    propData.offset = vector3(0.0, 0.0, 0.0)
    propData.rot = vector3(0.0, 0.0, 0.0)
    propData.rotOrder = 2
end

local function playCurrentAnimation()
    currentAnimation.paused = false
    currentAnimation.pausedTime = 0.0

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

        if GetGameTimer() - startedAt > 5000 then
            bridgeDebug("error", ("[pr_animateConfig] Timeout animDict: %s"):format(tostring(currentAnimation.dict)))
            debugAction("anim:play:timeout", {
                dict = currentAnimation.dict,
            }, "error")
            return false
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
        0,
        false,
        false,
        false
    )

    bridgeDebug("info", ("[pr_animateConfig] TaskPlayAnim dict=%s anim=%s flags=%s"):format(
        tostring(currentAnimation.dict),
        tostring(currentAnimation.anim),
        tostring(currentAnimation.flags)
    ))
    debugAction("anim:play:result", {
        dict = currentAnimation.dict,
        anim = currentAnimation.anim,
        flags = currentAnimation.flags,
        playing = IsEntityPlayingAnim(ped, currentAnimation.dict, currentAnimation.anim, 3),
        animTime = GetEntityAnimCurrentTime(ped, currentAnimation.dict, currentAnimation.anim),
    })

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
                and IsEntityPlayingAnim(ped, currentAnimation.dict, currentAnimation.anim, 3) == 1
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

    local playing = IsEntityPlayingAnim(ped, currentAnimation.dict, currentAnimation.anim, 3)
    if playing ~= 1 then
        debugAction("anim:pause:failed", {
            dict = currentAnimation.dict,
            anim = currentAnimation.anim,
            playing = playing,
        }, "warn")
        return false, 0.0
    end

    local animTime = GetEntityAnimCurrentTime(ped, currentAnimation.dict, currentAnimation.anim)
    currentAnimation.paused = true
    currentAnimation.pausedTime = animTime

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

local function forceOpenUi(source)
    debugAction("ui:open", {
        source = source or "unknown",
    })

    isOpen = true
    SetNuiFocus(true, true)
    if SetNuiFocusKeepInput then
        SetNuiFocusKeepInput(true)
    end
    startControlsThread()
    startEditorCamera(currentCameraTarget)
    sendVisible(true)
    bridgeDebug("info", ("[pr_animateConfig] openUi source=%s"):format(source or "unknown"))
end

local function openUi(source)
    if isOpen then
        forceOpenUi(source or "refresh")
        return
    end

    forceOpenUi(source or "open")
end

local function closeUi()
    if not isOpen then return end

    debugAction("ui:close", {})
    isOpen = false
    stopEditorCamera()
    resetAll()
    SetNuiFocus(false, false)
    if SetNuiFocusKeepInput then
        SetNuiFocusKeepInput(false)
    end
    sendVisible(false)
end

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
    end
    cb({ ok = true })
end)

RegisterNUICallback("playAnimation", function(data, cb)
    data = data or {}
    debugAction("nui:playAnimation", data)

    currentAnimation.dict = data.dict
    currentAnimation.anim = data.anim
    currentAnimation.flags = tonumber(data.flag) or 0
    currentAnimation.blendIn = tonumber(data.blendIn) or 8.0
    currentAnimation.blendOut = tonumber(data.blendOut) or 8.0
    currentAnimation.duration = tonumber(data.duration) or -1
    currentAnimation.playbackRate = tonumber(data.playbackRate) or 0.0
    currentAnimation.paused = false
    currentAnimation.pausedTime = 0.0

    cb({ ok = true })

    CreateThread(function()
        playCurrentAnimation()
    end)
end)

RegisterNUICallback("stopAnimation", function(_, cb)
    debugAction("nui:stopAnimation", {})
    currentAnimation.paused = false
    currentAnimation.pausedTime = 0.0
    ClearPedTasks(PlayerPedId())
    cb({ ok = true })
end)

RegisterNUICallback("pauseAnimation", function(_, cb)
    debugAction("nui:pauseAnimation", {})
    local ok, animTime = pauseCurrentAnimation()
    cb({
        ok = ok,
        animTime = animTime,
    })
end)

RegisterNUICallback("spawnProp", function(data, cb)
    data = data or {}
    debugAction("nui:spawnProp", data)

    local modelName = data.model
    if not modelName or modelName == "" then
        cb({ ok = false, error = "invalid args" })
        return
    end

    deletePropEntity()

    propData.boneId = tonumber(data.boneId) or 57005
    propData.rotOrder = tonumber(data.rotationOrder) or 2
    propData.offset = vectorFromData(data.offset, propData.offset)
    propData.rot = vectorFromData(data.rotation, propData.rot)

    local modelHash = GetHashKey(modelName)
    RequestModel(modelHash)

    local startedAt = GetGameTimer()

    while not HasModelLoaded(modelHash) do
        Wait(0)

        if GetGameTimer() - startedAt > 5000 then
            debugAction("prop:spawn:timeout", {
                model = modelName,
                modelHash = modelHash,
            }, "error")
            cb({ ok = false, error = "model load fail" })
            return
        end
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local spawnCoords = coords + (forward * 2.0)
    local entity = CreateObject(modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, false)

    if not entity or not DoesEntityExist(entity) then
        debugAction("prop:spawn:failed", {
            model = modelName,
            modelHash = modelHash,
        }, "error")
        cb({ ok = false, error = "spawn fail" })
        return
    end

    SetEntityHeading(entity, GetEntityHeading(ped))
    PlaceObjectOnGroundProperly(entity)
    SetModelAsNoLongerNeeded(modelHash)

    local netId = NetworkGetNetworkIdFromEntity(entity)
    if netId and netId ~= 0 then
        SetNetworkIdExistsOnAllMachines(netId, true)
        SetNetworkIdCanMigrate(netId, true)
    end

    propData.entity = entity
    propData.model = modelName

    local attached = attachEntityToPedBone()
    sendPropStatus(attached and "attached" or "none")
    debugAction("prop:spawn:result", {
        model = modelName,
        modelHash = modelHash,
        entity = entity,
        attached = attached,
    }, attached and "info" or "warn")

    cb({ ok = attached })
end)

RegisterNUICallback("deleteProp", function(_, cb)
    debugAction("nui:deleteProp", {})
    deletePropEntity()
    cb({ ok = true })
end)

RegisterNUICallback("updatePropOffsets", function(data, cb)
    data = data or {}
    debugAction("nui:updatePropOffsets", data)

    propData.boneId = tonumber(data.boneId) or propData.boneId or 57005
    propData.rotOrder = tonumber(data.rotationOrder) or propData.rotOrder or 2
    propData.offset = vectorFromData(data.offset, propData.offset)
    propData.rot = vectorFromData(data.rotation, propData.rot)

    if propData.entity and DoesEntityExist(propData.entity) then
        local attached = attachEntityToPedBone()
        debugAction("prop:update:result", {
            attached = attached,
            entity = propData.entity,
        }, attached and "info" or "warn")
    else
        debugAction("prop:update:stored", {
            hasEntity = false,
            boneId = propData.boneId,
            rotationOrder = propData.rotOrder,
        })
    end

    cb({ ok = true })
end)

RegisterNUICallback("changeCameraTarget", function(data, cb)
    data = data or {}
    debugAction("nui:changeCameraTarget", data)
    startEditorCamera(data.target or "waist")
    cb({ ok = true })
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

for i = 1, #disabledCallbacks do
    RegisterNUICallback(disabledCallbacks[i], function(_, cb)
        cb({
            ok = false,
            disabled = true,
            message = t("disabled"),
        })
    end)
end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    resetAll()
    stopEditorCamera()
    SetNuiFocus(false, false)
    if SetNuiFocusKeepInput then
        SetNuiFocusKeepInput(false)
    end
end)

exports("Open", openUi)
exports("Close", closeUi)
