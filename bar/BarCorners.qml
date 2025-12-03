import Quickshell
import Quickshell.Io
import QtQuick
import "../_systems"
import "../_styles"

PanelWindow {
        exclusiveZone: 0
        color: "transparent"
        mask: Region {}
        Rectangle {
            id: rect
            color: "transparent"

            anchors.fill: parent
        }
        anchors {
                top: true
                left: true
                right: true
                bottom:true
            }
            aboveWindows: true
        Corners {
            color: Styles.surface
            property int cornerSize: 25
            corners: [0, 1, 2, 3]
        }
    }