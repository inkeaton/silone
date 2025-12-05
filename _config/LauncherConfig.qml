// LauncherConfig.qml - Application launcher settings
import QtQuick

QtObject {
    // Window dimensions
    readonly property int width: 600
    readonly property int height: 380

    // Search behavior
    readonly property int maxResults: 100
    readonly property int searchDebounceMs: 100

    // List item sizing
    readonly property QtObject item: QtObject {
        readonly property int height: 50
        readonly property int iconSize: 32
        readonly property int padding: 8
    }

    // Fuzzy search thresholds
    readonly property QtObject fuzzy: QtObject {
        readonly property real threshold: 0.6
        readonly property bool enabled: true
    }
}
