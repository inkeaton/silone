//@ pragma UseQApplication
import "./bar"
import "./launcher"
import "./powermenu"
import "./osd"
import "./notifications"
import "./dashboard"
import "./_utils"
import "./_services"

// shell.qml - Main shell entry point
import Quickshell
import Quickshell.Io

Scope {
    // -------------------------------------------------------------------------
    // Bar & Corners
    // -------------------------------------------------------------------------
    Bar {}
    BarCorners {}

    // -------------------------------------------------------------------------
    // Notifications (always active, auto-shows when notifications arrive)
    // -------------------------------------------------------------------------
    // The NotificationService singleton is auto-loaded when we import _services.
    // The panel listens to it and shows/hides automatically.
    NotificationPanel {}

    // -------------------------------------------------------------------------
    // Launcher (lazy-loaded popup)
    // -------------------------------------------------------------------------
    LazyLoader {
        id: launcherLoader
        loading: true
        source: "./launcher/AppLauncher.qml"
    }

    LoaderToggle {
        id: launcherToggle
        loader: launcherLoader
    }

    // -------------------------------------------------------------------------
    // PowerMenu (lazy-loaded popup)
    // -------------------------------------------------------------------------
    LazyLoader {
        id: powermenuLoader
        loading: true
        source: "./powermenu/PowerMenu.qml"
    }

    LoaderToggle {
        id: powermenuToggle
        loader: powermenuLoader
    }

    // -------------------------------------------------------------------------
    // Dashboard / Control Center (lazy-loaded popup)
    // -------------------------------------------------------------------------
    LazyLoader {
        id: dashboardLoader
        loading: true
        source: "./dashboard/ControlCenter.qml"
    }

    LoaderToggle {
        id: dashboardToggle
        loader: dashboardLoader
    }

    // -------------------------------------------------------------------------
    // Volume OSD (always active, shows on volume change)
    // -------------------------------------------------------------------------
    VolumeOSD {}

    // -------------------------------------------------------------------------
    // IPC Handlers for external toggle commands
    // Usage: qs ipc call toggle <function_name>
    // -------------------------------------------------------------------------
    IpcHandler { 
        id: ipc
        target: "toggle"  

        function launcher() {
            launcherToggle.toggle();
        }

        function powermenu() {
            powermenuToggle.toggle();
        }

        function dashboard() {
            dashboardToggle.toggle();
        }
    }
}