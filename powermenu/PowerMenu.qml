// PowerMenu.qml - Refactored with better process management
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQml.Models
import QtQuick.Layouts
import QtQuick.VectorImage
import "../_styles"
import "../_components"
import "../_components/animations" as Animations
import "../_utils"
import "../_config"

PanelWindow {
    id: powermenu

    implicitWidth: Config.powerMenu.width
    implicitHeight: Config.powerMenu.height
    color: "transparent"
    focusable: true
    visible: false
    
    // Overlay layer to appear above scrim
    WlrLayershell.layer: WlrLayer.Overlay

    // Process runner
    ProcessRunner { id: runner }
    PowerOptionsModel { id: powerOptions }

    // Focus management
    onVisibleChanged: {
        if (visible) {
            optionGrid.currentIndex = 0;
            optionGrid.forceActiveFocus();
        }
    }

    // Outer wrapper
    PanelFrame {
        id: panelFrame
        anchors.fill: parent
        outerColor: Styles.surface
        innerColor: Styles.primary_container
        outerRadius: 50
        innerRadius: 30
        frameMargin: 20

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
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
                        model: powerOptions

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

    // Delegate component
    Component {
        id: optionDelegate

        Item {
            id: delegateRoot

            width: optionGrid.cellWidth
            height: optionGrid.cellHeight

            PowerActionButton {
                anchors.fill: parent
                iconSource: model.icon
                command: model.command
                current: GridView.isCurrentItem
                accessibleName: model.name || "Power option"
                onTriggered: (cmd) => {
                    if (cmd && cmd.length > 0) {
                        executeCommand(cmd);
                    }
                }
            }
        }
    }

    // Helper function to execute commands
    function executeCommand(command) {
        if (!command || command.length === 0) return;

        if (runner.run(command))
            powermenu.visible = false;
    }
}