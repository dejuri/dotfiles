import QtQuick
import qs.config

// Battery icon with a waving liquid inside
Item {
    id: root

    property real level: 0.5
    property bool charging: false
    property bool low: false
    property bool lit: false
    property bool animated: true

    readonly property color ink: lit ? Theme.background : Theme.primary
    readonly property color liquid: low ? Theme.red : ink

    property real shown: level
    Behavior on shown { NumberAnimation { duration: 900; easing.type: Easing.OutCubic } }

    property real phase: 0
    NumberAnimation on phase {
        from: 0; to: Math.PI * 2
        duration: root.charging ? 1400 : 2600
        loops: Animation.Infinite
        running: root.visible && root.animated
    }

    property real pulse: 1
    SequentialAnimation {
        running: root.low
        loops: Animation.Infinite
        NumberAnimation { target: root; property: "pulse"; to: 0.35; duration: 600; easing.type: Easing.InOutSine }
        NumberAnimation { target: root; property: "pulse"; to: 1; duration: 600; easing.type: Easing.InOutSine }
        onRunningChanged: if (!running) root.pulse = 1
    }

    onPhaseChanged: canvas.requestPaint()
    onShownChanged: canvas.requestPaint()
    onLiquidChanged: canvas.requestPaint()

    readonly property real nubWidth: Math.max(2, width * 0.08)
    readonly property real borderWidth: Math.max(1.5, height * 0.12)

    Rectangle {
        id: body
        width: root.width - root.nubWidth - 1
        height: root.height
        radius: height * 0.32
        color: "transparent"
        border.width: root.borderWidth
        border.color: root.ink
        opacity: root.pulse
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

        Canvas {
            id: canvas
            anchors.fill: parent
            anchors.margins: root.borderWidth + 1
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            Component.onCompleted: requestPaint()

            function wave(ctx, w, h, top, amp, ph, cycles, style) {
                ctx.beginPath()
                ctx.moveTo(0, h)
                for (let x = 0; x <= w; x += 1)
                    ctx.lineTo(x, top + Math.sin(x / w * Math.PI * 2 * cycles + ph) * amp)
                ctx.lineTo(w, h)
                ctx.closePath()
                ctx.fillStyle = style
                ctx.fill()
            }

            onPaint: {
                const ctx = getContext("2d")
                const w = width, h = height
                ctx.clearRect(0, 0, w, h)
                const lvl = root.shown
                if (lvl <= 0.01 || w <= 0 || h <= 0) return

                ctx.save()
                ctx.beginPath()
                ctx.roundedRect(0, 0, w, h, body.radius * 0.6, body.radius * 0.6)
                ctx.clip()

                const top = h * (1 - lvl)
                
                // flat surface when full or almost empty
                const edge = Math.min(1, lvl * 8, (1 - lvl) * 8)
                const amp = h * 0.16 * edge
                const c = root.liquid
                wave(ctx, w, h, top, amp, root.phase + 1.9, 1.1, Qt.rgba(c.r, c.g, c.b, 0.4))
                wave(ctx, w, h, top, amp * 0.85, -root.phase, 1.5, c)
                ctx.restore()
            }
        }
    }

    // Battery terminal
    Rectangle {
        x: body.width + 1
        anchors.verticalCenter: body.verticalCenter
        width: root.nubWidth
        height: root.height * 0.4
        radius: width / 2
        color: root.ink
        opacity: root.pulse
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }
}
