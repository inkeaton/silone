// ClickOutsideCatcher.qml - Focus grab with visual scrim for popup dismissal
// Uses HyprlandFocusGrab for click detection + PanelWindow for darkening effect
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

Scope {
    id: root
    
    // The popup window to monitor - when clicked outside, this will be hidden
    required property var popup
    
    // Optional scrim (darkening) opacity. Set to 0 for invisible overlay.
    property real scrimOpacity: 0.3
    
    // Visual scrim overlay (darkening effect)
    PanelWindow {
        id: scrim
        
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        
        // Use Overlay layer to appear above normal windows
        WlrLayershell.layer: WlrLayer.Overlay
        
        // Only visible when popup is visible
        visible: root.popup !== null && root.popup.visible
        
        // Semi-transparent dark scrim
        color: Qt.rgba(0, 0, 0, root.scrimOpacity)
        
        // Don't reserve space
        exclusionMode: ExclusionMode.Ignore
        
        // Click on scrim closes the popup
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.popup) {
                    root.popup.visible = false;
                }
            }
        }
    }
    
    // Focus grab for click-outside detection (for clicks outside scrim too)
    HyprlandFocusGrab {
        id: focusGrab
        
        // Only the popup receives normal input - clicking scrim or outside closes
        windows: root.popup ? [root.popup] : []
        
        // Active when popup is visible
        active: root.popup !== null && root.popup.visible
        
        // When focus grab is cleared (user clicked outside scrim), close the popup
        onCleared: {
            if (root.popup) {
                root.popup.visible = false;
            }
        }
    }
}
