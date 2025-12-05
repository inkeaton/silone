import QtQuick
import "../_config"

// Centralized list of power actions used by PowerMenu
// Uses Config for commands so they can be customized
ListModel {
    id: powerOptionsModel
    
    Component.onCompleted: {
        append({
            name: "Poweroff",
            icon: Config.powerMenu.icons.poweroff,
            command: Config.powerMenu.commands.poweroff
        });
        append({
            name: "Reboot",
            icon: Config.powerMenu.icons.reboot,
            command: Config.powerMenu.commands.reboot
        });
        append({
            name: "Lockscreen",
            icon: Config.powerMenu.icons.lock,
            command: Config.powerMenu.commands.lock
        });
        append({
            name: "Logout",
            icon: Config.powerMenu.icons.logout,
            command: Config.powerMenu.commands.logout
        });
    }
}
