// VolumeOSD.qml - Refactored with better code style
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import QtQuick.VectorImage
import "../_styles"

Scope {
    id: root

    // Track the default audio sink
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    // Show OSD when volume or mute changes
    Connections {
        target: Pipewire.defaultAudioSink?.audio

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
    property real volumeValue: {
        const audio = Pipewire.defaultAudioSink?.audio;
        if (!audio) return 0;
        
        // Support both single volume and volume array
        if (audio.volume !== undefined) return audio.volume;
        if (audio.volumes !== undefined && audio.volumes.length > 0) return audio.volumes[0];
        return 0;
    }

    // Mute state
    property bool isMuted: Pipewire.defaultAudioSink?.audio?.muted ?? false

    // Device information
    property string deviceName: {
        const props = Pipewire.defaultAudioSink?.properties ?? {};
        const desc = Pipewire.defaultAudioSink?.description ?? "";
        
        return props["device.description"] 
            ?? props["node.description"] 
            ?? props["alsa.card.name"] 
            ?? desc 
            ?? "Unknown output";
    }

    property string deviceIconName: {
        const props = Pipewire.defaultAudioSink?.properties ?? {};
        const name = (props["device.description"] 
                   ?? props["node.description"] 
                   ?? Pipewire.defaultAudioSink?.description 
                   ?? "").toLowerCase();

        // Detect device type from name
        if (name.includes("headphone") || name.includes("headset")) {
            return "../_styles/icons/vol/volume-100.svg";
        }
        if (name.includes("speaker") || name.includes("speakers")) {
            return "../_styles/icons/vol/volume-75.svg";
        }

        return "../_styles/icons/vol/volume-25.svg";
    }

    // Hide timer
    Timer {
        id: hideTimer
        interval: 1000
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