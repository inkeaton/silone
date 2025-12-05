// VolumeOSD.qml - Refactored with better code style
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import QtQuick.VectorImage
import "../_styles"
import "../_services"
import "../_config"

Scope {
    id: root

    // Show the panel whenever AudioService reports a change.
    Connections {
        target: AudioService

        function onVolumeChanged() {
            root.shouldShowOsd = true;
            root.panelActive = true;
            hideTimer.restart();
        }

        function onMutedChanged() {
            root.shouldShowOsd = true;
            root.panelActive = true;
            hideTimer.restart();
        }
    }

    // State properties
    property bool shouldShowOsd: false
    property bool panelActive: false

    // Current volume (0.0 to 1.0)
    property real volumeValue: AudioService.volume

    // Mute state
    property bool isMuted: AudioService.muted

    // Device information
    property string deviceName: AudioService.deviceName

    property string deviceIconName: AudioService.deviceIcon

    // Hide timer
    Timer {
        id: hideTimer
        interval: Config.osd.hideDelay
        onTriggered: {
            root.shouldShowOsd = false;
        }
    }

    // Lazy-loaded OSD panel
    LazyLoader {
        active: root.panelActive

        PanelWindow {
            // Positioning
            anchors.bottom: true
            margins.bottom: screen.height / 9
            exclusiveZone: 0

            implicitWidth: 420
            implicitHeight: 64
            color: "transparent"
            mask: Region {}

            // Main panel rectangle
            Rectangle {
                id: panelRect
                anchors.fill: parent
                radius: height / 2
                color: Styles.primary_container

                // Slide transform
                transform: Translate {
                    id: slideTransform
                    y: 48
                }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 18
                        rightMargin: 20
                        topMargin: 10
                        bottomMargin: 10
                    }
                    spacing: 12

                    // Device icon
                    VectorImage {
                        id: volumeIcon
                        source: root.deviceIconName
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        fillMode: Image.PreserveAspectFit
                        preferredRendererType: VectorImage.CurveRenderer
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 4

                        // Device name
                        Text {
                            text: root.deviceName
                            font.pixelSize: 14
                            font.family: Styles.mainFont
                            font.bold: true
                            color: Styles.primary_fixed
                            elide: Text.ElideRight
                            Layout.preferredWidth: 320
                        }

                        // Volume bar
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Layout.alignment: Qt.AlignVCenter

                            // Progress bar background
                            Rectangle {
                                implicitHeight: 12
                                Layout.preferredWidth: 325
                                radius: 20
                                color: Styles.on_primary

                                // Progress bar fill
                                Rectangle {
                                    id: fillRect
                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                        bottom: parent.bottom
                                    }
                                    color: Styles.primary
                                    radius: parent.radius
                                    implicitWidth: parent.width * (root.volumeValue ?? 0)
                                    opacity: root.isMuted ? 0.28 : 1.0

                                    Behavior on implicitWidth {
                                        NumberAnimation {
                                            duration: 150
                                            easing.type: Easing.InOutQuad
                                        }
                                    }

                                    Behavior on opacity {
                                        NumberAnimation { duration: 120 }
                                    }
                                }
                            }
                        }
                    }
                }

                // Initialize on creation
                Component.onCompleted: {
                    if (root.shouldShowOsd) {
                        slideInAnimation.start();
                    } else {
                        slideTransform.y = 48;
                        panelRect.opacity = 0;
                    }
                }

                // Listen for visibility changes
                Connections {
                    target: root

                    function onShouldShowOsdChanged() {
                        if (root.shouldShowOsd) {
                            slideInAnimation.start();
                        } else {
                            dismissAnimation.start();
                        }
                    }
                }

                // Slide-in animation
                ParallelAnimation {
                    id: slideInAnimation

                    NumberAnimation {
                        target: slideTransform
                        property: "y"
                        to: 0
                        duration: 300
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        target: panelRect
                        property: "opacity"
                        to: 1
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }

                // Slide-out animation
                SequentialAnimation {
                    id: dismissAnimation

                    ParallelAnimation {
                        NumberAnimation {
                            target: slideTransform
                            property: "y"
                            to: 48
                            duration: 200
                            easing.type: Easing.InCubic
                        }

                        NumberAnimation {
                            target: panelRect
                            property: "opacity"
                            to: 0
                            duration: 200
                            easing.type: Easing.InCubic
                        }
                    }

                    ScriptAction {
                        script: {
                            if (!root.shouldShowOsd) {
                                root.panelActive = false;
                            }
                        }
                    }
                }
            }
        }
    }
}