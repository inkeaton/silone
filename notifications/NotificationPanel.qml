// NotificationPanel.qml - Displays incoming notifications
// Uses NotificationService singleton for notification management
import Quickshell
import QtQuick
import QtQuick.Layouts
import "../_styles/"
import "../_services"
import "../_config"

Scope {
    id: root

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
            top: Config.notifications.topMargin
            right: Config.notifications.rightMargin
        }
        
        // Use implicitWidth instead of deprecated width
        implicitWidth: Config.notifications.panelWidth
        
        // Dynamic height based on content
        implicitHeight: NotificationService.hasNotifications 
            ? contentColumn.implicitHeight 
            : 0
        
        // Only visible when there are notifications
        visible: NotificationService.hasNotifications
        
        color: "transparent"
        
        // Notification list container
        Column {
            id: contentColumn
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            spacing: Config.notifications.spacing
            
            Repeater {
                model: NotificationService.trackedNotifications
                
                delegate: NotificationDelegate {
                    windowWidth: notificationWindow.implicitWidth
                    bodyMarkupSupported: NotificationService.server?.bodyMarkupSupported ?? true
                }
            }
        }
    }
}