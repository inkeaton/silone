// Styles.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
	id: root
    readonly property string mainFont: "SF Pro Rounded"
    readonly property int fontSize: 24

    readonly property string main: "#E50C63"
    readonly property string surface: "#261D1F"

    readonly property string error: "#FFB4AB"
    readonly property string error_container: "#93000A"

    readonly property string primary: "#FFB2BE"
    readonly property string primary_fixed: "#FFD9DE"
    readonly property string primary_container: "#713340"
    readonly property string on_primary: "#561D2A"

    readonly property string secondary: "#E4BDC2 "
    readonly property string secondary_container: "#5C3F44"
    readonly property string on_secondary: "#43292E"

    readonly property string tertiary: "#EBBE90"
    readonly property string tertiary_container: "#5F411C"
    readonly property string on_tertiary: "#452B08"
}