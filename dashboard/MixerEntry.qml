// MixerEntry.qml - Individual app audio control
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire
import "../_styles"
import "../_services"

ColumnLayout {
    id: root
    required property var node

    PwObjectTracker { objects: [ root.node ] }

    spacing: 5
    Layout.fillWidth: true
    Layout.bottomMargin: 15

    // Header row with app name and mute button
    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        Layout.leftMargin: 10
        Layout.rightMargin: 10

        // App name with smart fallback
        Text {
            Layout.fillWidth: true
            text: AudioService.nodeDisplayName(root.node)
            
            color: Styles.primary
            font.family: Styles.mainFont
            font.pixelSize: 13
            font.bold: true
            elide: Text.ElideRight
            opacity: root.node?.audio?.muted ? 0.5 : 1.0
            
            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }

        // Mute toggle button
        Rectangle {
            width: 24
            height: 24
            radius: 12
            color: muteMouse.containsMouse ? Styles.primary_container : "transparent"
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            Text {
                anchors.centerIn: parent
                text: root.node?.audio?.muted ? "🔇" : "🔊"
                color: Styles.primary
                font.pixelSize: 14
            }

            MouseArea {
                id: muteMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: AudioService.toggleNodeMute(root.node)
            }
        }
    }

    // Volume slider
    Slider {
        id: volumeSlider
        Layout.fillWidth: true
        Layout.preferredHeight: 16
        Layout.leftMargin: 10
        Layout.rightMargin: 10

        from: 0.0
        to: 1.0
        
        // Prevent binding loop: use internal value when dragging
        value: pressed ? value : AudioService.nodeVolume(root.node)
        
        onMoved: AudioService.setNodeVolume(root.node, value)

        background: Rectangle {
            x: volumeSlider.leftPadding
            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
            width: volumeSlider.availableWidth
            height: 4
            radius: 2
            color: Styles.primary_container
            
            // Fill indicator
            Rectangle {
                width: volumeSlider.visualPosition * parent.width
                height: parent.height
                color: Styles.primary
                radius: 2
                opacity: root.node?.audio?.muted ? 0.3 : 1.0
                
                Behavior on width {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.OutCubic
                    }
                }
                
                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }
        }
        
        handle: Rectangle {
            x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
            width: 12
            height: 12
            radius: 6
            color: Styles.primary
            opacity: root.node?.audio?.muted ? 0.5 : 1.0
            scale: volumeSlider.pressed ? 1.3 : 1.0
            
            Behavior on scale {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }
            
            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }
    }
}