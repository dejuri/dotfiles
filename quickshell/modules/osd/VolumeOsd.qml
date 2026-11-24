import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

// Small popup with volume level appears when volume or mute changes
Scope {
    id: root

    property bool shown: false
    property bool ready: false
    property real sinkChangedAt: 0

    Timer { interval: 2000; running: true; onTriggered: root.ready = true }

    Connections {
        target: Audio
        function onSinkChanged() { root.sinkChangedAt = Date.now() }
        function onVolumeChanged() { check.restart() }
        function onMutedChanged() { check.restart() }
    }

    Timer {
        id: check
        interval: 40
        onTriggered: {
            if (!root.ready || !Config.sound.osdEnabled) return
            if (Date.now() - root.sinkChangedAt < 300) return
            root.shown = true
            hideTimer.restart()
        }
    }
    Timer {
        id: hideTimer
        interval: Config.sound.osdTimeout
        onTriggered: root.shown = false
    }

    PanelWindow {
        visible: root.shown || card.opacity > 0
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        anchors.bottom: true
        margins.bottom: (Config.dock.enabled ? Config.dock.height : 0) + 24
        implicitWidth: 280
        implicitHeight: 64

        mask: Region {}
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:osd"

        Rectangle {
            id: card
            anchors.centerIn: parent
            width: 260
            height: 52
            radius: height / 2
            color: Theme.background
            opacity: root.shown ? 1 : 0
            scale: root.shown ? 1 : 0.92
            Behavior on opacity { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }

            Text {
                id: icon
                x: 18
                anchors.verticalCenter: parent.verticalCenter
                text: Audio.icon
                font.family: Theme.font
                font.pixelSize: 22
                color: Theme.text
            }

            Rectangle {
                id: track
                anchors {
                    left: icon.right; leftMargin: 14
                    right: percent.left; rightMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                height: 8
                radius: 4
                color: Theme.mid

                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    width: parent.width * Audio.volume
                    radius: 4
                    color: Audio.muted ? Theme.midnext : Theme.primary
                    Behavior on width { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }
            }

            Text {
                id: percent
                anchors { right: parent.right; rightMargin: 18; verticalCenter: parent.verticalCenter }
                width: 44
                horizontalAlignment: Text.AlignRight
                text: Audio.muted ? "mute" : Math.round(Audio.volume * 100) + "%"
                font.family: Theme.font
                font.pixelSize: 15
                color: Audio.muted ? Theme.lighter : Theme.text
            }
        }
    }
}
