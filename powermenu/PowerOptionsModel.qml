import QtQml.Models

// Centralized list of power actions used by PowerMenu
ListModel {
    ListElement {
        name: "Poweroff"
        icon: "../_styles/icons/pow/accensione.svg"
        command: "systemctl poweroff"
    }
    ListElement {
        name: "Reboot"
        icon: "../_styles/icons/pow/riavvio.svg"
        command: "systemctl reboot"
    }
    ListElement {
        name: "Lockscreen"
        icon: "../_styles/icons/pow/accensione.svg"
        command: "loginctl lock-session"
    }
    ListElement {
        name: "Logout"
        icon: "../_styles/icons/pow/accensione.svg"
        command: "hyprctl dispatch exit"
    }
}
