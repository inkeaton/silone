// PanelFrame.qml - shared double-layer container for popups
import QtQuick
import "../_styles"

Item {
    id: root

    property color outerColor: Styles.surface
    property color innerColor: Styles.primary_container
    property real outerRadius: 40
    property real innerRadius: 24
    property real frameMargin: 0
    property real contentPadding: 0
    property bool clipContent: true

    default property alias contentData: contentHost.data
    property alias contentItem: contentHost

    implicitWidth: 200
    implicitHeight: 200

    Rectangle {
        id: outerRect
        anchors.fill: parent
        radius: outerRadius
        color: outerColor
    }

    Rectangle {
        id: innerRect
        anchors.fill: outerRect
        anchors.margins: frameMargin
        radius: innerRadius
        color: innerColor
        clip: clipContent
    }

    Item {
        id: contentHost
        anchors {
            left: innerRect.left
            right: innerRect.right
            top: innerRect.top
            bottom: innerRect.bottom
            leftMargin: contentPadding
            rightMargin: contentPadding
            topMargin: contentPadding
            bottomMargin: contentPadding
        }
    }
}
