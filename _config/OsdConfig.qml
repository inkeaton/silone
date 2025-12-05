// OsdConfig.qml - On-screen display settings
import QtQuick

QtObject {
    // Enable/disable OSD
    readonly property bool enabled: true

    // Timing
    readonly property int hideDelay: 1000  // ms before hiding

    // Sizing
    readonly property QtObject sizes: QtObject {
        readonly property int width: 200
        readonly property int height: 50
        readonly property int iconSize: 28
        readonly property int sliderHeight: 6
    }

    // Position offset from edge
    readonly property int bottomMargin: 100
}
