import QtQuick
import qs.config
import qs.services

Item {
    id: root
    property bool mirrored: false
    property color barColor: Theme.primary
    property real barWidth: Config.dock.cavaWidth
    property real barSpacing: 3

    readonly property int visibleCount:
        Math.max(0, Math.floor((width + barSpacing) / (barWidth + barSpacing)))

    readonly property var levels: resample(Cava.barLevels, visibleCount)

    function resample(src, n) {
        const out = new Array(Math.max(0, n))
        const N = src.length
        if (n <= 0 || N === 0) return out

        const step = N / n
        for (let i = 0; i < n; i++) {
            const a = i * step
            const b = a + step
            let sum = 0
            for (let j = Math.floor(a); j < Math.ceil(b) && j < N; j++) {
                sum += src[j] * (Math.min(b, j + 1) - Math.max(a, j))
            }
            out[i] = sum / step
        }
        return out
    }

    visible: width > 40

    Row {
        anchors.fill: parent
        spacing: root.barSpacing
        layoutDirection: root.mirrored ? Qt.RightToLeft : Qt.LeftToRight

        Repeater {
            model: root.visibleCount

            Item {
                id: cell
                required property int index
                readonly property real level: root.levels[index] ?? 0

                width: root.barWidth
                height: root.height

                Rectangle {
                    width: parent.width
                    height: Math.max(2, cell.level * cell.height)
                    anchors.bottom: parent.bottom

                    color: root.barColor
                    opacity: cell.level
                    Behavior on height { NumberAnimation { duration: Theme.animFast }}
                }
            }
        }
    }
}