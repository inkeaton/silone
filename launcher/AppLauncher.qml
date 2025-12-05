// AppLauncher.qml - Refactored with improvements
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models
import "../_styles"
import "../_components"
import "../_components/animations" as Animations
import "../_config"
import "fuzzySearch.js" as FuzzySearch

PanelWindow {
    id: launcher
    implicitWidth: Config.launcher.width
    implicitHeight: Config.launcher.height
    color: "transparent"
    focusable: true
    visible: false
    
    // Overlay layer to appear above scrim
    WlrLayershell.layer: WlrLayer.Overlay

    onVisibleChanged: {
        if (visible) {
            search.text = "";
            appList.currentIndex = 0;
            search.forceActiveFocus();
        }
    }

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
                    interval: Config.launcher.searchDebounceMs
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

                        property int previousIndex: -1
                        property bool skipWrapAnimation: false

                        model: appListModel

                        highlight: Rectangle {
                            color: Styles.surface
                            radius: 50
                        }
                        highlightFollowsCurrentItem: true
                        highlightMoveDuration: skipWrapAnimation ? 0 : 150
                        highlightResizeDuration: skipWrapAnimation ? 0 : 120

                        onCurrentIndexChanged: {
                            const count = appListModel.count;
                            if (count <= 1) {
                                previousIndex = currentIndex;
                                skipWrapAnimation = false;
                                return;
                            }

                            if (previousIndex === -1) {
                                previousIndex = currentIndex;
                                skipWrapAnimation = false;
                                return;
                            }

                            const lastIndex = count - 1;
                            const wrapped = (previousIndex === 0 && currentIndex === lastIndex)
                                || (previousIndex === lastIndex && currentIndex === 0);

                            if (wrapped) {
                                skipWrapAnimation = true;
                                Qt.callLater(() => skipWrapAnimation = false);
                            } else {
                                skipWrapAnimation = false;
                            }

                            previousIndex = currentIndex;
                        }

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
                    Item {
                        // Wrapper needed because StackLayout manages children
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 10
                            width: parent.width - 40

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
                    }  // Close Item wrapper
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
        const maxResults = 100
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