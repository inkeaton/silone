// AppearanceConfig.qml - Font, sizing, spacing, animation settings
import QtQuick

QtObject {
    // Font settings
    readonly property QtObject font: QtObject {
        readonly property string family: "SF Pro Rounded"
        readonly property int small: 12
        readonly property int normal: 14
        readonly property int large: 17
        readonly property int xlarge: 20
        readonly property int xxlarge: 24
    }

    // Border radius / rounding
    readonly property QtObject rounding: QtObject {
        readonly property int small: 16
        readonly property int normal: 28
        readonly property int large: 30
        readonly property int full: 50
    }

    // Spacing between elements
    readonly property QtObject spacing: QtObject {
        readonly property int tiny: 4
        readonly property int small: 6
        readonly property int normal: 8
        readonly property int large: 10
        readonly property int xlarge: 12
        readonly property int xxlarge: 16
        readonly property int section: 20
    }

    // Padding inside elements
    readonly property QtObject padding: QtObject {
        readonly property int small: 8
        readonly property int normal: 10
        readonly property int large: 16
        readonly property int xlarge: 20
        readonly property int section: 25
    }

    // Animation durations (ms)
    readonly property QtObject animation: QtObject {
        readonly property int instant: 50
        readonly property int fast: 100
        readonly property int normal: 150
        readonly property int slow: 200
        readonly property int verySlow: 300
    }
}
