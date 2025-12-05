// Config.qml - Main configuration singleton
// Aggregates all configuration modules into a single access point
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // Sub-configurations
    readonly property AppearanceConfig appearance: AppearanceConfig {}
    readonly property BarConfig bar: BarConfig {}
    readonly property NotificationsConfig notifications: NotificationsConfig {}
    readonly property OsdConfig osd: OsdConfig {}
    readonly property LauncherConfig launcher: LauncherConfig {}
    readonly property PowerMenuConfig powerMenu: PowerMenuConfig {}
    readonly property DashboardConfig dashboard: DashboardConfig {}
    readonly property GeneralConfig general: GeneralConfig {}
}
