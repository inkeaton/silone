import QtQuick
import QtQuick.Layouts
import "../_styles"

Item {
    id: trayMaster
    
    // Calculate width: Button + (Content + Spacing if open)
    implicitHeight: 24
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
     
        // Toggle Button using the new ToggleButton component
        ToggleButton {
            id: trayButton
            Layout.alignment: Qt.AlignVCenter
            
            toggled: trayMaster.trayOpen
            onClicked: trayMaster.trayOpen = !trayMaster.trayOpen
            
            // Button appearance
            buttonWidth: 24
            buttonHeight: 24
            
            // Arrow icons
            textOn: "›"
            textOff: "‹"
            
            // When open: rounded rect, when closed: circle
            radiusOn: 6
            radiusOff: 12
            
            // Colors
            colorOn: Styles.primary_fixed
            colorOff: Styles.primary
            textColor: Styles.surface
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