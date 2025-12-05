import QtQuick
import QtQuick.Layouts
import "../_styles"

Item {
    id: trayMaster
    
    // Calculate width: Button + (Content + Spacing if open)
    implicitHeight: 20
    implicitWidth: trayButton.width + (trayOpen ? (container.implicitWidth + layout.spacing) : 0)
    
    // Allows putting SystemTray {} inside Tray {} in Bar.qml
    default property alias content: container.children
    
    property bool trayOpen: false
    
    // Prevent icons from floating outside when closing
    clip: true 

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
    
    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 8 
     
        // Toggle Button (Always visible)
        Rectangle {
            id: trayButton
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 20
            implicitHeight: 20
            radius: trayOpen ? 4 : 30 // Circle normally
            
            // Visual feedback for open state
            color: trayOpen ? Styles.primary_fixed : Styles.primary
            
            Behavior on color { ColorAnimation { duration: 150 } }
            
            // Arrow icon
            Text {
                anchors.centerIn: parent
                text: trayOpen ? "›" : "‹" // Simple arrow toggle
                color: Styles.surface
                font.pixelSize: 14
                font.bold: true
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: trayMaster.trayOpen = !trayMaster.trayOpen
            }
        }
        
        // Content Container (Collapsible)
        Item {
            id: trayContentWrapper
            Layout.fillHeight: true
            Layout.fillWidth: true
            
            visible: trayMaster.trayOpen
            opacity: trayMaster.trayOpen ? 1.0 : 0.0
            
            // Width logic handled by parent implicitWidth, 
            // but we can ensure it doesn't take space when hidden
            Layout.preferredWidth: container.implicitWidth

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            
            RowLayout {
                id: container
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
            }
        }
    }
}