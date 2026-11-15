function quoted(value) {
    return '"' + String(value ?? "").replace(/\\/g, "\\\\").replace(/"/g, '\\"')
        .replace(/[\x00-\x1f\x7f]/g, (character) => "\\" + String(character.charCodeAt(0)).padStart(3, "0")) + '"';
}

function vectorValues(vector) {
    return [vector.x, vector.y, vector.z].map((value) => Number(value).toFixed(5)).join(", ");
}

function vec3(vector) {
    return "vec3(" + vectorValues(vector) + ")";
}

export function formatExport(format, { id, label, animation }, props, rotations) {
    if (format === "json") return JSON.stringify({ id, label, animation, props }, null, 4);

    if (format === "values") {
        return props.map((prop) => [
            prop.model + " | bone " + prop.boneId + " | order " + prop.rotationOrder,
            vectorValues(prop.offset),
            vectorValues(prop.rotation),
        ].join("\n")).join("\n\n");
    }

    if (format === "native") {
        return props.map((prop, index) => [
            "-- " + prop.model.replace(/[\r\n]/g, " "),
            "AttachEntityToEntity(object" + (index + 1) + ", ped, GetPedBoneIndex(ped, " + prop.boneId + "),",
            "    " + vectorValues(prop.offset) + ", " + vectorValues(prop.rotation) + ",",
            "    true, true, false, true, " + prop.rotationOrder + ", true)",
        ].join("\n")).join("\n\n");
    }

    if (format === "scully") {
        const lines = [
            "{",
            "    Label = " + quoted(label || id) + ",",
            "    Command = " + quoted(id) + ",",
            "    Dictionary = " + quoted(animation.dict) + ",",
            "    Animation = " + quoted(animation.anim) + ",",
            "    Options = {",
        ];
        const flags = [];
        if (animation.flag === 50) flags.push("Stuck = true");
        else if ((animation.flag & 48) === 48) flags.push("Move = true");
        if ((animation.flag & 1) !== 0) flags.push("Loop = true");
        if (animation.duration > 0) lines.push("        Duration = " + Math.trunc(animation.duration) + ",");
        if (flags.length) lines.push("        Flags = { " + flags.join(", ") + " },");
        if (props.length) {
            lines.push("        Props = {");
            props.forEach((prop, index) => lines.push(
                "            {",
                "                Name = " + quoted(prop.model) + ",",
                "                Bone = " + prop.boneId + ",",
                "                Placement = { " + vec3(prop.offset) + ", " + vec3(rotations[index]) + " },",
                "            },",
            ));
            lines.push("        },");
        }
        return [...lines, "    },", "},"].join("\n");
    }

    const lines = [
        "{",
        "    id = " + quoted(id) + ",",
        "    dict = " + quoted(animation.dict) + ",",
        "    anim = " + quoted(animation.anim) + ",",
        "    flags = " + animation.flag + ",",
        "    blendIn = " + animation.blendIn + ",",
        "    blendOut = " + animation.blendOut + ",",
        "    duration = " + animation.duration + ",",
        "    playbackRate = " + animation.playbackRate + ",",
        "    props = {",
    ];
    for (const prop of props) lines.push(
        "        {",
        "            model = " + quoted(prop.model) + ",",
        "            bone = " + prop.boneId + ",",
        "            pos = " + vec3(prop.offset) + ",",
        "            rot = " + vec3(prop.rotation) + ",",
        "            rotationOrder = " + prop.rotationOrder + ",",
        "        },",
    );
    return [...lines, "    },", "}"].join("\n");
}
