local RESOURCE_NAME = GetCurrentResourceName()
local CATALOG_FILE = "saved_config.json"
local catalog = {
    version = 2,
    animations = {},
}

local function sanitizeId(value)
    local id = tostring(value or ""):lower()
    id = id:gsub("%s+", "_"):gsub("[^%w_-]", ""):sub(1, 64)
    return id
end

local function numberOr(value, fallback)
    local parsed = tonumber(value)
    if parsed == nil then return fallback end
    return parsed
end

local function normalizeVector(value)
    value = type(value) == "table" and value or {}
    return {
        x = numberOr(value.x, 0.0),
        y = numberOr(value.y, 0.0),
        z = numberOr(value.z, 0.0),
    }
end

local function normalizeProp(value)
    if type(value) ~= "table" or type(value.model) ~= "string" or value.model == "" then return nil end

    return {
        model = value.model,
        boneId = math.floor(numberOr(value.boneId or value.bone, 57005)),
        rotationOrder = math.floor(numberOr(value.rotationOrder, 2)),
        offset = normalizeVector(value.offset or value.pos),
        rotation = normalizeVector(value.rotation or value.rot),
    }
end

local function normalizeEntry(id, payload, existing)
    local animation = type(payload.animation) == "table" and payload.animation or payload
    if type(animation.dict) ~= "string" or animation.dict == ""
        or type(animation.anim) ~= "string" or animation.anim == ""
    then
        return nil, "invalid_animation"
    end

    local propsSource = payload.props
    if type(propsSource) ~= "table" then
        propsSource = payload.prop and { payload.prop } or {}
    end

    local props = {}
    for i = 1, #propsSource do
        local prop = normalizeProp(propsSource[i])
        if prop then props[#props + 1] = prop end
    end

    local now = os.date("!%Y-%m-%dT%H:%M:%SZ")
    local label = payload.label
    if type(label) ~= "string" or #label > 400 or not utf8.len(label) or label == "" then label = nil end
    return {
        id = id,
        label = label,
        animation = {
            dict = animation.dict,
            anim = animation.anim,
            flag = math.floor(numberOr(animation.flag or animation.flags, 0)),
            blendIn = numberOr(animation.blendIn, 8.0),
            blendOut = numberOr(animation.blendOut, 8.0),
            duration = math.floor(numberOr(animation.duration, -1)),
            playbackRate = numberOr(animation.playbackRate, 1.0),
        },
        props = props,
        createdAt = existing and existing.createdAt or now,
        updatedAt = now,
    }
end

local function saveCatalog()
    local encoded = json.encode(catalog, { indent = true })
    if not encoded then return false, 0 end

    local saved = SaveResourceFile(RESOURCE_NAME, CATALOG_FILE, encoded, -1)
    return saved == true or saved == 1, #encoded
end

local function deriveLegacyId(raw)
    if raw.id then return sanitizeId(raw.id) end
    local animation = type(raw.animation) == "table" and raw.animation or {}
    if animation.dict == "mp_player_intdrink" and animation.anim == "loop_bottle" then
        return "garrafa_dagua"
    end
    return sanitizeId((animation.dict or "animation") .. "_" .. (animation.anim or "saved"))
end

local function loadCatalog()
    local rawText = LoadResourceFile(RESOURCE_NAME, CATALOG_FILE)
    if not rawText or rawText == "" then return end

    local ok, decoded = pcall(json.decode, rawText)
    if not ok or type(decoded) ~= "table" then
        print(("^1[%s] %s invalido; mantendo catalogo vazio.^7"):format(RESOURCE_NAME, CATALOG_FILE))
        return
    end

    if decoded.version == 2 and type(decoded.animations) == "table" then
        catalog = decoded
        catalog.version = 2
        catalog.animations = catalog.animations or {}
        return
    end

    if type(decoded.animation) == "table" then
        local id = deriveLegacyId(decoded)
        if id == "" then id = "legacy_animation" end
        local entry = normalizeEntry(id, decoded)
        if entry then
            catalog.animations[id] = entry
            saveCatalog()
            print(("^2[%s] Configuracao antiga migrada para o ID '%s'.^7"):format(RESOURCE_NAME, id))
        end
    end
end

local function sendCatalog(target)
    TriggerClientEvent("pr_animateConfig:client:setCatalog", target, catalog.animations)
end

loadCatalog()

RegisterNetEvent("pr_animateConfig:server:requestCatalog", function()
    sendCatalog(source)
end)

RegisterNetEvent("pr_animateConfig:server:saveConfig", function(requestId, payload)
    local src = source
    local result = {
        ok = false,
        file = CATALOG_FILE,
    }

    if type(payload) ~= "table" then
        result.error = "invalid_payload"
        TriggerClientEvent("pr_animateConfig:client:saveConfigResult", src, requestId, result)
        return
    end

    local id = sanitizeId(payload.id)
    if id == "" then
        result.error = "invalid_id"
        TriggerClientEvent("pr_animateConfig:client:saveConfigResult", src, requestId, result)
        return
    end

    local existed = catalog.animations[id] ~= nil
    local entry, errorCode = normalizeEntry(id, payload, catalog.animations[id])
    if not entry then
        result.error = errorCode or "invalid_entry"
        TriggerClientEvent("pr_animateConfig:client:saveConfigResult", src, requestId, result)
        return
    end

    local previous = catalog.animations[id]
    catalog.animations[id] = entry
    local saved, bytes = saveCatalog()
    if not saved then
        catalog.animations[id] = previous
        result.error = "save_failed"
        TriggerClientEvent("pr_animateConfig:client:saveConfigResult", src, requestId, result)
        return
    end

    result.ok = true
    result.id = id
    result.created = not existed
    result.bytes = bytes
    TriggerClientEvent("pr_animateConfig:client:saveConfigResult", src, requestId, result)
    TriggerClientEvent("pr_animateConfig:client:setCatalog", -1, catalog.animations)
end)

exports("Get", function(id)
    return catalog.animations[sanitizeId(id)]
end)

exports("GetAll", function()
    return catalog.animations
end)

exports("Play", function(playerId, id, durationSeconds)
    local target = tonumber(playerId)
    local animationId = sanitizeId(id)
    if not target or not catalog.animations[animationId] then return false end

    TriggerClientEvent("pr_animateConfig:client:playSaved", target, animationId, durationSeconds)
    return true
end)

exports("Stop", function(playerId)
    local target = tonumber(playerId)
    if not target then return false end
    TriggerClientEvent("pr_animateConfig:client:stopSaved", target)
    return true
end)