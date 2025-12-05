// DashboardConfig.qml - Control center / dashboard settings
import QtQuick

QtObject {
    // Window dimensions
    readonly property int width: 400
    readonly property int rightMargin: 10
    readonly property int topMargin: 50

    // Section spacing
    readonly property int sectionSpacing: 20
    readonly property int itemSpacing: 10

    // Media player
    readonly property QtObject mediaPlayer: QtObject {
        readonly property int height: 125
        readonly property int artRadius: 28
    }

    // Mixer entries
    readonly property QtObject mixer: QtObject {
        readonly property int sliderHeight: 6
        readonly property int iconSize: 32
    }

    // Quick toggles
    readonly property QtObject toggles: QtObject {
        readonly property int size: 40
        readonly property int iconSize: 20
    }
}
