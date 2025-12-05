// BrightnessService.qml - Brightness control via brightnessctl
// NOTE: UNTESTED - cannot test right now
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // -------------------------------------------------------------------------
    // Public Properties
    // -------------------------------------------------------------------------
    
    // Current brightness (0.0 to 1.0)
    property real brightness: 0.0
    
    // Whether brightness control is available
    readonly property bool available: maxBrightness > 0
    
    // Internal: max brightness value from brightnessctl
    property int maxBrightness: 0
    property int currentBrightness: 0

    // -------------------------------------------------------------------------
    // Initialization
    // -------------------------------------------------------------------------
    
    Component.onCompleted: {
        initProc.running = true;
    }

    // Get max brightness on startup
    Process {
        id: initProc
        command: ["brightnessctl", "max"]
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(text.trim());
                if (!isNaN(val) && val > 0) {
                    root.maxBrightness = val;
                    // Now get current brightness
                    currentProc.running = true;
                }
            }
        }
    }

    // Get current brightness
    Process {
        id: currentProc
        command: ["brightnessctl", "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(text.trim());
                if (!isNaN(val)) {
                    root.currentBrightness = val;
                    root.brightness = root.maxBrightness > 0 
                        ? val / root.maxBrightness 
                        : 0;
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // File watcher for external brightness changes
    // Watches /sys/class/backlight/*/brightness
    // -------------------------------------------------------------------------
    
    // Poll for brightness changes (fallback since file watching can be tricky)
    Timer {
        id: pollTimer
        interval: 500
        running: root.available
        repeat: true
        onTriggered: {
            if (!setProc.running) {
                pollProc.running = true;
            }
        }
    }

    Process {
        id: pollProc
        command: ["brightnessctl", "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(text.trim());
                if (!isNaN(val) && val !== root.currentBrightness) {
                    root.currentBrightness = val;
                    const newBrightness = root.maxBrightness > 0 
                        ? val / root.maxBrightness 
                        : 0;
                    if (Math.abs(newBrightness - root.brightness) > 0.001) {
                        root.brightness = newBrightness;
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // Brightness Control Functions
    // -------------------------------------------------------------------------
    
    function clampBrightness(value) {
        return Math.max(0, Math.min(1, value));
    }

    Process {
        id: setProc
        property string pendingValue: ""
        command: ["brightnessctl", "set", pendingValue]
        
        onRunningChanged: {
            if (!running && pendingValue !== "") {
                // Refresh current value after setting
                pollProc.running = true;
            }
        }
    }

    function setBrightness(value) {
        if (!root.available)
            return false;
        
        const clamped = root.clampBrightness(value);
        const percent = Math.round(clamped * 100);
        
        // Update local value immediately for responsiveness
        root.brightness = clamped;
        root.currentBrightness = Math.round(clamped * root.maxBrightness);
        
        // Set via brightnessctl
        setProc.pendingValue = percent + "%";
        setProc.running = true;
        
        return true;
    }

    function adjustBrightness(delta) {
        return root.setBrightness(root.brightness + delta);
    }

    // Convenience functions for key bindings
    function increase(step = 0.05) {
        return root.adjustBrightness(step);
    }

    function decrease(step = 0.05) {
        return root.adjustBrightness(-step);
    }
}
