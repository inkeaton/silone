// PowerMenuConfig.qml - Power menu commands and layout
import QtQuick

QtObject {
    // Window dimensions
    readonly property int width: 350
    readonly property int height: 430

    // Grid layout
    readonly property int columns: 2
    readonly property int spacing: 16

    // Commands - customize for your system
    readonly property QtObject commands: QtObject {
        readonly property string poweroff: "systemctl poweroff"
        readonly property string reboot: "systemctl reboot"
        readonly property string lock: "loginctl lock-session"
        readonly property string logout: "hyprctl dispatch exit"
        readonly property string suspend: "systemctl suspend"
        readonly property string hibernate: "systemctl hibernate"
    }

    // Icons (paths relative to _styles/icons/pow/)
    readonly property QtObject icons: QtObject {
        readonly property string poweroff: "../_styles/icons/pow/accensione.svg"
        readonly property string reboot: "../_styles/icons/pow/riavvio.svg"
        readonly property string lock: "../_styles/icons/pow/accensione.svg"
        readonly property string logout: "../_styles/icons/pow/accensione.svg"
    }
}
