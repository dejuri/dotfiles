pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// CPU and RAM usage, read from /proc every 2 seconds
Singleton {
    id: root

    property real cpuUsage: 0   // 0..1
    property real memUsage: 0   // 0..1
    property real memUsedGb: 0
    property real memTotalGb: 0

    property var _prev: null

    function _parseStat(text) {
        const first = text.split("\n")[0].trim().split(/\s+/).slice(1).map(Number)
        if (first.length < 5) return
        const idle = first[3] + first[4]            // idle + iowait
        const total = first.reduce((a, b) => a + b, 0)
        if (_prev) {
            const dt = total - _prev.total
            const di = idle - _prev.idle
            cpuUsage = dt > 0 ? Math.max(0, Math.min(1, 1 - di / dt)) : 0
        }
        _prev = { total: total, idle: idle }
    }

    function _parseMem(text) {
        const t = text.match(/MemTotal:\s+(\d+)/)
        const a = text.match(/MemAvailable:\s+(\d+)/)
        if (!t || !a) return
        const total = Number(t[1]), avail = Number(a[1])
        memUsage = total > 0 ? 1 - avail / total : 0
        memTotalGb = total / 1048576
        memUsedGb = (total - avail) / 1048576
    }

    FileView { id: statFile; path: "/proc/stat";    onLoaded: root._parseStat(text()) }
    FileView { id: memFile;  path: "/proc/meminfo"; onLoaded: root._parseMem(text()) }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { statFile.reload(); memFile.reload() }
    }
}
