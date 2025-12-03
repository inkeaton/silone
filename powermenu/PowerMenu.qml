// PowerMenu.qml - Refactored with better process management
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQml.Models
import QtQuick.Layouts
import QtQuick.VectorImage
import "../_styles"

PanelWindow {
    id: powermenu

    width: 350
    height: 430
    color: "transparent"
    focusable: true
    visible: false

    // Process runner
    Process {
        id: runner
        running: false
    }

    // Focus management
    onVisibleChanged: {
        if (visible) {
            optionGrid.currentIndex = 0;
            optionGrid.forceActiveFocus();
        }
    }

    // Outer wrapper
    WrapperRectangle {
        id: wrapTrasp
        color: Styles.surface
        anchors.fill: parent
        radius: 50

        // Inner wrapper
        WrapperRectangle {
            id: wrap
            color: Styles.primary_container
            radius: 30
            clip: true

            anchors {
                fill: parent
                margins: 20
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.preferredWidth: 260
                    Layout.preferredHeight: 50
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    Layout.bottomMargin: 10
                    radius: 50
                    color: Styles.primary

                    Text {
                        anchors.centerIn: parent
                        text: "Vai già via?"
                        color: Styles.on_primary
                        font: Qt.font({
                            pixelSize: 20,
                            family: Styles.mainFont,
                            bold: true
                        })
                    }
                }

                // Grid container
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    GridView {
                        id: optionGrid
                        focus: true

                        anchors {
                            fill: parent
                            margins: 20
                        }

                        // Layout
                        readonly property int spacing: 16
                        readonly property int columns: 2

                        cellWidth: Math.floor(width / columns)
                        cellHeight: Math.floor(width / columns)

                        // Data
                        model: ListModel {
                            ListElement {
                                name: "Poweroff"
                                icon: "../_styles/icons/pow/accensione.svg"
                                command: "systemctl poweroff"
                            }
                            ListElement {
                                name: "Reboot"
                                icon: "../_styles/icons/pow/riavvio.svg"
                                command: "systemctl reboot"
                            }
                            ListElement {
                                name: "Lockscreen"
                                icon: "../_styles/icons/pow/accensione.svg"
                                command: "loginctl lock-session"
                            }
                            ListElement {
                                name: "Logout"
                                icon: "../_styles/icons/pow/accensione.svg"
                                command: "hyprctl dispatch exit"
                            }
                        }

                        // Highlight
                        highlight: Rectangle {
                            color: Styles.surface
                            radius: 50

                            Behavior on x {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutCubic
                                }
                            }
                            Behavior on y {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                        highlightFollowsCurrentItem: true

                        delegate: optionDelegate

                        // Keyboard navigation
                        Keys.onPressed: (event) => {
                            switch (event.key) {
                                case Qt.Key_Escape:
                                    powermenu.visible = false;
                                    event.accepted = true;
                                    break;

                                case Qt.Key_Return:
                                case Qt.Key_Enter:
                                    executeCurrentCommand();
                                    event.accepted = true;
                                    break;

                                case Qt.Key_Down:
                                    moveCurrentIndexDown();
                                    event.accepted = true;
                                    break;

                                case Qt.Key_Up:
                                    moveCurrentIndexUp();
                                    event.accepted = true;
                                    break;

                                case Qt.Key_Left:
                                    moveCurrentIndexLeft();
                                    event.accepted = true;
                                    break;

                                case Qt.Key_Right:
                                    moveCurrentIndexRight();
                                    event.accepted = true;
                                    break;
                            }
                        }

                        // Execute command helper
                        function executeCurrentCommand() {
                            if (currentIndex >= 0 && currentIndex < count) {
                                const item = model.get(currentIndex);
                                if (item && item.command && item.command.length > 0) {
                                    executeCommand(item.command);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Delegate component
    Component {
        id: optionDelegate

        Item {
            id: delegateRoot

            width: optionGrid.cellWidth
            height: optionGrid.cellHeight

            readonly property bool isCurrent: GridView.isCurrentItem
            readonly property bool isHovered: mouseArea.containsMouse

            scale: isCurrent ? 1.05 : (isHovered ? 1.02 : 1.0)
            opacity: isCurrent ? 1.0 : (isHovered ? 0.9 : 0.7)

            Behavior on scale {
                NumberAnimation {
                    duration: 170
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 170
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (model.command && model.command.length > 0) {
                        executeCommand(model.command);
                    }
                }

                Rectangle {
                    color: "transparent"
                    radius: 50

                    anchors {
                        fill: parent
                        margins: optionGrid.spacing / 2
                    }

                    VectorImage {
                        id: optionIcon
                        source: model.icon
                        width: 100
                        height: 100
                        fillMode: Image.PreserveAspectFit
                        preferredRendererType: VectorImage.CurveRenderer
                        anchors.centerIn: parent

                        Accessible.role: Accessible.Button
                        Accessible.name: model.name || "Power option"
                        Accessible.description: model.command || ""
                    }
                }
            }
        }
    }

    // Helper function to execute commands
    function executeCommand(command) {
        if (!command || command.length === 0) return;

        const cmdArray = command.split(" ");
        runner.command = cmdArray;
        runner.running = true;
        powermenu.visible = false;
    }
}