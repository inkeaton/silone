// Time.qml
pragma Singleton

import Quickshell
import QtQuick
import "../_config"

Singleton {
	id: root
	// an expression can be broken across multiple lines using {}
	readonly property string time: {
		// The passed format string matches the default output of
		// the `date` command.
		Qt.formatDateTime(clock.date, Config.bar.clockFormat)
	}

	SystemClock {
		id: clock
		precision: SystemClock.Minutes
	}
}