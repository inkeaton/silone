// BrightnessOSD.qml - Arc-style brightness indicator
// NOTE: UNTESTED - User cannot test right now
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

    // Track previous brightness to detect changes
    property real previousBrightness: BrightnessService.brightness

    // Show the panel whenever BrightnessService reports a change
    Connections {
        target: BrightnessService

        function onBrightnessChanged() {
            // Only show OSD if brightness actually changed significantly
            if (Math.abs(BrightnessService.brightness - root.previousBrightness) > 0.001) {
                root.previousBrightness = BrightnessService.brightness;
                root.shouldShowOsd = true;
                root.panelActive = true;
                root.bounceTrigger++;
                hideTimer.restart();
            }
        }
    }

    // State properties
    property bool shouldShowOsd: false
    property bool panelActive: false

    // Current brightness (0.0 to 1.0)
    property real brightnessValue: BrightnessService.brightness

    // Hide timer
    Timer {
        id: hideTimer
        interval: Config.osd.hideDelay
        onTriggered: {
            root.shouldShowOsd = false;
        }
    }

    // Animated brightness value for smooth arc tweening
    property real animatedBrightness: brightnessValue
    Behavior on animatedBrightness {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    // Trigger for icon bounce
    property int bounceTrigger: 0

    // Lazy-loaded OSD panel
    LazyLoader {
        active: root.panelActive

        PanelWindow {
            // Positioning (same as VolumeOSD)
            anchors.bottom: true
            margins.bottom: screen.height / 14
            exclusiveZone: 0

            implicitWidth: 240
            implicitHeight: 200
            color: "transparent"
            mask: Region {}

            // Main panel rectangle
            Rectangle {
                id: panelRect
                anchors.fill: parent
                radius: 28
                color: Styles.surface

                // Slide transform
                transform: Translate {
                    id: slideTransform
                    y: 48
                }

                // Arc container
                Item {
                    id: arcContainer
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 15
                    width: 180
                    height: 180

                    // Arc properties
                    property real arcRadius: 72
                    property real arcWidth: 14
                    // Arc spans 240° (66.67%), gap at bottom
                    // Start: -210° (-7π/6), End: 30° (π/6)
                    property real startAngle: -210 * (Math.PI / 180)
                    property real endAngle: 30 * (Math.PI / 180)
                    property real totalSweep: endAngle - startAngle  // 240° = 4π/3

                    // Background arc (shows maximum)
                    Canvas {
                        id: bgArc
                        anchors.fill: parent

                        onPaint: {
                            var ctx = getContext("2d");
                            var centerX = width / 2;
                            var centerY = height / 2;
                            
                            ctx.clearRect(0, 0, width, height);
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, arcContainer.arcRadius, 
                                    arcContainer.startAngle, arcContainer.endAngle, false);
                            ctx.lineWidth = arcContainer.arcWidth;
                            ctx.lineCap = "round";
                            ctx.strokeStyle = Styles.primary;
                            ctx.globalAlpha = 0.25;
                            ctx.stroke();
                        }

                        Component.onCompleted: requestPaint()
                    }

                    // Active brightness arc
                    Canvas {
                        id: brightnessArc
                        anchors.fill: parent

                        property real brightness: root.animatedBrightness
                        onBrightnessChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d");
                            var centerX = width / 2;
                            var centerY = height / 2;
                            
                            // Calculate end angle based on animated brightness
                            var brightnessAngle = arcContainer.startAngle + 
                                (arcContainer.totalSweep * root.animatedBrightness);

                            ctx.clearRect(0, 0, width, height);
                            
                            if (root.animatedBrightness > 0.01) {
                                ctx.beginPath();
                                ctx.arc(centerX, centerY, arcContainer.arcRadius,
                                        arcContainer.startAngle, brightnessAngle, false);
                                ctx.lineWidth = arcContainer.arcWidth;
                                ctx.lineCap = "round";
                                ctx.strokeStyle = Styles.primary;
                                ctx.globalAlpha = 1.0;
                                ctx.stroke();
                            }
                        }

                        Component.onCompleted: requestPaint()
                    }

                    // Brightness icon (centered)
                    VectorImage {
                        id: brightnessIcon
                        anchors.centerIn: parent
                        source: "../_styles/icons/brightness.svg"
                        width: 90
                        height: 90
                        fillMode: Image.PreserveAspectFit
                        preferredRendererType: VectorImage.CurveRenderer
                        
                        scale: 1.0

                        // Watch for bounce trigger
                        Connections {
                            target: root
                            function onBounceTriggerChanged() {
                                iconBounceAnim.restart();
                            }
                        }

                        // Icon bounce animation
                        SequentialAnimation {
                            id: iconBounceAnim
                            NumberAnimation {
                                target: brightnessIcon
                                property: "scale"
                                to: 1.1
                                duration: 80
                                easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                target: brightnessIcon
                                property: "scale"
                                to: 1.0
                                duration: 200
                                easing.type: Easing.OutBack
                                easing.overshoot: 2
                            }
                        }
                    }
                }

                // Brightness label
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 12
                    text: "Luminosità"
                    font.pixelSize: 16
                    font.family: Styles.mainFont
                    font.bold: true
                    color: Styles.primary
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
