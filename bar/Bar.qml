// Bar.qml - Refactored
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "./modules" // bar components
import "../_styles/"
import "../_systems/"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            color: "transparent"

            required property var modelData

            implicitHeight: 40
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            // Bar background
            Rectangle {
                id: background
                anchors.fill: parent
                color: Styles.surface

                // Left section
                RowLayout {
                    id: leftrow
                    spacing: 8

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 16
                    }

                    Workspaces {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    }
                }

                // Center section
                RowLayout {
                    id: centerrow
                    spacing: 8
                    anchors.centerIn: parent

                    Clock {}
                }

                // Right section
                RowLayout {
                    id: rightrow
                    spacing: 12

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 16
                    }

                    // KeyboardLayout {
                    //     Layout.alignment: Qt.AlignVCenter
                    // }

                    Tray {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        SystemTray {}
                    }
                }
            }
        }
    }
}