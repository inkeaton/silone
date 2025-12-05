// MediaPlayer.qml - MPRIS media player control
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Mpris
import "../_styles"
import "../_components"

Item {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 125

    // Player management
    property var playersList: Mpris.players.values
    property int playerIndex: 0
    property var player: {
        if (!playersList || playersList.length === 0) return null;
        const idx = Math.abs(playerIndex % playersList.length);
        return playersList[idx];
    }
    property bool hasPlayer: !!player

    // Watch for player changes
    onPlayersListChanged: {
        if (playerIndex >= playersList.length) playerIndex = 0;
        findPlayingMedia();
    }

    Component.onCompleted: findPlayingMedia()

    // Auto-select playing media
    function findPlayingMedia() {
        if (!playersList) return;
        
        for (let i = 0; i < playersList.length; i++) {
            if (playersList[i] && 
                playersList[i].playbackState === MprisPlaybackState.Playing) {
                root.playerIndex = i;
                return;
            }
        }
    }

    // Cycle between available players
    function cyclePlayer() {
        if (playersList && playersList.length > 0) {
            playerIndex = (playerIndex + 1) % playersList.length;
        }
    }

    // Metadata properties
    property string title: (hasPlayer && player.trackTitle) 
        ? player.trackTitle 
        : "No Media"
    property string artist: (hasPlayer && player.trackArtist) 
        ? player.trackArtist 
        : "Select a player"
    property string artUrl: (hasPlayer && player.metadata["mpris:artUrl"]) 
        ? player.metadata["mpris:artUrl"] 
        : ""
    property real currentVolume: (hasPlayer && player.volume !== undefined) 
        ? player.volume 
        : 1.0

    // Main visual container
    Item {
        anchors.fill: parent

        // Album art background with mask
        Image {
            id: albumArt
            anchors.fill: parent
            source: root.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            visible: false
        }

        // Rounded mask for album art
        Item {
            id: artMask
            anchors.fill: parent
            layer.enabled: true
            layer.smooth: true
            visible: false
            
            Rectangle {
                anchors.fill: parent
                radius: 28
                color: "black"
            }
        }

        // Masked album art
        MultiEffect {
            anchors.fill: parent
            source: albumArt
            maskEnabled: true
            maskSource: artMask
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
            visible: root.artUrl !== ""
        }

        // Dark overlay scrim
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: root.artUrl !== "" ? 0.5 : 1.0
            radius: 28
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }

        // Fallback pattern when no album art
        Item {
            anchors.fill: parent
            visible: root.artUrl === ""
            opacity: 0.1

            Repeater {
                model: 5
                
                Text {
                    x: Math.random() * parent.width
                    y: Math.random() * parent.height
                    text: "🎵"
                    font.pixelSize: 40
                    rotation: Math.random() * 360
                    color: Styles.primary
                }
            }
        }

        // Content layout
        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Left side: Info & controls
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                // Player switcher (only if multiple players)
                Rectangle {
                    visible: root.playersList && root.playersList.length > 1
                    Layout.alignment: Qt.AlignLeft
                    Layout.bottomMargin: 4
                    height: 24
                    width: 24
                    radius: 12
                    color: sourceMouse.containsMouse ? "#60FFFFFF" : "#30FFFFFF"
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⇄"
                        color: "white"
                        font.pixelSize: 14
                    }
                    
                    MouseArea {
                        id: sourceMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.cyclePlayer()
                    }
                }

                // Track title
                Text {
                    text: root.title
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    color: "white"
                    font.family: Styles.mainFont
                    font.pixelSize: 18
                    font.bold: true
                }

                // Artist name
                Text {
                    text: root.artist
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    color: "#DDDDDD"
                    font.family: Styles.mainFont
                    font.pixelSize: 14
                }

                // Volume control
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    Layout.bottomMargin: 5
                    Layout.preferredHeight: 20
                    spacing: 8
                    visible: root.hasPlayer

                    Text {
                        text: "🔊"
                        color: "#CCCCCC"
                        font.pixelSize: 12
                    }

                    Slider {
                        id: volSlider
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        
                        from: 0.0
                        to: 1.0
                        
                        // Prevent binding loop
                        value: pressed ? value : root.currentVolume
                        
                        onMoved: {
                            if (root.hasPlayer && root.player.volume !== undefined) {
                                root.player.volume = value;
                            }
                        }

                        background: Rectangle {
                            x: volSlider.leftPadding
                            y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                            width: volSlider.availableWidth
                            height: 4
                            radius: 2
                            color: "#50FFFFFF"
                            
                            Rectangle {
                                width: volSlider.visualPosition * parent.width
                                height: parent.height
                                color: "white"
                                radius: 2
                            }
                        }
                        
                        handle: Rectangle {
                            x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                            y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                            width: 10
                            height: 10
                            radius: 5
                            color: "white"
                            scale: volSlider.pressed ? 1.3 : 1.0
                            
                            Behavior on scale {
                                NumberAnimation { duration: 100 }
                            }
                        }
                    }
                }
            }

            // Right side: Play/Pause button
            ToggleButton {
                buttonWidth: 56
                buttonHeight: 56
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                
                toggled: root.hasPlayer && root.player.playbackState === MprisPlaybackState.Playing
                
                textOn: "⏸"
                textOff: "▶"
                fontSize: 24
                
                // White background, black text
                colorOn: "white"
                colorOff: "white"
                textColor: "black"
                
                // Circle when paused, rounded rect when playing
                radiusOn: 28
                radiusOff: 16
                
                onClicked: {
                    if (!root.hasPlayer) return;
                    
                    if (root.player.canTogglePlaying) {
                        root.player.togglePlaying();
                    } else {
                        if (root.player.playbackState === MprisPlaybackState.Playing) {
                            root.player.pause();
                        } else {
                            root.player.play();
                        }
                    }
                }
            }
        }
    }
}