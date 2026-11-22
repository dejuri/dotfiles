pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property int barCount: 100
    property bool active: true
    property var barLevels: new Array(barCount).fill(0)

    readonly property string cavaConfig: [
        "[general]",
        "bars = " + root.barCount,
        "framerate = 30",
        "[output]",
        "method = raw",
        "raw_target = /dev/stdout",
        "data_format = ascii",
        "ascii_max_range = 1000",
        "bar_delimiter = 59",
        "frame_delimiter = 10"
    ].join("\\n")

    Process {
        id: cavaProcess
        running: root.active

        command: [
            "bash", "-c",
            "cava -p <(printf '" + root.cavaConfig + "\\n')"
        ]

        stdout: SplitParser {
            onRead: data => {
                const tokens = data.trim().split(";")
                if (tokens.length < 2) return

                const next = new Array(root.barCount)
                for (let i = 0; i < root.barCount; i++) {
                    const raw = parseInt(tokens[i]) || 0
                    next[i] = Math.max(0, Math.min(1, raw / 1000))
                }
                root.barLevels = next
            }
        }
    }
}