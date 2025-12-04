// NotificationPanel.qml - Displays incoming notifications
// Uses NotificationService singleton for notification management
import Quickshell
import QtQuick
import QtQuick.Layouts
import "../_styles/"
import "../_services"

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
            top: 10  // Below bar
            right: 10
        }
        
        // Use implicitWidth instead of deprecated width
        implicitWidth: 350
        
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
            spacing: 8
            
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