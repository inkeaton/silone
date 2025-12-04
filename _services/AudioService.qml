// AudioService.qml - central PipeWire helper
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "." as Services

Singleton {
    id: root

    // Keep PipeWire nodes tracked so bindings update as soon as volume changes.
    property list<var> trackedObjects: {
        const list = [];
        if (Pipewire.defaultAudioSink)
            list.push(Pipewire.defaultAudioSink);
        const sinkAudio = Pipewire.defaultAudioSink?.audio;
        if (sinkAudio)
            list.push(sinkAudio);
        return list;
    }

    PwObjectTracker {
        id: tracker
        objects: root.trackedObjects
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var sinkAudio: sink?.audio
    readonly property bool available: sinkAudio !== undefined

    readonly property string deviceName: Services.Icons.deviceNameForSink(sink)
    readonly property string deviceIcon: Services.Icons.deviceIconForSink(sink)

    readonly property real volume: root.available ? root.readVolume(sinkAudio) : 0.0
    readonly property bool muted: sinkAudio?.muted ?? false

    // Expose current PipeWire nodes for per-app controls.
    readonly property var streams: Pipewire.nodes.values

    function clampVolume(value) {
        return Math.max(0, Math.min(1, value));
    }

    function readVolume(audio) {
        if (!audio)
            return 0.0;
        if (audio.volume !== undefined)
            return audio.volume;
        if (audio.volumes !== undefined && audio.volumes.length > 0)
            return audio.volumes[0];
        return 0.0;
    }

    function setVolume(value) {
        if (!root.available)
            return false;
        const clamped = root.clampVolume(value);
        if (sinkAudio.volume !== undefined) {
            sinkAudio.volume = clamped;
            return true;
        }
        if (sinkAudio.volumes !== undefined && sinkAudio.volumes.length > 0) {
            let volumes = sinkAudio.volumes;
            for (let i = 0; i < volumes.length; ++i)
                volumes[i] = clamped;
            sinkAudio.volumes = volumes;
            return true;
        }
        return false;
    }

    function adjustVolume(delta) {
        return root.setVolume(root.volume + delta);
    }

    function toggleMute(force) {
        if (!root.available)
            return false;
        sinkAudio.muted = force !== undefined ? Boolean(force) : !sinkAudio.muted;
        return true;
    }

    function nodeVolume(node) {
        if (!node?.audio)
            return 0.0;
        return root.readVolume(node.audio);
    }

    function setNodeVolume(node, value) {
        if (!node?.audio)
            return false;
        node.audio.volume = root.clampVolume(value);
        return true;
    }

    function toggleNodeMute(node, force) {
        if (!node?.audio)
            return false;
        node.audio.muted = force !== undefined ? Boolean(force) : !node.audio.muted;
        return true;
    }

    function nodeDisplayName(node) {
        if (!node)
            return "Unknown";
        const props = node.properties ?? {};
        const appName = props["application.name"] ?? node.description ?? "Unknown App";
        const mediaName = props["media.name"];
        if (mediaName && mediaName !== appName && mediaName.indexOf("Audio Stream") === -1)
            return mediaName;
        return appName;
    }
}
