import QtQuick
import QtQuick.Layouts
import QtQuick.VectorImage
import "../_styles"
import "../_components/animations" as Animations

// Button used by the power menu grid, encapsulating icon, label, and hover behavior.
Item {
    id: root

    property url iconSource: ""
    property string command: ""
    property string accessibleName: "Power action"
    property bool current: false

    signal triggered(string command)

    implicitWidth: 150
    implicitHeight: 150

    readonly property bool hovered: mouseArea.containsMouse

    scale: current ? 1.05 : (hovered ? 1.02 : 1)
    opacity: current ? 1.0 : (hovered ? 0.9 : 0.75)

    Behavior on scale { Animations.ScalePress {} }
    Behavior on opacity { Animations.FadeInFast {} }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        radius: width / 2
        color: "transparent"

        VectorImage {
            anchors.centerIn: parent
            source: root.iconSource
            width: parent.width * 0.7
            height: width
            fillMode: Image.PreserveAspectFit
            preferredRendererType: VectorImage.CurveRenderer
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        Accessible.role: Accessible.Button
        Accessible.name: root.accessibleName

        onClicked: root.triggered(root.command)
    }
}
