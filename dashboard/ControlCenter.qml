import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire
import "../_styles"

PanelWindow {
    id: dashboard

    anchors { top: true; left: true }
    margins { top: 10; left: 10 }

    width: 400
    height: mainRect.implicitHeight
    
    visible: false
    color: "transparent"

    onVisibleChanged: {
        if (visible) contentGrid.forceActiveFocus();
    }

    // TRACKING: Essential for signals to fire, even if we read the Singleton below.
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    Rectangle {
        id: mainRect
        width: parent.width
        implicitHeight: mainLayout.implicitHeight + 40
        color: Styles.surface
        radius: 30
        clip: true

        property bool mixerExpanded: false
            // Human-friendly device name (matches VolumeOSD logic)
            readonly property string deviceName: {
                const props = Pipewire.defaultAudioSink?.properties ?? {};
                const desc = Pipewire.defaultAudioSink?.description ?? "";
                return props["device.description"] 
                    ?? props["node.description"] 
                    ?? props["alsa.card.name"] 
                    ?? desc 
                    ?? "Unknown output";
            }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // --- HEADER ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "Audio"
                    font.family: Styles.mainFont
                    font.pixelSize: 24
                    font.bold: true
                    color: Styles.primary
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 40; height: 40; radius: 20
                    color: settingsMouse.containsMouse ? Styles.primary_container : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⚙"
                        color: Styles.primary
                        font.pixelSize: 20
                    }
                    MouseArea {
                        id: settingsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: console.log("Settings clicked")
                    }
                }
            }


            // --- MASTER CONTROLS ---
            RowLayout {
                id: contentGrid
                Layout.fillWidth: true
                spacing: 10
                focus: true

                // Mute Button
                Rectangle {
                    width: 32; height: 32; radius: 16
                    color: muteMouse.containsMouse ? Styles.primary_container : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    // Access Singleton directly
                    readonly property bool isMuted: Pipewire.defaultAudioSink?.audio?.muted ?? false
                    
                    Text {
                        anchors.centerIn: parent
                        text: parent.isMuted ? "🔇" : "🔊"
                        font.pixelSize: 20
                        color: Styles.primary
                    }
                    
                    MouseArea {
                        id: muteMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (Pipewire.defaultAudioSink?.audio) {
                                Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
                            }
                        }
                    }
                }

                // MASTER SLIDER with device name above it
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: mainRect.deviceName
                        color: Styles.primary_fixed
                        font.family: Styles.mainFont
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Slider {
                        id: masterSlider
                        Layout.fillWidth: true
                        from: 0.0
                        to: 1.0

                        // 1. READ LOGIC (Matches VolumeOSD)
                        readonly property real systemVolume: {
                            const audio = Pipewire.defaultAudioSink?.audio;
                            if (!audio) return 0.5;
                            if (audio.volume !== undefined) return audio.volume;
                            if (audio.volumes !== undefined && audio.volumes.length > 0) return audio.volumes[0];
                            return 0.5;
                        }

                        // Prevent binding loop: while pressing, keep the local slider value.
                        value: pressed ? value : systemVolume

                        // Write changes as the user drags (matches MixerEntry pattern).
                        onMoved: {
                            if (Pipewire.defaultAudioSink?.audio) {
                                Pipewire.defaultAudioSink.audio.volume = value;
                            }
                        }

                        // Visual Style
                        background: Rectangle {
                            x: masterSlider.leftPadding
                            y: masterSlider.topPadding + masterSlider.availableHeight / 2 - height / 2
                            width: masterSlider.availableWidth
                            height: 6
                            radius: 3
                            color: Styles.primary_container

                            Rectangle {
                                width: masterSlider.visualPosition * parent.width
                                height: parent.height
                                color: Styles.primary
                                radius: 3
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onPressed: {
                                    const w = parent.width;
                                    var frac = Math.max(0, Math.min(1, mouse.x / w));
                                    masterSlider.value = frac;
                                    if (Pipewire.defaultAudioSink?.audio) Pipewire.defaultAudioSink.audio.volume = frac;
                                }
                                onPositionChanged: {
                                    if (pressed) {
                                        const w = parent.width;
                                        var frac = Math.max(0, Math.min(1, mouse.x / w));
                                        masterSlider.value = frac;
                                        if (Pipewire.defaultAudioSink?.audio) Pipewire.defaultAudioSink.audio.volume = frac;
                                    }
                                }
                            }
                        }

                        handle: Rectangle {
                            x: masterSlider.leftPadding + masterSlider.visualPosition * (masterSlider.availableWidth - width)
                            y: masterSlider.topPadding + masterSlider.availableHeight / 2 - height / 2
                            width: 20; height: 20; radius: 10
                            color: Styles.primary
                            scale: masterSlider.pressed ? 1.2 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }
                        }
                    }
                }

                // Expand Button
                Rectangle {
                    width: 32; height: 32; radius: 16
                    color: expandMouse.containsMouse ? Styles.primary_container : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Text {
                        anchors.centerIn: parent
                        text: mainRect.mixerExpanded ? "▲" : "▼"
                        color: Styles.primary
                        font.pixelSize: 12
                    }
                    
                    MouseArea {
                        id: expandMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mainRect.mixerExpanded = !mainRect.mixerExpanded
                    }
                }
            }

            // --- APP MIXER ---
            ColumnLayout {
                id: mixerList
                Layout.fillWidth: true
                spacing: 0
                clip: true
                visible: mainRect.mixerExpanded
                
                Layout.preferredHeight: visible ? implicitHeight : 0
                
                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Styles.primary_container
                    Layout.bottomMargin: 15
                    opacity: 0.5
                }

                Repeater {
                    model: Pipewire.nodes.values
                    delegate: Item {
                        id: appWrapper
                        Layout.fillWidth: true
                        
                        property var nodeProps: modelData.properties
                        property string mediaClass: nodeProps ? (nodeProps["media.class"] ?? "") : ""
                        readonly property bool isApp: mediaClass.indexOf("Stream/Output/Audio") !== -1
                        
                        visible: isApp
                        Layout.preferredHeight: visible ? mixerEntry.implicitHeight : 0
                        
                        MixerEntry {
                            id: mixerEntry
                            anchors.left: parent.left
                            anchors.right: parent.right
                            node: modelData
                            visible: appWrapper.visible
                        }
                    }
                }
                
                Item {
                    Layout.preferredHeight: 10
                    visible: mixerList.visible
                }
            }

                        // --- MEDIA PLAYER ---
            MediaPlayer {
                Layout.fillWidth: true
            }
        }
    }

    // Keyboard Shortcuts
    Keys.onPressed: (event) => {
        switch (event.key) {
            case Qt.Key_Escape:
                dashboard.visible = false;
                event.accepted = true;
                break;
            case Qt.Key_Space:
                if (Pipewire.defaultAudioSink?.audio) {
                    Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
                }
                event.accepted = true;
                break;
            case Qt.Key_M:
                mainRect.mixerExpanded = !mainRect.mixerExpanded;
                event.accepted = true;
                break;
        }
    }
}