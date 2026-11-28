import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.services

// CPU and RAM usage with thin animated bars, click opens btop in the terminal
HoverButton {
    id: root

    baseColor: Theme.midnext
    fontSize: 16 * Theme.barScale
    labelOffsetY: -5 * Theme.barScale
    text: Icons.cpu + " " + Math.round(SystemStats.cpuUsage * 100) + "%  "
        + Icons.memory + " " + Math.round(SystemStats.memUsage * 100) + "%"

    onClicked: Quickshell.execDetached([Config.general.terminal, "-e", "btop"])

    component UsageBar: Rectangle {
        id: bar
        property real value: 0
        height: 4 * Theme.barScale
        radius: height / 2
        color: root.lit ? Theme.midnext : Theme.mid
        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width: parent.width * Math.max(0, Math.min(1, bar.value))
            radius: parent.radius
            color: bar.value > 0.85 ? Theme.red : (root.lit ? Theme.background : Theme.primary)
            Behavior on width { NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: Theme.animNormal } }
        }
    }

    UsageBar {
        value: SystemStats.cpuUsage
        anchors { left: parent.left; leftMargin: 10; bottom: parent.bottom; bottomMargin: 5 * Theme.barScale }
        width: (parent.width - 28) / 2
    }
    UsageBar {
        value: SystemStats.memUsage
        anchors { right: parent.right; rightMargin: 10; bottom: parent.bottom; bottomMargin: 5 * Theme.barScale }
        width: (parent.width - 28) / 2
    }
}
