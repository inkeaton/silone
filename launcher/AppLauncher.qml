// AppLauncher.qml - Refactored with improvements
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models
import "../_styles"
import "fuzzySearch.js" as FuzzySearch

PanelWindow {
    id: launcher
    implicitWidth: 600
    implicitHeight: 380
    color: "transparent"
    focusable: true
    visible: false

    onVisibleChanged: {
        if (visible) {
            search.text = "";
            appList.currentIndex = 0;
            search.forceActiveFocus();
        }
    }

    WrapperRectangle {
        id: wrapTrasp
        color: Styles.surface
        anchors.fill: parent
        radius: 50

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
                spacing: 10

                anchors {
                    leftMargin: 25
                    rightMargin: 25
                    topMargin: 16
                }

                // Search field
                TextField {
                    id: search
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50

                    placeholderText: "Di cosa hai bisogno?"

                    onTextChanged: {
                        appList.currentIndex = 0;
                        searchDebounceTimer.restart();
                    }

                    enabled: true
                    focus: true
                    activeFocusOnPress: true
                    leftPadding: 20
                    color: Styles.on_primary

                    font: Qt.font({
                        pixelSize: 20,
                        family: Styles.mainFont,
                        bold: true
                    })

                    background: Rectangle {
                        color: Styles.primary
                        radius: 50
                        implicitWidth: 200
                        implicitHeight: 50
                    }

                    // Keyboard navigation
                    Keys.onPressed: (event) => {
                        switch (event.key) {
                            case Qt.Key_Escape:
                                launcher.visible = false;
                                event.accepted = true;
                                break;

                            case Qt.Key_Return:
                            case Qt.Key_Enter:
                                if (appListModel.count > 0) {
                                    let item = appListModel.get(appList.currentIndex);
                                    item.app.execute();
                                    launcher.visible = false;
                                }
                                event.accepted = true;
                                break;

                            case Qt.Key_Down:
                                appList.incrementCurrentIndex();
                                event.accepted = true;
                                break;

                            case Qt.Key_Up:
                                appList.decrementCurrentIndex();
                                event.accepted = true;
                                break;
                        }
                    }
                }

                // Debounce timer for search
                Timer {
                    id: searchDebounceTimer
                    interval: 100
                    repeat: false
                    onTriggered: updateAppList()
                }

                // Content switcher
                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: appListModel.count > 0 ? 0 : 1

                    // App list
                    ListView {
                        id: appList
                        clip: true
                        focus: false
                        keyNavigationWraps: true
                        cacheBuffer: 500

                        model: appListModel

                        highlight: Rectangle {
                            color: Styles.surface
                            radius: 50
                        }
                        highlightFollowsCurrentItem: true
                        highlightMoveDuration: 100

                        delegate: Item {
                            id: delegateRoot
                            implicitWidth: appList.width
                            implicitHeight: 50

                            required property int index
                            required property var modelData

                            readonly property bool isCurrent: ListView.isCurrentItem

                            opacity: isCurrent ? 1.0 : 0.7

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Text {
                                leftPadding: 15
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                elide: Text.ElideRight
                                text: delegateRoot.modelData.app.name
                                color: Styles.primary

                                font: Qt.font({
                                    pixelSize: 20,
                                    family: Styles.mainFont
                                })
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    appList.currentIndex = delegateRoot.index;
                                    delegateRoot.modelData.app.execute();
                                    launcher.visible = false;
                                }
                            }
                        }
                    }

                    // Empty state
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10
                        implicitWidth: parent.width - 40

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "🔍"
                            font.pixelSize: 90
                            color: Styles.primary
                            opacity: 0.5
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: search.text.length > 0
                                ? "Nessuna applicazione trovata"
                                : "Inizia a digitare per cercare"
                            color: Styles.primary
                            opacity: 0.7

                            font: Qt.font({
                                pixelSize: 25,
                                family: Styles.mainFont
                            })

                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: parent.width - 40
                            text: search.text.length > 0
                                ? "Prova con un altro termine di ricerca"
                                : "Puoi cercare applicazioni per nome"
                            color: Styles.primary
                            opacity: 0.5

                            font: Qt.font({
                                pixelSize: 18,
                                family: Styles.mainFont
                            })

                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }

    // App list model
    ListModel {
        id: appListModel
    }

// Initialize the app list when component is complete
    Component.onCompleted: {
        updateAppList()
    }

    // Function to update the app list model
    function updateAppList() {
        let results = FuzzySearch.filterAndSortApps(
            DesktopEntries.applications.values,
            search.text
        )
        
        // Clear and repopulate the model
        appListModel.clear()
        
        // Limit results to improve performance (optional)
        const maxResults = 50
        const limitedResults = results.slice(0, maxResults)
        
        for (let i = 0; i < limitedResults.length; i++) {
            appListModel.append({
                app: limitedResults[i].app,
                score: limitedResults[i].score
            })
        }
        
        // Reset selection to first item if available
        if (appListModel.count > 0) {
            appList.currentIndex = 0
        }
    }

    // Watch for changes in desktop entries
    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            updateAppList()
        }
    }
}

    // Initialize on component completion