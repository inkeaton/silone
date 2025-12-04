import QtQuick
import QtQuick.Layouts
import "../_styles/"
import "../_services"
import "../_components/animations" as Animations

Rectangle {
    id: notifDelegate

    // -------------------------------------------------------------------------
    // Data & Config
    // -------------------------------------------------------------------------
    // Repeater injects 'modelData' automatically. We require it.
    required property var modelData
    
    // Alias it to 'notification' so the rest of your code works as expected.
    readonly property var notification: modelData

    property real windowWidth: 350
    property bool bodyMarkupSupported: true

    // Safely calculate duration. If missing, default to 5000ms.
    property int totalDuration: (notification && notification.timeout > 0) 
                                ? notification.timeout 
                                : 5000

    // -------------------------------------------------------------------------
    // Visuals
    // -------------------------------------------------------------------------
    width: windowWidth
    height: notifLayout.implicitHeight + 20
    color: Styles.surface
    radius: 25
    
    // Clip is essential for the slide animation to look clean
    clip: true 

    // Initial state for entry animation
    opacity: 0
    transform: Translate {
        id: slideTransform
        x: 400
    }

    // -------------------------------------------------------------------------
    // Timer Logic (Optimized)
    // -------------------------------------------------------------------------
    // We use a NumberAnimation instead of a Timer. It's smoother (60fps) and 
    // handles the "pause on hover" logic natively.
    
    property real progress: 0.0 // 0.0 to 1.0

    NumberAnimation on progress {
        id: timerAnim
        from: 0.0
        to: 1.0
        duration: notifDelegate.totalDuration
        running: true
        // Pause if mouse is inside the notification
        paused: notifMouseArea.containsMouse
    }

    // Dismiss when progress finishes
    onProgressChanged: {
        if (progress >= 1.0) {
            dismissAnimation.start();
        }
    }

    // -------------------------------------------------------------------------
    // Entry/Exit Animations
    // -------------------------------------------------------------------------
    Component.onCompleted: {
        slideInAnimation.start();
    }

    ParallelAnimation {
        id: slideInAnimation
        NumberAnimation { target: slideTransform; property: "x"; to: 0; duration: 300; easing.type: Easing.OutCubic }
        Animations.FadeInFast { target: notifDelegate; property: "opacity"; to: 1 }
    }

    SequentialAnimation {
        id: dismissAnimation
        
        ParallelAnimation {
            NumberAnimation { target: slideTransform; property: "x"; to: 400; duration: 250; easing.type: Easing.InCubic }
            Animations.FadeOutFast { target: notifDelegate; property: "opacity"; to: 0 }
        }

        ScriptAction {
            // Safely call dismiss
            script: if (notification) notification.dismiss()
        }
    }

    // -------------------------------------------------------------------------
    // Content
    // -------------------------------------------------------------------------
    MouseArea {
        id: notifMouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
    }

    ColumnLayout {
        id: notifLayout
        anchors {
            left: parent.left; right: parent.right; top: parent.top
            leftMargin: 20; rightMargin: 20; topMargin: 10
        }
        spacing: 8

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // App Icon
                Image {
                id: notifIcon
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                
                readonly property string fallbackIcon: Icons.notificationIcon(notification?.summary, notification?.urgency)

                // Safe source lookups
                source: (notification?.image) ? notification.image : 
                    (notification?.appIcon) ? notification.appIcon : 
                    (fallbackIcon.length > 0 ? fallbackIcon : "")
                
                // Explicit boolean check for visibility
                visible: !!source && source.toString().length > 0
                
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: true
            }

            // App Name
            Text {
                // Safe text access
                text: notification?.appName || "System"
                font.pixelSize: 13
                font.family: Styles.mainFont
                font.bold: true
                color: Styles.primary
                Layout.fillWidth: true
            }

            // Close Button & Progress
            Item {
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50

                Canvas {
                    id: progressCanvas
                    anchors.fill: parent
                    
                    // Trigger repaint when progress changes
                    property real p: notifDelegate.progress
                    onPChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d");
                        var centerX = width / 2;
                        var centerY = height / 2;
                        var radius = 12;
                        
                        // Invert progress for the visual (1.0 -> 0.0)
                        var drawProgress = 1 - notifDelegate.progress;

                        ctx.clearRect(0, 0, width, height);
                        ctx.beginPath();
                        ctx.arc(centerX, centerY, radius, -Math.PI / 2, 
                                -Math.PI / 2 + (2 * Math.PI * drawProgress), false);
                        ctx.lineWidth = 8; // Thinner line looks cleaner
                        ctx.strokeStyle = Styles.primary;
                        ctx.globalAlpha = 0.4;
                        ctx.stroke();
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    radius: 12
                    color: dismissArea.containsMouse ? Styles.primary_container : Styles.primary
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        font.pixelSize: 18
                        font.family: Styles.mainFont
                        font.bold: true
                        color: dismissArea.containsMouse ? Styles.primary : Styles.primary_container
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    MouseArea {
                        id: dismissArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: dismissAnimation.start();
                    }
                }
            }
        }

        // Summary
        Text {
            text: notification?.summary || ""
            font.pixelSize: 17
            font.family: Styles.mainFont
            font.bold: true
            color: Styles.primary_fixed
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            
            // Strict boolean check
            visible: text.length > 0
            textFormat: Text.PlainText
        }

        // Body
        Text {
            text: notification?.body || ""
            bottomPadding: 10
            font.pixelSize: 14
            font.family: Styles.mainFont
            color: Styles.primary
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            
            textFormat: bodyMarkupSupported ? Text.StyledText : Text.PlainText
            // Strict boolean check
            visible: text.length > 0
        }

        // Actions
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            // Check for array existence and length
            visible: (notification && notification.actions && notification.actions.length > 0)

            Repeater {
                // Safe model access
                model: (notification && notification.actions) ? notification.actions : []

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    color: actionMouseArea.containsMouse ? Styles.primary_container : Styles.primary
                    radius: 16

                    Text {
                        anchors.centerIn: parent
                        text: modelData.text
                        font.pixelSize: 14
                        font.family: Styles.mainFont
                        font.bold: true
                        color: actionMouseArea.containsMouse ? Styles.primary : Styles.primary_container
                    }

                    MouseArea {
                        id: actionMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            modelData.invoke();
                            dismissAnimation.start();
                        }
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }
    }
}