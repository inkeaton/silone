// NotificationsConfig.qml - Notification panel settings
import QtQuick

QtObject {
    // Panel dimensions
    readonly property int panelWidth: 350
    readonly property int topMargin: 10
    readonly property int rightMargin: 10
    readonly property int spacing: 8

    // Notification behavior
    readonly property int defaultExpireTimeout: 5000  // ms, 0 = don't expire
    readonly property bool expireNotifications: true

    // Delegate styling
    readonly property QtObject delegate: QtObject {
        readonly property int minHeight: 80
        readonly property int iconSize: 48
        readonly property int closeButtonSize: 24
        readonly property int padding: 12
        readonly property int cornerRadius: 20
    }
}
