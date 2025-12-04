//@ pragma UseQApplication
import "./bar"
import "./launcher"
import "./powermenu"
import "./osd"
import "./notifications"
import "./dashboard"
import "./_utils"

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

    LoaderToggle {
        id: launcherToggle
        loader: launcherLoader
    }

    // PowerMenu
    LazyLoader {
        id: powermenuLoader
        loading: true

        source: "./powermenu/PowerMenu.qml"
    }

    LoaderToggle {
        id: powermenuToggle
        loader: powermenuLoader
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

    LoaderToggle {
        id: dashboardToggle
        loader: dashboardLoader
    }

    VolumeOSD {}

// Toggles  
    IpcHandler { 
        id: ipc
        target: "toggle"  

        function launcher(){
            launcherToggle.toggle();
        }

        function powermenu(){
            powermenuToggle.toggle();
        }

        function dashboard() {
            dashboardToggle.toggle();
        }

    }

}

