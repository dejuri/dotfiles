import QtQuick
import qs.components
import qs.config
import qs.services

// Power off, reboot, logout and lock
Row {
    id: root
    signal actionTriggered()

    spacing: 8

    HoverButton { text: Icons.power; onClicked: Power.poweroff() }
    HoverButton { text: Icons.reboot; onClicked: Power.reboot() }
    HoverButton { text: Icons.logout; onClicked: Power.logout() }
    HoverButton { text: Icons.lock; onClicked: { Power.lock(); root.actionTriggered() } }
}
