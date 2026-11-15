local REPO_OWNER = "Pierremoraes-ofc"
local REPO_NAME = "pr_animateConfig"

if IsDuplicityVersion() and Config.VersionCheck then
    CreateThread(function()
        Wait(5000)

        if pr_lib and type(pr_lib.versionCheck) == "function" then
            pr_lib.versionCheck(("%s/%s"):format(REPO_OWNER, REPO_NAME))
        end
    end)
end
