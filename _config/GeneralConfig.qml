// GeneralConfig.qml - General settings and default applications
import QtQuick

QtObject {
    // Default applications
    readonly property QtObject apps: QtObject {
        readonly property string terminal: "kitty"
        readonly property string fileManager: "thunar"
        readonly property string browser: "firefox"
        readonly property string editor: "code"
    }

    // Compositor (Hyprland) commands
    readonly property QtObject hyprland: QtObject {
        readonly property string workspacePrefix: "workspace "
        readonly property string dispatchPrefix: "hyprctl dispatch "
    }

    // Debug settings
    readonly property bool debugMode: false
    readonly property bool showFps: false
}
