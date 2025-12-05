// BarConfig.qml - Bar positioning and sizing
import QtQuick

QtObject {
    // Bar dimensions
    readonly property int height: 40
    readonly property int margin: 16
    readonly property int moduleSpacing: 8
    readonly property int sectionSpacing: 12

    // Clock format (Qt time format string)
    readonly property string clockFormat: "hh:mm"

    // Workspaces
    readonly property QtObject workspaces: QtObject {
        readonly property int indicatorWidth: 10
        readonly property int activeWidth: 30
        readonly property int indicatorHeight: 10
    }

    // System tray
    readonly property QtObject tray: QtObject {
        readonly property int iconSize: 20
        readonly property int spacing: 8
    }
}
