RegisterNetEvent("pr_animateConfig:server:saveConfig", function(requestId, payload)
    local src = source
    local result = {
        ok = false,
        file = "saved_config.json",
    }

    if type(payload) ~= "table" then
        result.error = "invalid_payload"
        TriggerClientEvent("pr_animateConfig:client:saveConfigResult", src, requestId, result)
        return
    end

    payload.savedAt = os.date("!%Y-%m-%dT%H:%M:%SZ")

    local encoded = json.encode(payload, { indent = true })
    if not encoded then
        result.error = "encode_failed"
        TriggerClientEvent("pr_animateConfig:client:saveConfigResult", src, requestId, result)
        return
    end

    local saved = SaveResourceFile(GetCurrentResourceName(), result.file, encoded, -1)
    result.ok = saved == true or saved == 1
    result.bytes = #encoded

    if not result.ok then
        result.error = "save_failed"
    end

    TriggerClientEvent("pr_animateConfig:client:saveConfigResult", src, requestId, result)
end)
