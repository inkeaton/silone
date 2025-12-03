// Workspaces.qml - Fixed shake animation bug
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../_styles/"

Rectangle {
    id: root
    height: 25
    width: wrow.implicitWidth
    radius: 30
    color: Styles.primary_container

    Row {
        id: wrow
        anchors.centerIn: parent
        spacing: 8
        leftPadding: 10
        rightPadding: 10

        Repeater {
            model: Hyprland.workspaces

            Rectangle {
                id: workspaceIndicator
                width: modelData.active ? 30 : 10
                height: 10
                radius: 30
                color: modelData.active ? Styles.primary_fixed : Styles.primary

                // Smooth width transition
                Behavior on width {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                // Shake animation transform
                transform: Translate {
                    id: shakeTrans
                    x: 0
                    y: 0
                }

                // Shake animation sequence
                SequentialAnimation {
                    id: shakeAnim
                    running: false
                    loops: 1

                    onFinished: {
                        shakeTrans.x = 0;
                    }

                    NumberAnimation {
                        target: shakeTrans
                        property: "x"
                        to: 1
                        duration: 50
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: shakeTrans
                        property: "x"
                        to: -1
                        duration: 50
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: shakeTrans
                        property: "x"
                        to: 0
                        duration: 50
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: shakeTrans
                        property: "x"
                        to: 1
                        duration: 50
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: shakeTrans
                        property: "x"
                        to: 0
                        duration: 50
                        easing.type: Easing.InOutQuad
                    }
                }

                // Mouse interaction
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        clickAnimation.start();
                        Hyprland.dispatch("workspace " + modelData.id);
                    }

                    onEntered: {
                        if (!modelData.active) {
                            shakeAnim.running = true;
                        }
                    }
                }
            }
        }

        // Debug text when no workspaces
        Text {
            visible: Hyprland.workspaces.length === 0
            text: "No workspaces detected"
            color: Styles.primary
            font.family: Styles.mainFont
            font.pixelSize: 12
        }
    }

    // Click animation
    SequentialAnimation {
        id: clickAnimation
        running: false

        NumberAnimation {
            target: root
            property: "scale"
            to: 0.9
            duration: 100
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root
            property: "scale"
            to: 1.0
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
}