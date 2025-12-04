// NotificationService.qml - Singleton notification server manager
// Centralizes notification handling so panels can react to notifications
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    // -------------------------------------------------------------------------
    // Notification Server Configuration
    // -------------------------------------------------------------------------
    
    /** The underlying notification server instance */
    readonly property alias server: notifServer
    
    /** The ObjectModel of currently tracked (visible) notifications - use as model for Repeater */
    readonly property alias trackedNotifications: notifServer.trackedNotifications
    
    /** Whether there are any active notifications */
    readonly property bool hasNotifications: notifServer.trackedNotifications.values.length > 0
    
    /** Count of active notifications */
    readonly property int notificationCount: notifServer.trackedNotifications.values.length

    // -------------------------------------------------------------------------
    // Signals
    // -------------------------------------------------------------------------
    
    /** Emitted when a new notification arrives */
    signal notificationReceived(var notification)
    
    /** Emitted when all notifications are cleared */
    signal allCleared()

    // -------------------------------------------------------------------------
    // Server Instance
    // -------------------------------------------------------------------------
    NotificationServer {
        id: notifServer
        
        // Feature support flags
        actionsSupported: true
        bodyMarkupSupported: true
        keepOnReload: true
        persistenceSupported: true

        // Handle incoming notifications
        onNotification: notif => {
            // Track the notification so it appears in the list
            notif.tracked = true;
            
            // Emit signal for UI components to react
            root.notificationReceived(notif);
        }
    }

    // -------------------------------------------------------------------------
    // Public Methods
    // -------------------------------------------------------------------------
    
    /**
     * Dismiss all tracked notifications
     */
    function clearAll() {
        // Use .values to get the list from ObjectModel, iterate backwards
        const notifs = trackedNotifications.values;
        for (let i = notifs.length - 1; i >= 0; i--) {
            if (notifs[i] && typeof notifs[i].dismiss === 'function') {
                notifs[i].dismiss();
            }
        }
        root.allCleared();
    }
    
    /**
     * Dismiss a specific notification by reference
     * @param notification - The notification object to dismiss
     */
    function dismiss(notification) {
        if (notification && typeof notification.dismiss === 'function') {
            notification.dismiss();
        }
    }
}
