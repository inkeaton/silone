// ToggleButton.qml - Reusable animated toggle button component
import QtQuick
import "../_styles"

Rectangle {
    id: root
    
    // -------------------------------------------------------------------------
    // Public API
    // -------------------------------------------------------------------------
    
    // The boolean property to toggle (use with alias or binding)
    property bool toggled: false
    
    // Dimensions
    property real buttonWidth: 24
    property real buttonHeight: 24
    
    // Text displayed inside the button
    property string textOn: "›"
    property string textOff: "‹"
    
    // Colors
    property color colorOn: Styles.primary_fixed
    property color colorOff: Styles.primary
    property color textColor: Styles.surface
    
    // Radius when on/off (allows morphing from circle to rounded rect)
    property real radiusOn: 6
    property real radiusOff: buttonHeight / 2  // Circle by default
    
    // Font settings
    property int fontSize: 14
    property bool fontBold: true
    
    // Hover scale factor
    property real hoverScale: 1.08
    
    // -------------------------------------------------------------------------
    // Signals
    // -------------------------------------------------------------------------
    
    signal clicked()
    
    // -------------------------------------------------------------------------
    // Internal
    // -------------------------------------------------------------------------
    
    implicitWidth: buttonWidth
    implicitHeight: buttonHeight
    
    // Dynamic properties based on toggle state
    radius: toggled ? radiusOn : radiusOff
    color: toggled ? colorOn : colorOff
    
    // Smooth color transition
    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    
    // Smooth radius transition
    Behavior on radius {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }
    
    // Click bounce animation
    SequentialAnimation {
        id: clickAnimation
        
        NumberAnimation {
            target: root
            property: "scale"
            to: 0.85
            duration: 80
            easing.type: Easing.OutCubic
        }
        
        NumberAnimation {
            target: root
            property: "scale"
            to: 1.0
            duration: 150
            easing.type: Easing.OutBack
            easing.overshoot: 1.5
        }
    }
    
    // -------------------------------------------------------------------------
    // Content
    // -------------------------------------------------------------------------
    
    // Toggle text/icon
    Text {
        anchors.centerIn: parent
        text: root.toggled ? root.textOn : root.textOff
        color: root.textColor
        font.pixelSize: root.fontSize
        font.bold: root.fontBold
        font.family: Styles.mainFont
        
        // Smooth text change (fade) - commented out
        // Behavior on text {
        //     SequentialAnimation {
        //         NumberAnimation { target: parent; property: "opacity"; to: 0; duration: 75 }
        //         PropertyAction { }
        //         NumberAnimation { target: parent; property: "opacity"; to: 1; duration: 75 }
        //     }
        // }
    }
    
    // -------------------------------------------------------------------------
    // Mouse Interaction
    // -------------------------------------------------------------------------
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            clickAnimation.start();
            root.toggled = !root.toggled;
            root.clicked();
        }
    }
}
