import { formatExport } from "./formats.js";

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
let currentTimelineDuration = 0;
let timelineDragging = false;
let timelineSeekTimer;
let timelinePhase = 0;
let timelinePaused = false;
let timelineClip;
let pendingSeek = Promise.resolve();
let seekRevision = 0;
let editorProps = [];
let selectedId;
let maxProps = 8;
let propRevision = 0;
let exportRevision = 0;
let viewGeneration = 0;
let animationBusy = false;
let testActive = false;
let pickerActive = false;
let draftEdited = false;
let draftTimer;
let catalog = {};
const pendingTransforms = new Map();
const markerButtons = new Map();
let lastMarkers = [];
const historyKey = "pr_animateConfig.history.v1";
const draftKey = "pr_animateConfig.last.v1";
const field = (id) => document.getElementById(id);
const actionButton = (action) => document.querySelector("[data-action='" + action + "']");
let playbackRate = 1;
const playbackInput = document.getElementById("playbackRate");
const playbackButtons = document.querySelectorAll("[data-playback-rate]");

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



function formatTimelineTime(seconds) {
    const safe = Math.max(0, Number(seconds) || 0);
    const centiseconds = Math.round(safe * 100);
    const minutes = Math.floor(centiseconds / 6000);
    const remaining = (centiseconds % 6000) / 100;
    return `${String(minutes).padStart(2, "0")}:${remaining.toFixed(2).padStart(5, "0")}`;
}

function renderTimeline(phase, duration, forceSlider = false) {
    const normalized = Math.max(0, Math.min(1, Number(phase) || 0));
    timelinePhase = normalized;
    currentTimelineDuration = Math.max(0, Number(duration) || 0);
    const canSeek = currentTimelineDuration > 0 && !animationBusy;
    for (const id of ["animationTimeline", "previousFrame", "nextFrame"]) field(id).disabled = !canSeek;

    const slider = document.getElementById("animationTimeline");
    if (slider && (!timelineDragging || forceSlider)) {
        slider.value = String(Math.round(normalized * 1000));
    }

    const output = document.getElementById("timelineValue");
    if (output) {
        output.textContent = `${formatTimelineTime(normalized * currentTimelineDuration)} / ${formatTimelineTime(currentTimelineDuration)}`;
    }
}

function seekTimeline(phase, final = false) {
    const normalized = Math.max(0, Math.min(1, Number(phase) || 0));
    renderTimeline(normalized, currentTimelineDuration, true);

    if (timelineSeekTimer) {
        clearTimeout(timelineSeekTimer);
        timelineSeekTimer = null;
    }

    const revision = ++seekRevision;
    const send = () => {
        pendingSeek = pendingSeek.then(async () => {
            if (revision !== seekRevision) return;
            const result = await post("seekAnimation", { phase: normalized });
            if (revision !== seekRevision) return;
            if (report(result)) {
                timelinePaused = true;
                if (final) rememberDraft();
            }
        });
    };
    if (final) {
        send();
    } else {
        timelineSeekTimer = setTimeout(send, 40);
    }
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

function setPlaybackRate(value, apply = false) {
    const decimal = String(value ?? "").trim().replace(",", ".");
    const parsed = Number(decimal);
    playbackRate = parsed > 0 && parsed <= 3.4028234e38 ? parsed : apply ? playbackRate : 1;
    playbackInput.value = playbackRate;
    for (const button of playbackButtons) {
        button.setAttribute("aria-pressed", String(Number(button.dataset.playbackRate) === playbackRate));
    }
    if (apply) {
        exportRevision++;
        post("setPlaybackRate", { rate: playbackRate });
        queueDraft();
    }
}

function setupAnimationFields(defaults) {
    currentDefaults = defaults || {};
    setValue("animDict", currentDefaults.dict || "");
    setValue("animName", currentDefaults.name || "");
    setValue("animFlag", currentDefaults.flag ?? 0);
    setValue("blendIn", currentDefaults.blendIn ?? 8.0);
    setValue("blendOut", currentDefaults.blendOut ?? 8.0);
    setValue("duration", currentDefaults.duration ?? -1);
    setPlaybackRate(currentDefaults.playbackRate);
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
        setPlaybackRate(animation.playbackRate ?? currentDefaults.playbackRate);
        const idInput = document.getElementById("animationId");
        if (idInput && !idInput.value.trim()) {
            idInput.value = normalizeAnimationId(animation.labelId || animation.name || "animation");
        }
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

function setupPropFields(prop) {
    setValue("propModel", prop.model || "");
    setValue("boneId", prop.boneId ?? 57005);
    setValue("rotationOrder", prop.rotationOrder ?? 2);
    for (const axis of ["x", "y", "z"]) {
        setValue("offset" + axis.toUpperCase(), prop.offset?.[axis] ?? 0);
        setValue("rot" + axis.toUpperCase(), prop.rotation?.[axis] ?? 0);
    }
    syncBoneList();
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

function boneLabel(bone) {
    const label = text(bone.labelId);
    return bone.finger ? label + " " + bone.segment + " · " + text(bone.group + "Bones") : label;
}

function folded(value) {
    return value.toLowerCase().normalize("NFD").replace(/\p{M}/gu, "");
}

function matchesBone(bone) {
    const group = field("boneRegion").value;
    if (!(group === "all" || group === bone.group || (group === "body" && !bone.finger))) return false;
    const query = folded(field("boneSearch").value.trim());
    return !query || folded(boneLabel(bone)).includes(query) || String(bone.id).includes(query)
        || ("0x" + bone.id.toString(16)).includes(query);
}

function syncBoneList() {
    const bones = currentBones.filter(matchesBone);
    fillSelect(field("bonePreset"), [{ labelId: "custom" }, ...bones],
        (bone) => bone.id === undefined ? text("custom") : boneLabel(bone) + " (" + bone.id + ")",
        (bone) => String(bone.id ?? ""));
    const current = Number(field("boneId").value);
    setValue("bonePreset", bones.some((bone) => bone.id === current) ? current : "");
}

function setupBones(bones) {
    currentBones = bones;
    syncBoneList();
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

function updatePropControls() {
    const prop = editorProps.find((item) => item.id === selectedId);
    field("propStatus").textContent = prop ? editorProps.length + " / " + maxProps + " " + text("attachedProps") : text("noProp");
    field("attachedProp").disabled = !prop || currentGizmoActive;
    field("replaceProp").disabled = !prop || currentGizmoActive;
    field("togglePropVisibility").disabled = !prop || currentGizmoActive;
    field("togglePropVisibility").textContent = text(prop?.visible === false ? "showProp" : "hideProp");
    actionButton("spawnProp").disabled = editorProps.length >= maxProps || currentGizmoActive;
    actionButton("deleteProp").disabled = !prop || currentGizmoActive;
    actionButton("toggleGizmo").disabled = !prop?.visible || currentGizmoActive;
    actionButton("captureGizmo").disabled = !prop?.visible || currentGizmoActive;
}

function receiveProps(payload) {
    editorProps = Array.isArray(payload.props) ? payload.props : [];
    selectedId = payload.selectedId;
    const current = editorProps.find((item) => item.id === selectedId);
    fillSelect(field("attachedProp"), editorProps.length ? editorProps : [{ model: text("noProp") }],
        (item, index) => item.id ? (index + 1) + ". " + item.model + (item.visible ? "" : " · " + text("hiddenProp")) : item.model,
        (item) => String(item.id ?? ""));
    setValue("attachedProp", selectedId);
    setupPropFields(current || currentDefaultProp);
    setValue("propPreset", "custom");
    updatePropControls();
    renderBoneMarkers(lastMarkers);
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
    maxProps = payload.maxProps || 8;
    currentDefaultProp = payload.defaultProp || {};
    draftEdited = false;
    timelineDragging = false;
    timelinePaused = false;
    timelineClip = undefined;
    currentGizmoActive = false;
    for (const id of ["animationId", "animationLabel", "output", "boneSearch"]) setValue(id, "");
    setValue("boneRegion", "body");
    setTestMode(false);
    setPickerUi(false);
    writeScene({});
    for (const id of ["editorFeedback", "propFeedback", "exportFeedback"]) feedback("", false, id);
    setupProps(payload.props || []);
    setupBones(payload.bones || []);
    setupSteps(payload.nudgeSteps || {});
    updateStatus();
    receiveProps({ props: [] });
    setAnimationBusy(false);
    renderTimeline(0, 0, true);
    renderHistory();

    app.classList.remove("is-hidden");
    addDebugLog(text("opened", "Editor opened."));
    debugPayload("nui:setVisible", {
        animations: currentAnimations.length,
        props: currentProps.length,
        bones: currentBones.length,
    });
}

function hideApp() {
    if (draftEdited) rememberDraft();
    clearTimeout(timelineSeekTimer);
    clearTimeout(draftTimer);
    seekRevision++;
    exportRevision++;
    viewGeneration++;
    pendingTransforms.clear();
    setPickerUi(false);
    app.classList.add("is-hidden");
}

function normalizeAnimationId(value) {
    return String(value || "")
        .trim()
        .toLowerCase()
        .replace(/\s+/g, "_")
        .replace(/[^a-z0-9_-]/g, "")
        .slice(0, 64);
}



function readAnimationPayload() {
    return {
        dict: field("animDict").value.trim(),
        anim: field("animName").value.trim(),
        flag: Math.trunc(numberValue(field("animFlag").value, 0)),
        blendIn: numberValue(document.getElementById("blendIn")?.value, 8.0),
        blendOut: numberValue(document.getElementById("blendOut")?.value, 8.0),
        duration: numberValue(document.getElementById("duration")?.value, -1),
        playbackRate,
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

function feedback(message, error = false, id = "editorFeedback") {
    const output = field(id);
    output.textContent = message;
    output.classList.toggle("is-error", error);
}

function report(result, output) {
    if (result?.ok) return true;
    if (result?.error !== "cancelled") feedback(text(result?.error, text("editorError")), true, output);
    return false;
}

function scenePayload() {
    const hour = field("sceneHour").value;
    return {
        backdrop: Boolean(field("sceneBackdrop").value),
        preset: field("sceneBackdrop").value,
        color: field("sceneColor").value,
        hour: hour === "" ? undefined : Number(hour),
        weather: field("sceneWeather").value,
    };
}

function writeScene(scene) {
    setValue("sceneBackdrop", scene.preset ?? (scene.backdrop ? "custom" : ""));
    setValue("sceneColor", scene.color || "#24c848");
    setValue("sceneHour", scene.hour);
    setValue("sceneWeather", scene.weather);
}

function snapshot() {
    const animation = readAnimationPayload();
    const sameClip = animation.dict === timelineClip?.dict && animation.anim === timelineClip?.anim;
    return {
        id: normalizeAnimationId(field("animationId").value),
        label: field("animationLabel").value.trim(),
        animation,
        props: editorProps.map(({ id, ...prop }) => prop),
        selectedIndex: editorProps.findIndex(({ id }) => id === selectedId) + 1,
        phase: sameClip ? timelinePhase : 0,
        paused: sameClip && (timelinePaused || timelinePhase > 0),
        scene: scenePayload(),
    };
}

function readStorage(key, fallback) {
    try { return JSON.parse(localStorage.getItem(key)) ?? fallback; }
    catch { return fallback; }
}

function writeStorage(key, data) {
    try { localStorage.setItem(key, JSON.stringify(data)); }
    catch { /* Keep editing available when local storage is disabled. */ }
}

function rememberDraft() {
    if (app.classList.contains("is-hidden")) return;
    draftEdited = true;
    clearTimeout(draftTimer);
    writeStorage(draftKey, snapshot());
    field("restoreLast").disabled = !readStorage(draftKey, null);
}

function queueDraft() {
    draftEdited = true;
    clearTimeout(draftTimer);
    draftTimer = setTimeout(rememberDraft, 200);
}

function recentEntries() {
    const entries = readStorage(historyKey, []);
    return Array.isArray(entries) ? entries.filter((entry) => entry?.draft?.animation) : [];
}

function addHistory(data) {
    const key = data.id || data.animation.dict + "/" + data.animation.anim;
    const entries = recentEntries().filter((entry) => entry.key !== key);
    writeStorage(historyKey, [{ key, draft: data }, ...entries].slice(0, 20));
    rememberDraft();
    renderHistory();
}

function renderHistory() {
    const entries = Object.entries(catalog).sort(([a], [b]) => a.localeCompare(b));
    fillSelect(field("savedAnimation"), [
        { label: text("chooseSaved"), value: "" },
        ...recentEntries().map(({ draft }, index) => ({
            label: text("recent") + " · " + (draft.label || draft.id || draft.animation.anim),
            value: "local:" + index,
        })),
        ...entries.map(([id, item]) => ({ label: text("catalog") + " · " + (item.label || id), value: "server:" + id })),
    ], (entry) => entry.label, (entry) => entry.value);
    field("restoreLast").disabled = !readStorage(draftKey, null);
    field("restoreSaved").disabled = true;
}

async function restoreDraft(draft) {
    if (!draft || animationBusy) return;
    const generation = viewGeneration;
    setAnimationBusy(true);
    await finishSeek();
    if (generation !== viewGeneration) return;
    const scene = draft.scene || scenePayload();
    const result = await postAndDebug("restoreSnapshot", {
        ...draft, scene, props: Array.isArray(draft.props) ? draft.props : [],
    });
    if (generation !== viewGeneration) return;
    setAnimationBusy(false);
    if (!report(result)) return;

    const animation = draft.animation || {};
    setValue("animationId", draft.id);
    setValue("animationLabel", draft.label);
    setValue("animationPreset", "custom");
    setValue("animDict", animation.dict);
    setValue("animName", animation.anim);
    setValue("animFlag", animation.flag ?? 0);
    setValue("blendIn", animation.blendIn ?? 8);
    setValue("blendOut", animation.blendOut ?? -8);
    setValue("duration", animation.duration ?? -1);
    setPlaybackRate(animation.playbackRate);
    writeScene(scene);
    setValue("output", "");
    if (result.playbackError) report({ error: result.playbackError });
    rememberDraft();
}

async function generateConfig() {
    const revision = ++exportRevision;
    await Promise.all(pendingTransforms.values());
    if (revision !== exportRevision) return "";
    const draft = snapshot();
    const format = field("exportFormat").value;
    const selectedOnly = field("exportScope").value === "selected";
    const selected = editorProps.filter((prop) => !selectedOnly || prop.id === selectedId);
    const props = selected.map(({ id, visible, ...prop }) => prop);
    setValue("output", "");
    feedback("", false, "exportFeedback");
    if (!props.length && (selectedOnly || format === "values" || format === "native")) {
        feedback(text("noProp"), true, "exportFeedback");
        return "";
    }

    const anim = draft.animation;
    if (format === "scully" && (!draft.id || !anim.dict || !anim.anim)) {
        feedback(text("scullyRequired"), true, "exportFeedback");
        return "";
    }

    let rotations = [];
    if (format === "scully" && props.length) {
        const result = await post("scullyRotations", { ids: selected.map((prop) => prop.id) });
        if (revision !== exportRevision || !report(result, "exportFeedback")) return "";
        rotations = result.rotations;
    }

    const output = formatExport(format, draft, props, rotations);
    setValue("output", output);
    if (format === "scully") {
        const file = text(props.length ? "scullyPropFile" : "scullyGeneralFile");
        const approximated = ![0, 1, 50, 51].includes(anim.flag) || anim.playbackRate !== 1;
        feedback(file + (approximated ? " " + text("scullyMapping") : ""), false, "exportFeedback");
    }
    addHistory(draft);
    return output;
}

async function copyGeneratedConfig() {
    const output = document.getElementById("output");
    const value = await generateConfig();
    let copied = false;

    if (!output || !value) {
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
    if (copied) {
        const help = field("exportFeedback").textContent;
        feedback((help ? help + " " : "") + text("copySuccess"), false, "exportFeedback");
    } else feedback(text("copyFailed"), true, "exportFeedback");
}

async function applyPropOffsets(reason) {
    if (!selectedId || currentGizmoActive) return;
    const id = selectedId;
    const payload = {
        ...readPropPayload(), id,
        revision: ++propRevision,
        preserveRotation: field("preserveRotation").checked && reason !== "resetTransform",
    };
    exportRevision++;
    const task = post("updatePropOffsets", payload).then((result) => {
        if (pendingTransforms.get(id) !== task) return;
        const index = editorProps.findIndex((prop) => prop.id === id);
        if (index < 0) return;
        if (!report(result, "propFeedback")) {
            if (selectedId === id && ["bone", "rotationOrder"].includes(reason)) setupPropFields(editorProps[index]);
            return;
        }
        editorProps[index] = {
            ...editorProps[index], boneId: payload.boneId, offset: payload.offset,
            rotation: result.rotation, rotationOrder: result.rotationOrder,
        };
        if (selectedId === id && reason === "rotationOrder") {
            for (const axis of ["x", "y", "z"]) setValue("rot" + axis.toUpperCase(), result.rotation[axis].toFixed(5));
        }
        feedback("", false, "propFeedback");
        renderBoneMarkers(lastMarkers);
        rememberDraft();
    }).finally(() => {
        if (pendingTransforms.get(id) === task) pendingTransforms.delete(id);
    });
    pendingTransforms.set(id, task);
    await task;
}

function setTestMode(active) {
    testActive = active;
    app.classList.toggle("is-testing", active);
    field("testHint").classList.toggle("is-hidden", !active);
    if (active) setPickerUi(false);
}

function setPickerUi(active) {
    pickerActive = active;
    field("pickBone").setAttribute("aria-pressed", String(active));
    if (!active) renderBoneMarkers([]);
}

async function togglePicker(active) {
    setPickerUi(active);
    const result = await post("setBonePicker", { active, group: field("boneRegion").value });
    if (!report(result, "propFeedback")) setPickerUi(false);
}

async function chooseBone(id) {
    setValue("boneId", id);
    syncBoneList();
    await applyPropOffsets("bone");
    if (pickerActive) await togglePicker(false);
}

function renderBoneMarkers(markers) {
    lastMarkers = markers;
    const visible = new Set();
    if (pickerActive && !currentGizmoActive) {
        for (const [index, marker] of markers.entries()) {
            const bone = currentBones.find(({ id }) => id === marker.id);
            if (!bone || !matchesBone(bone)) continue;
            visible.add(marker.id);
            let button = markerButtons.get(marker.id);
            if (!button) {
                button = document.createElement("button");
                button.type = "button";
                button.className = bone.finger ? "bone-marker is-finger" : "bone-marker";
                button.title = boneLabel(bone) + " (" + bone.id + ")";
                button.setAttribute("aria-label", button.title);
                button.addEventListener("click", () => chooseBone(bone.id));
                field("boneOverlay").appendChild(button);
                markerButtons.set(marker.id, button);
            }
            button.style.left = marker.x * 100 + "%";
            button.style.top = marker.y * 100 + "%";
            button.style.zIndex = String(index + 1);
            button.classList.toggle("is-selected", Number(field("boneId").value) === marker.id);
        }
    }
    for (const [id, button] of markerButtons) {
        if (!visible.has(id)) {
            button.remove();
            markerButtons.delete(id);
        }
    }
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
    } else if (payload.action === "animationTimeline" && !app.classList.contains("is-hidden")) {
        timelineClip = { dict: payload.dict, anim: payload.anim };
        timelinePaused = payload.paused === true;
        if (!timelineDragging) renderTimeline(payload.phase, payload.durationSeconds);
    } else if (payload.action === "setGizmoState") {
        currentGizmoActive = payload.active === true;
        updateStatus();
        updatePropControls();
        if (currentGizmoActive) setPickerUi(false);
    } else if (payload.action === "editorProps") {
        receiveProps(payload);
        exportRevision++;
        if (payload.changed) rememberDraft();
    } else if (payload.action === "boneMarkers" && (!payload.group || payload.group === field("boneRegion").value)) {
        renderBoneMarkers(Array.isArray(payload.markers) ? payload.markers : []);
    } else if (payload.action === "testMode") {
        setTestMode(payload.active === true);
    } else if (payload.action === "updateOffsets" && payload.id === selectedId) {
        const prop = editorProps.find((item) => item.id === selectedId);
        if (prop) {
            prop.offset = payload.offset;
            prop.rotation = payload.rotation;
            setupPropFields(prop);
        }
    }
});

actionButton("close").onclick = () => postAndDebug("close");
document.addEventListener("keydown", (event) => {
    if (event.key !== "Escape" || currentGizmoActive || testActive || app.classList.contains("is-hidden")) return;
    if (pickerActive) togglePicker(false);
    else postAndDebug("close");
});

for (const button of playbackButtons) {
    button.addEventListener("click", () => setPlaybackRate(button.dataset.playbackRate, true));
}
playbackInput.addEventListener("change", () => setPlaybackRate(playbackInput.value, true));
playbackInput.addEventListener("keydown", (event) => {
    if (event.key === "Enter") playbackInput.blur();
});

const animationTimeline = field("animationTimeline");
animationTimeline.addEventListener("pointerdown", () => { timelineDragging = true; });
animationTimeline.addEventListener("input", () => seekTimeline(Number(animationTimeline.value) / 1000));
animationTimeline.addEventListener("change", () => seekTimeline(Number(animationTimeline.value) / 1000, true));
animationTimeline.addEventListener("pointerup", () => { timelineDragging = false; });
animationTimeline.addEventListener("pointercancel", () => { timelineDragging = false; });

function finishSeek() {
    clearTimeout(timelineSeekTimer);
    return pendingSeek;
}

function setAnimationBusy(busy) {
    animationBusy = busy;
    actionButton("playAnimation").disabled = busy;
    actionButton("pauseAnimation").disabled = busy;
    field("testAnimation").disabled = busy;
    renderTimeline(timelinePhase, currentTimelineDuration);
}

async function playEditor(action) {
    if (animationBusy) return;
    const generation = viewGeneration;
    setAnimationBusy(true);
    feedback("");
    await finishSeek();
    if (generation !== viewGeneration) return;
    const result = await postAndDebug(action, readAnimationPayload());
    if (generation !== viewGeneration) return;
    setAnimationBusy(false);
    if (report(result)) {
        timelinePaused = false;
        rememberDraft();
    }
}

field("previousFrame").onclick = () => seekTimeline(timelinePhase - 0.05 / currentTimelineDuration, true);
field("nextFrame").onclick = () => seekTimeline(timelinePhase + 0.05 / currentTimelineDuration, true);
field("testAnimation").onclick = () => playEditor("testAnimation");
actionButton("playAnimation").onclick = () => playEditor("playAnimation");
actionButton("pauseAnimation").onclick = async () => {
    await finishSeek();
    if (report(await postAndDebug("pauseAnimation"))) rememberDraft();
};
actionButton("stopAnimation").onclick = async () => {
    await finishSeek();
    if (report(await postAndDebug("stopAnimation"))) rememberDraft();
};
actionButton("clearAll").onclick = async () => {
    await finishSeek();
    if (!report(await postAndDebug("stopAnimation"))) return;
    setupAnimationFields({});
    rememberDraft();
};

async function propAction(action, payload) {
    await Promise.all(pendingTransforms.values());
    const result = await postAndDebug(action, payload);
    if (report(result, "propFeedback")) feedback("", false, "propFeedback");
    return result;
}

actionButton("spawnProp").onclick = () => propAction("spawnProp", readPropPayload());
field("replaceProp").onclick = () => propAction("spawnProp", { ...readPropPayload(), id: selectedId, replace: true });
field("togglePropVisibility").onclick = () => propAction("togglePropVisibility", { id: selectedId });
actionButton("deleteProp").onclick = () => propAction("deleteProp", { id: selectedId });
field("attachedProp").onchange = (event) => propAction("selectProp", { id: Number(event.target.value) });
actionButton("captureGizmo").onclick = () => propAction("captureGizmo");
actionButton("toggleGizmo").onclick = () => propAction("toggleGizmo");
actionButton("resetTransform").onclick = () => {
    setupPropFields({ ...readPropPayload(), offset: currentDefaultProp.offset, rotation: currentDefaultProp.rotation });
    applyPropOffsets("resetTransform");
};

actionButton("generate").onclick = generateConfig;
actionButton("copyLua").onclick = copyGeneratedConfig;
actionButton("saveConfig").onclick = async () => {
    await Promise.all(pendingTransforms.values());
    const draft = snapshot();
    if (!draft.id) {
        field("animationId").focus();
        return feedback(text("animationIdRequired"), true, "exportFeedback");
    }
    const { id, label, animation, props } = draft;
    const result = await postAndDebug("saveConfig", { id, label, animation, props });
    if (report(result, "exportFeedback")) {
        catalog[id] = { id, label, animation, props };
        feedback(text("saveSuccess"), false, "exportFeedback");
        addHistory(draft);
    }
};

field("bonePreset").onchange = (event) => {
    if (event.target.value !== "") chooseBone(Number(event.target.value));
};
field("boneSearch").oninput = () => {
    syncBoneList();
    renderBoneMarkers(lastMarkers);
};
field("boneRegion").onchange = () => {
    syncBoneList();
    renderBoneMarkers(lastMarkers);
    if (pickerActive) togglePicker(true);
};
field("pickBone").onclick = () => togglePicker(!pickerActive);

field("restoreLast").onclick = () => restoreDraft(readStorage(draftKey, null));
field("refreshCatalog").onclick = async () => {
    const result = await post("getCatalog");
    if (report(result)) {
        catalog = result.animations || {};
        renderHistory();
    }
};
field("savedAnimation").onchange = () => { field("restoreSaved").disabled = !field("savedAnimation").value; };
field("restoreSaved").onclick = () => {
    const [kind, id] = field("savedAnimation").value.split(":");
    if (kind === "local") restoreDraft(recentEntries()[Number(id)]?.draft);
    if (kind === "server") restoreDraft(catalog[id]);
};

for (const id of ["sceneBackdrop", "sceneColor", "sceneHour", "sceneWeather"]) {
    field(id).addEventListener("input", async () => {
        if (id === "sceneBackdrop" && field(id).value.startsWith("#")) setValue("sceneColor", field(id).value);
        if (id === "sceneColor") setValue("sceneBackdrop", "custom");
        if (report(await post("setScene", scenePayload()))) rememberDraft();
    });
}

for (const id of ["exportFormat", "exportScope"]) {
    field(id).onchange = () => {
        exportRevision++;
        setValue("output", "");
        feedback("", false, "exportFeedback");
    };
}

app.addEventListener("input", (event) => {
    if (["output", "animationTimeline", "boneSearch", "boneRegion", "savedAnimation", "exportFormat", "exportScope"].includes(event.target.id)) return;
    exportRevision++;
    queueDraft();
});

document.querySelectorAll(".camera-target-btn").forEach((button) => {
    button.addEventListener("click", () => {
        document.querySelectorAll(".camera-target-btn").forEach((item) => item.classList.remove("active"));
        button.classList.add("active");
        const target = button.dataset.target;
        if (target.endsWith("Hand")) {
            setValue("boneRegion", target);
            field("boneRegion").onchange();
        }
        postAndDebug("changeCameraTarget", { target });
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
    const changeOnly = id === "boneId" || id === "rotationOrder";
    element?.addEventListener(changeOnly ? "change" : "input", () => {
        if (id === "boneId") syncBoneList();
        applyPropOffsets(id === "boneId" ? "bone" : id);
    });
});

document.getElementById("propModel")?.addEventListener("input", () => {
    setValue("propPreset", "custom");
    addDebugLog("nui:propModelChanged");
});

post("pageReady");
