// MediaPlayer.qml - MPRIS media player control (Material Design inspired)
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
    Layout.preferredHeight: 140

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

    // Progress bar properties
    // Detect streams: either length not supported, or length is very long (>3.5 hours = likely a stream)
    property real trackLength: hasPlayer && player.lengthSupported ? player.length : 0
    property bool isStream: hasPlayer && (!player.lengthSupported || trackLength > 12600)
    property bool canShowProgress: hasPlayer && player.positionSupported && player.lengthSupported && !isStream
    property bool canSeek: hasPlayer && player.canSeek && !isStream
    
    // Album art crossfade
    property string currentArt: ""
    property string previousArt: ""
    property real currentArtOpacity: 1.0
    property real prevArtOpacity: 0.0
    
    onArtUrlChanged: {
        if (artUrl !== currentArt) {
            previousArt = currentArt;
            currentArt = artUrl;
            // Instantly set opacities, then animate
            prevArtOpacity = 1.0;
            currentArtOpacity = 0.0;
            artTransitionTimer.restart();
        }
    }
    
    Timer {
        id: artTransitionTimer
        interval: 50  // Small delay to ensure properties are set
        onTriggered: {
            root.currentArtOpacity = 1.0;
            root.prevArtOpacity = 0.0;
        }
    }
    
    // Format time as mm:ss
    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds < 0) return "--:--";
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return mins.toString().padStart(2, '0') + ":" + secs.toString().padStart(2, '0');
    }
    
    // Update position when playing (uses FrameAnimation for smooth updates)
    FrameAnimation {
        running: root.hasPlayer && root.player.playbackState === MprisPlaybackState.Playing
        onTriggered: {
            if (root.player) {
                root.player.positionChanged();
            }
        }
    }

    // Main visual container
    Item {
        anchors.fill: parent

        // Previous album art (fades out)
        Image {
            id: prevAlbumArt
            anchors.fill: parent
            source: root.previousArt
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            visible: false
        }

        // Current album art (fades in)
        Image {
            id: albumArt
            anchors.fill: parent
            source: root.currentArt
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

        // Previous art (fading out)
        MultiEffect {
            id: prevArtEffect
            anchors.fill: parent
            source: prevAlbumArt
            maskEnabled: true
            maskSource: artMask
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
            visible: root.previousArt !== "" && opacity > 0
            opacity: root.prevArtOpacity
            
            Behavior on opacity {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }

        // Current art (fading in)
        MultiEffect {
            id: currentArtEffect
            anchors.fill: parent
            source: albumArt
            maskEnabled: true
            maskSource: artMask
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
            visible: root.currentArt !== ""
            opacity: root.currentArtOpacity
            
            Behavior on opacity {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }

        // Dark overlay scrim
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: root.currentArt !== "" ? 0.5 : 0.7
            radius: 28
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }

        // Fallback pattern when no album art
        Item {
            anchors.fill: parent
            visible: root.currentArt === ""
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

                // Progress bar with time display
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    spacing: 4
                    visible: root.hasPlayer
                    
                    // Progress slider
                    Slider {
                        id: progressSlider
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        
                        from: 0.0
                        to: root.canShowProgress ? Math.max(root.player.length, 1) : 1.0
                        
                        // Track position, but don't update while dragging
                        value: pressed ? value : (root.canShowProgress ? root.player.position : 0)
                        
                        enabled: root.canSeek
                        opacity: root.canShowProgress ? 1.0 : 0.5
                        
                        onMoved: {
                            if (root.canSeek && root.canShowProgress) {
                                root.player.position = value;
                            }
                        }

                        background: Rectangle {
                            x: progressSlider.leftPadding
                            y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                            width: progressSlider.availableWidth
                            height: 4
                            radius: 2
                            color: "#40FFFFFF"
                            
                            // Progress fill
                            Rectangle {
                                width: progressSlider.visualPosition * parent.width
                                height: parent.height
                                color: Styles.primary
                                radius: 2
                                
                                Behavior on width {
                                    enabled: !progressSlider.pressed
                                    NumberAnimation { duration: 100 }
                                }
                            }
                        }
                        
                        handle: Rectangle {
                            x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                            y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                            width: 12
                            height: 12
                            radius: 6
                            color: Styles.primary
                            visible: root.canSeek
                            scale: progressSlider.pressed ? 1.3 : (progressSlider.hovered ? 1.15 : 1.0)
                            
                            Behavior on scale {
                                NumberAnimation { duration: 100 }
                            }
                        }
                    }
                    
                    // Time labels
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        // Current position
                        Text {
                            text: root.canShowProgress 
                                ? root.formatTime(root.player.position)
                                : (root.isStream ? "LIVE" : "--:--")
                            color: "#DDDDDD"
                            font.family: Styles.mainFont
                            font.pixelSize: 11
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Track length
                        Text {
                            text: root.canShowProgress 
                                ? root.formatTime(root.player.length)
                                : (root.isStream ? "∞" : "--:--")
                            color: "#DDDDDD"
                            font.family: Styles.mainFont
                            font.pixelSize: 11
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