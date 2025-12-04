// ProcessRunner.qml - reusable helper for launching commands safely
import QtQuick
import Quickshell.Io

Item {
    id: root
    width: 0
    height: 0
    visible: false

    property alias running: process.running

    Process {
        id: process
        running: false
    }

    function run(command, options) {
        const normalized = normalizeCommand(command)
        if (!normalized) {
            console.warn("ProcessRunner: invalid command", command)
            return false
        }

        process.command = normalized
        const opts = options || {}
        if (opts.cwd !== undefined)
            process.cwd = opts.cwd
        if (opts.env !== undefined)
            process.environment = opts.env
        process.running = true
        return true
    }

    function normalizeCommand(command) {
        if (Array.isArray(command) && command.length > 0)
            return command
        if (typeof command === "string" && command.trim().length > 0)
            return command.trim().split(/\s+/)
        return null
    }
}
