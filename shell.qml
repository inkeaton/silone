//@ pragma UseQApplication
import "./bar"
import "./launcher"
import "./powermenu"
import "./osd"
import "./notifications"
import "./dashboard"

// shell.qml
import Quickshell
import Quickshell.Io

Scope {
    Bar {}
    
    BarCorners {}

    // Launcher
    LazyLoader {
        id: launcherLoader
        loading: true

        source: "./launcher/AppLauncher.qml"
    }

    // PowerMenu
    LazyLoader {
        id: powermenuLoader
        loading: true

        source: "./powermenu/PowerMenu.qml"
    }

    LazyLoader {
        id: notificationLoader
        loading: true

        source: "./notifications/NotificationPanel.qml"
    }

    // shell.qml
    LazyLoader {
        id: dashboardLoader
        loading: true
        source: "./dashboard/ControlCenter.qml"
    }

    VolumeOSD {}

// Toggles  
    IpcHandler { 
        id: ipc
        target: "toggle"  

        function launcher(){
            if (!launcherLoader.item)
                launcherLoader.active = true;

            // toggle visibility
            launcherLoader.item.visible = !launcherLoader.item.visible;
            
        }

        function powermenu(){
            if (!powermenuLoader.item)
                powermenuLoader.active = true;

            // toggle visibility
            powermenuLoader.item.visible = !powermenuLoader.item.visible;
            
        }

        function dashboard() {
            if (!dashboardLoader.item) 
                dashboardLoader.active = true;

            dashboardLoader.item.visible = !dashboardLoader.item.visible;
        }

    }

}

