const resourceName = typeof GetParentResourceName === "function"
    ? GetParentResourceName()
    : "pr_animateConfig";

const app = document.querySelector("#app");
let currentTranslations = {};
let currentDefaults = {};
let currentDefaultProp = {};
let currentAnimations = [];
let currentProps = [];
let currentBones = [];
let currentGizmoActive = false;

async function post(action, payload = {}) {
    try {
        const response = await fetch(`https://${resourceName}/${action}`, {
            method: "POST",
            headers: { "Content-Type": "application/json; charset=UTF-8" },
            body: JSON.stringify(payload),
        });

        return await response.json();
    } catch (error) {
        console.error(`[${resourceName}] NUI post failed:`, action, error);
        return null;
    }
}

function text(key, fallback = key) {
    return currentTranslations[key] || fallback;
}

function numberValue(value, fallback) {
    if (value === null || value === undefined || String(value).trim() === "") {
        return fallback;
    }

    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
}

function setValue(id, value) {
    const element = document.getElementById(id);
    if (element) element.value = value ?? "";
}

function luaString(value) {
    return String(value ?? "").replace(/\\/g, "\\\\").replace(/"/g, '\\"');
}

function fixed(value, decimals) {
    return Number(value || 0).toFixed(decimals);
}

function translate(translations) {
    currentTranslations = translations || {};

    document.querySelectorAll("[data-i18n]").forEach((element) => {
        const key = element.dataset.i18n;
        element.textContent = text(key, key);
    });

    document.querySelectorAll("[data-i18n-title]").forEach((element) => {
        const key = element.dataset.i18nTitle;
        element.title = text(key, key);
    });

    document.querySelectorAll("[data-icon='close']").forEach((element) => {
        element.textContent = text("closeIcon", "x");
    });
}

function fillSelect(select, rows, getLabel, getValue) {
    if (!select) return;

    select.innerHTML = "";
    rows.forEach((row, index) => {
        const option = document.createElement("option");
        option.value = getValue ? getValue(row, index) : String(index);
        option.textContent = getLabel(row, index);
        select.appendChild(option);
    });
}

function setupAnimationFields(defaults) {
    currentDefaults = defaults || {};
    setValue("animDict", currentDefaults.dict || "");
    setValue("animName", currentDefaults.name || "");
    setValue("animFlag", currentDefaults.flag ?? 0);
    setValue("blendIn", currentDefaults.blendIn ?? 8.0);
    setValue("blendOut", currentDefaults.blendOut ?? 8.0);
    setValue("duration", currentDefaults.duration ?? -1);
    setValue("playbackRate", currentDefaults.playbackRate ?? 0.0);
}

function setupAnimationPreset(animations) {
    currentAnimations = animations || [];
    const select = document.getElementById("animationPreset");
    if (!select) return;

    fillSelect(
        select,
        [{ labelId: "custom" }, ...currentAnimations],
        (row) => text(row.labelId, row.labelId),
        (_, index) => index === 0 ? "custom" : String(index - 1)
    );

    select.value = "custom";
    select.onchange = () => {
        if (select.value === "custom") return;

        const animation = currentAnimations[Number(select.value)];
        if (!animation) return;

        setValue("animDict", animation.dict || "");
        setValue("animName", animation.name || "");
        setValue("animFlag", animation.flag ?? 0);
        setValue("blendIn", animation.blendIn ?? currentDefaults.blendIn ?? 8.0);
        setValue("blendOut", animation.blendOut ?? currentDefaults.blendOut ?? 8.0);
        setValue("duration", animation.duration ?? currentDefaults.duration ?? -1);
        setValue("playbackRate", animation.playbackRate ?? currentDefaults.playbackRate ?? 0.0);
        addDebugLog(`nui:animationPreset ${animation.labelId || animation.name || select.value}`);
    };
}

function setupFlags(flags) {
    const container = document.getElementById("flagButtons");
    if (!container) return;

    container.innerHTML = "";
    (flags || []).forEach((flag) => {
        const button = document.createElement("button");
        button.type = "button";
        button.className = "small";
        button.dataset.value = flag.value;
        button.textContent = text(flag.labelId, flag.labelId);
        button.addEventListener("click", () => {
            setValue("animFlag", flag.value ?? 0);
            setValue("animationPreset", "custom");
        });
        container.appendChild(button);
    });
}

function setupPropFields(defaultProp) {
    currentDefaultProp = defaultProp || {};
    setValue("propModel", currentDefaultProp.model || "");
    setValue("boneId", currentDefaultProp.boneId || "");
    setValue("rotationOrder", currentDefaultProp.rotationOrder ?? 2);
    setValue("offsetX", currentDefaultProp.offset?.x ?? 0);
    setValue("offsetY", currentDefaultProp.offset?.y ?? 0);
    setValue("offsetZ", currentDefaultProp.offset?.z ?? 0);
    setValue("rotX", currentDefaultProp.rotation?.x ?? 0);
    setValue("rotY", currentDefaultProp.rotation?.y ?? 0);
    setValue("rotZ", currentDefaultProp.rotation?.z ?? 0);
}

function setupProps(props) {
    currentProps = props || [];
    const select = document.getElementById("propPreset");
    if (!select) return;

    fillSelect(
        select,
        [{ labelId: "custom" }, ...currentProps],
        (row) => text(row.labelId, row.labelId),
        (_, index) => index === 0 ? "custom" : String(index - 1)
    );

    select.value = "custom";
    select.onchange = () => {
        if (select.value === "custom") return;

        const prop = currentProps[Number(select.value)];
        if (!prop) return;

        setValue("propModel", prop.model || "");
        addDebugLog(`nui:propPreset ${prop.labelId || prop.model || select.value}`);
    };
}

function setupBones(bones) {
    currentBones = bones || [];
    const select = document.getElementById("bonePreset");
    if (!select) return;

    fillSelect(
        select,
        [{ labelId: "custom" }, ...currentBones],
        (row) => row.id ? `${text(row.labelId, row.labelId)} (${row.id})` : text(row.labelId, row.labelId),
        (_, index) => index === 0 ? "custom" : String(index - 1)
    );

    select.value = "custom";
    select.onchange = () => {
        if (select.value === "custom") return;

        const bone = currentBones[Number(select.value)];
        if (!bone) return;

        setValue("boneId", bone.id || "");
        addDebugLog(`nui:bonePreset ${bone.labelId || bone.id}`);
        applyPropOffsets("bonePreset");
    };
}

function setupSteps(nudgeSteps) {
    const posStep = document.getElementById("posStep");
    const rotStep = document.getElementById("rotStep");

    fillSelect(posStep, nudgeSteps?.position || [], (value) => String(value), (value) => String(value));
    fillSelect(rotStep, nudgeSteps?.rotation || [], (value) => `${value}°`, (value) => String(value));

    if (posStep && posStep.options.length > 0) posStep.selectedIndex = Math.min(2, posStep.options.length - 1);
    if (rotStep && rotStep.options.length > 0) rotStep.selectedIndex = Math.min(2, rotStep.options.length - 1);
}

function updateStatus() {
    const propStatus = document.getElementById("propStatus");
    if (propStatus) propStatus.textContent = text("noProp", "No prop");

    const gizmoState = document.getElementById("gizmoState");
    if (gizmoState) {
        gizmoState.textContent = currentGizmoActive ? text("gizmo", "Gizmo") : text("menu", "Menu");
        gizmoState.classList.toggle("is-live", currentGizmoActive);
    }
}

function updatePropStatus(status) {
    const propStatus = document.getElementById("propStatus");
    if (!propStatus) return;

    propStatus.textContent = status === "attached"
        ? text("propAttached", "Prop attached")
        : text("noProp", "No prop");
}

function addDebugLog(message) {
    const log = document.getElementById("debugLog");
    if (!log) return;

    const line = document.createElement("div");
    line.className = "debug-line info";
    line.textContent = `[${new Date().toLocaleTimeString()}] ${message}`;
    log.appendChild(line);
    log.scrollTop = log.scrollHeight;

    while (log.children.length > 80) {
        log.removeChild(log.firstChild);
    }
}

function debugPayload(action, payload) {
    addDebugLog(`${action} ${JSON.stringify(payload)}`);
}

async function postAndDebug(action, payload = {}) {
    debugPayload(`nui:${action}`, payload);
    const result = await post(action, payload);
    debugPayload(`client:${action}:result`, result || {});
    return result;
}

function showApp(payload) {
    translate(payload.translations || {});
    setupAnimationFields(payload.defaults || {});
    setupAnimationPreset(payload.animations || []);
    setupFlags(payload.flags || []);
    setupPropFields(payload.defaultProp || {});
    setupProps(payload.props || []);
    setupBones(payload.bones || []);
    setupSteps(payload.nudgeSteps || {});
    updateStatus();

    app.classList.remove("is-hidden");
    addDebugLog(text("opened", "Editor opened."));
    debugPayload("nui:setVisible", {
        animations: currentAnimations.length,
        props: currentProps.length,
        bones: currentBones.length,
    });
}

function hideApp() {
    app.classList.add("is-hidden");
}

function readAnimationPayload() {
    return {
        dict: document.getElementById("animDict")?.value || "",
        anim: document.getElementById("animName")?.value || "",
        flag: numberValue(document.getElementById("animFlag")?.value, 0),
        blendIn: numberValue(document.getElementById("blendIn")?.value, 8.0),
        blendOut: numberValue(document.getElementById("blendOut")?.value, 8.0),
        duration: numberValue(document.getElementById("duration")?.value, -1),
        playbackRate: numberValue(document.getElementById("playbackRate")?.value, 0.0),
    };
}

function readPropPayload() {
    return {
        model: document.getElementById("propModel")?.value || "",
        boneId: numberValue(document.getElementById("boneId")?.value, 57005),
        rotationOrder: numberValue(document.getElementById("rotationOrder")?.value, 2),
        offset: {
            x: numberValue(document.getElementById("offsetX")?.value, 0),
            y: numberValue(document.getElementById("offsetY")?.value, 0),
            z: numberValue(document.getElementById("offsetZ")?.value, 0),
        },
        rotation: {
            x: numberValue(document.getElementById("rotX")?.value, 0),
            y: numberValue(document.getElementById("rotY")?.value, 0),
            z: numberValue(document.getElementById("rotZ")?.value, 0),
        },
    };
}

function generateLuaConfig() {
    const anim = readAnimationPayload();
    const prop = readPropPayload();
    const output = document.getElementById("output");
    if (!output) return;

    output.value = `{
    dict = "${luaString(anim.dict)}",
    anim = "${luaString(anim.anim)}",
    flags = ${anim.flag},
    props = {
        {
            model = "${luaString(prop.model)}",
            bone = ${prop.boneId},
            pos = vec3(${fixed(prop.offset.x, 4)}, ${fixed(prop.offset.y, 4)}, ${fixed(prop.offset.z, 4)}),
            rot = vec3(${fixed(prop.rotation.x, 3)}, ${fixed(prop.rotation.y, 3)}, ${fixed(prop.rotation.z, 3)}),
            rotationOrder = ${prop.rotationOrder},
        },
    },
}`;
    addDebugLog("nui:generateConfig");
}

function ensureGeneratedConfig() {
    const output = document.getElementById("output");
    if (!output) return "";

    if (!output.value.trim()) {
        generateLuaConfig();
    }

    return output.value;
}

async function copyGeneratedConfig() {
    const output = document.getElementById("output");
    const value = ensureGeneratedConfig();
    let copied = false;

    if (!output || !value) {
        addDebugLog(text("copyFailed", "Copy failed."));
        return;
    }

    try {
        if (navigator.clipboard?.writeText) {
            await navigator.clipboard.writeText(value);
            copied = true;
        }
    } catch (error) {
        copied = false;
    }

    if (!copied) {
        try {
            output.focus();
            output.select();
            output.setSelectionRange(0, value.length);
            copied = document.execCommand("copy") === true;
        } catch (error) {
            copied = false;
        }
    }

    window.getSelection?.().removeAllRanges?.();
    addDebugLog(text(copied ? "copySuccess" : "copyFailed", copied ? "Copied." : "Copy failed."));
}

function applyPropOffsets(reason) {
    const payload = readPropPayload();
    payload.reason = reason || "change";
    return postAndDebug("updatePropOffsets", payload);
}

window.addEventListener("message", (event) => {
    const payload = event.data || {};

    if (payload.action === "setVisible") {
        if (payload.visible) {
            showApp(payload);
        } else {
            hideApp();
        }
    } else if (payload.action === "debugLog") {
        addDebugLog(payload.message || "");
    } else if (payload.action === "setGizmoState") {
        currentGizmoActive = payload.active === true;
        updateStatus();
    } else if (payload.action === "propStatus") {
        updatePropStatus(payload.status);
    } else if (payload.action === "updateOffsets") {
        if (payload.offset) {
            setValue("offsetX", Number(payload.offset.x || 0).toFixed(4));
            setValue("offsetY", Number(payload.offset.y || 0).toFixed(4));
            setValue("offsetZ", Number(payload.offset.z || 0).toFixed(4));
        }
        if (payload.rotation) {
            setValue("rotX", Number(payload.rotation.x || 0).toFixed(2));
            setValue("rotY", Number(payload.rotation.y || 0).toFixed(2));
            setValue("rotZ", Number(payload.rotation.z || 0).toFixed(2));
        }
    }
});

document.querySelectorAll("[data-action='close']").forEach((element) => {
    element.addEventListener("click", () => postAndDebug("close"));
});

document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && !currentGizmoActive) {
        postAndDebug("close", { reason: "escape" });
    }
});

document.querySelectorAll("[data-action='playAnimation']").forEach((element) => {
    element.addEventListener("click", () => postAndDebug("playAnimation", readAnimationPayload()));
});

document.querySelectorAll("[data-action='pauseAnimation']").forEach((element) => {
    element.addEventListener("click", () => postAndDebug("pauseAnimation"));
});

document.querySelectorAll("[data-action='stopAnimation']").forEach((element) => {
    element.addEventListener("click", () => postAndDebug("stopAnimation"));
});

document.querySelectorAll("[data-action='clearAll']").forEach((element) => {
    element.addEventListener("click", () => {
        setupAnimationFields({});
        postAndDebug("stopAnimation", { reason: "clearAll" });
    });
});

document.querySelectorAll("[data-action='spawnProp']").forEach((element) => {
    element.addEventListener("click", async () => {
        const result = await postAndDebug("spawnProp", readPropPayload());
        updatePropStatus(result && result.ok ? "attached" : "none");
    });
});

document.querySelectorAll("[data-action='deleteProp']").forEach((element) => {
    element.addEventListener("click", async () => {
        await postAndDebug("deleteProp");
        updatePropStatus("none");
    });
});

document.querySelectorAll("[data-action='toggleGizmo']").forEach((element) => {
    element.addEventListener("click", () => postAndDebug("toggleGizmo", { active: !currentGizmoActive }));
});

document.querySelectorAll("[data-action='captureGizmo']").forEach((element) => {
    element.addEventListener("click", () => postAndDebug("captureGizmo"));
});

document.querySelectorAll("[data-action='resetTransform']").forEach((element) => {
    element.addEventListener("click", () => {
        setupPropFields(currentDefaultProp);
        applyPropOffsets("resetTransform");
    });
});

document.querySelectorAll("[data-action='generate']").forEach((element) => {
    element.addEventListener("click", generateLuaConfig);
});

document.querySelectorAll("[data-action='copyLua']").forEach((element) => {
    element.addEventListener("click", copyGeneratedConfig);
});

document.querySelectorAll("[data-action='saveConfig']").forEach((element) => {
    element.addEventListener("click", async () => {
        const result = await postAndDebug("saveConfig", {
            animation: readAnimationPayload(),
            prop: readPropPayload(),
            lua: ensureGeneratedConfig(),
        });

        addDebugLog(text(result?.ok ? "saveSuccess" : "saveFailed", result?.ok ? "Config saved." : "Save failed."));
    });
});

document.querySelectorAll(".camera-target-btn").forEach((button) => {
    button.addEventListener("click", () => {
        document.querySelectorAll(".camera-target-btn").forEach((item) => item.classList.remove("active"));
        button.classList.add("active");
        postAndDebug("changeCameraTarget", { target: button.dataset.target });
    });
});

document.querySelectorAll(".axis-grid button").forEach((button) => {
    const label = button.dataset.dir === "1" ? "+" : "-";
    button.textContent = `${button.dataset.axis?.toUpperCase() || ""}${label}`;
});

document.querySelectorAll(".axis-grid button").forEach((button) => {
    button.addEventListener("click", () => {
        const group = button.closest(".axis-grid")?.dataset.group;
        const axis = button.dataset.axis;
        const dir = Number(button.dataset.dir || 0);
        const input = document.querySelector(`[data-axis-input='${group}.${axis}']`);
        const stepSelect = document.getElementById(group === "offset" ? "posStep" : "rotStep");
        const step = numberValue(stepSelect?.value, group === "offset" ? 0.01 : 1.0);

        if (!input) return;

        const next = numberValue(input.value, 0) + (step * dir);
        input.value = next.toFixed(group === "offset" ? 4 : 2);
        applyPropOffsets(`axis:${group}.${axis}`);
    });
});

["offsetX", "offsetY", "offsetZ", "rotX", "rotY", "rotZ", "boneId", "rotationOrder"].forEach((id) => {
    const element = document.getElementById(id);
    element?.addEventListener("input", () => applyPropOffsets(`input:${id}`));
    element?.addEventListener("change", () => applyPropOffsets(`change:${id}`));
});

document.getElementById("propModel")?.addEventListener("input", () => {
    setValue("propPreset", "custom");
    addDebugLog("nui:propModelChanged");
});

post("pageReady");
