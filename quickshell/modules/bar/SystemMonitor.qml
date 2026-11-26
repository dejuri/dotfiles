import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.services

// CPU and RAM usage, click opens btop in the terminal
HoverButton {
    id: root
    baseColor: Theme.midnext
    fontSize: 14 * Theme.barScale
    labelOffsetY: -2 * Theme.barScale
    text: Icons.cpu + " CPU: " + Math.round(SystemStats.cpuUsage * 100) + "%  " + Icons.memory + " MEM: " + Math.round(SystemStats.memUsage * 100) + "%"
    onClicked: Quickshell.execDetached([Config.general.terminal, "-e", "btop"])
}
