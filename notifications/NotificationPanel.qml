import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "../_styles/"

ShellRoot {
    // -------------------------------------------------------------------------
    // Notification Server
    // -------------------------------------------------------------------------
    NotificationServer {
        id: notifServer
        actionsSupported: true
        bodyMarkupSupported: true
        keepOnReload: true
        persistenceSupported: true

        // Track incoming notifications so they appear in the list
        onNotification: notif => {
            notif.tracked = true;
            notificationWindow.visible = true;
        }
    }

    // -------------------------------------------------------------------------
    // Window
    // -------------------------------------------------------------------------
    PanelWindow {
        id: notificationWindow
        
        anchors {
            right: true
            top: true
        }

        margins {
            top: 10
            right: 10
        }
        
        width: 350
        // Use implicitHeight to auto-collapse the window when empty
        implicitHeight: visible ? contentColumn.implicitHeight : 0
        
        // Only visible if we have notifications
        visible: notifServer.trackedNotifications.length > 0
        
        color: "transparent"
        
        Column {
            id: contentColumn
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            spacing: 8
            
            Repeater {
                model: notifServer.trackedNotifications
                delegate: notificationDelegateComponent
            }
        }
    }
    
    // -------------------------------------------------------------------------
    // Delegate Component
    // -------------------------------------------------------------------------
    Component {
        id: notificationDelegateComponent
        
        NotificationDelegate {
            // Note: We do NOT assign 'notification: modelData' here.
            // The Repeater injects 'modelData' directly into the item.
            
            windowWidth: notificationWindow.width
            bodyMarkupSupported: notifServer.bodyMarkupSupported
        }
    }
}