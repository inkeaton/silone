// Icons.qml - shared heuristics for icons and friendly labels
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property string volumeIconDir: "../_styles/icons/vol/"

    function resolved(path) {
        return Qt.resolvedUrl(path)
    }

    function deviceNameForSink(sink) {
        if (!sink)
            return "Unknown output"
        const props = sink.properties ?? {}
        const description = sink.description ?? ""
        return props["device.description"]
            ?? props["node.description"]
            ?? props["alsa.card.name"]
            ?? description
            ?? "Unknown output"
    }

    function deviceIconForSink(sink) {
        const name = deviceNameForSink(sink).toLowerCase()
        if (name.indexOf("headphone") !== -1 || name.indexOf("headset") !== -1)
            return resolved(volumeIconDir + "volume-100.svg")
        if (name.indexOf("speaker") !== -1)
            return resolved(volumeIconDir + "volume-75.svg")
        if (name.indexOf("monitor") !== -1 || name.indexOf("display") !== -1)
            return resolved(volumeIconDir + "volume-50.svg")
        return resolved(volumeIconDir + "volume-25.svg")
    }

    function volumeIcon(volume, isMuted) {
        const v = Math.max(0, Math.min(1, volume ?? 0))
        if (isMuted || v === 0)
            return resolved(volumeIconDir + "volume-mute.svg")
        if (v < 0.26)
            return resolved(volumeIconDir + "volume-25.svg")
        if (v < 0.51)
            return resolved(volumeIconDir + "volume-50.svg")
        if (v < 0.76)
            return resolved(volumeIconDir + "volume-75.svg")
        return resolved(volumeIconDir + "volume-100.svg")
    }

    function appIconForName(name, fallback) {
        const entry = DesktopEntries.heuristicLookup(name)
        const icon = entry?.icon
        return fallback ? Quickshell.iconPath(icon, fallback) : Quickshell.iconPath(icon)
    }

    function notificationIcon(summary, urgency) {
        const lowered = (summary || "").toLowerCase().trim()
        if (!lowered && urgency !== NotificationUrgency.Critical)
            return ""
        if (lowered.indexOf("battery") !== -1)
            return "image://icon/power"
        if (lowered.indexOf("update") !== -1)
            return "image://icon/update"
        if (lowered.indexOf("download") !== -1 || lowered.indexOf("installed") !== -1)
            return "image://icon/download"
        if (lowered.indexOf("warning") !== -1 || urgency === NotificationUrgency.Critical)
            return "image://icon/warning"
        if (lowered.indexOf("message") !== -1 || lowered.indexOf("chat") !== -1)
            return "image://icon/chat"
        return "image://icon/notifications"
    }
}
