// SystemTray.qml - Fixed & Refactored
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../_styles/"

RowLayout {
    id: trayRow
    spacing: 8

    anchors.centerIn: parent

    Repeater {
        model: SystemTray.items

        Item {
            id: iconContainer

            required property SystemTrayItem modelData

            implicitWidth: 20
            implicitHeight: 20

            // Hover effect background
            Rectangle {
                id: hoverEffect
                anchors.fill: parent
                radius: 4
                color: Styles.primary
                opacity: 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // Primary icon
            IconImage {
                id: icon
                anchors.centerIn: parent
                width: 16
                height: 16
                source: iconContainer.modelData.icon
                visible: status === Image.Ready
            }

            // Tooltip
            ToolTip {
                id: toolTip
                popupType: Popup.Native
                y: iconContainer.implicitHeight * 2
                delay: 500

                contentItem: Text {
                    text: toolTip.text
                    color: Styles.primary
                    font.capitalization: Font.Capitalize
                    font.family: Styles.mainFont
                    font.pixelSize: 12
                }

                background: Rectangle {
                    color: Styles.surface
                    radius: 6
                }
            }

            // Context menu anchor
            QsMenuAnchor {
                id: menuAnchor
                anchor.item: iconContainer
                anchor.gravity: Edges.Bottom | Edges.Left
                menu: iconContainer.modelData.menu
            }

            // Mouse interaction
            MouseArea {
                id: mouseArea
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                hoverEnabled: true
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        iconContainer.modelData.activate();
                    } else if (mouse.button === Qt.RightButton) {
                        menuAnchor.open();
                    } else if (mouse.button === Qt.MiddleButton) {
                        iconContainer.modelData.secondaryActivate();
                    }
                }

                onEntered: {
                    // Show hover effect
                    hoverEffect.opacity = 0.15;

                    // Build tooltip text
                    let tooltipText = iconContainer.modelData.tooltipTitle;
                    if (!tooltipText || tooltipText === "") {
                        tooltipText = iconContainer.modelData.title || "System Tray Item";
                    }

                    // Append description if available
                    if (iconContainer.modelData.tooltipDescription &&
                        iconContainer.modelData.tooltipDescription !== "") {
                        tooltipText += "\n" + iconContainer.modelData.tooltipDescription;
                    }

                    toolTip.show(tooltipText);
                }

                onExited: {
                    hoverEffect.opacity = 0;
                    toolTip.hide();
                }

                onPressed: {
                    hoverEffect.opacity = 0.25;
                }

                onReleased: {
                    hoverEffect.opacity = mouseArea.containsMouse ? 0.15 : 0;
                }
            }
        }
    }
}