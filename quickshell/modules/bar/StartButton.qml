import QtQuick
import qs.components
import qs.config
import qs.services

// Button with distro icon
HoverButton {
    width: height
    baseColor: Theme.midnext
    idleForeground: Theme.primary
    text: Icons.distro
    fontSize: 33
    labelScale: hovered ? 1 : 0.75
    active: UiState.controlCenterOpen
    onClicked: UiState.toggleControlCenter()
}
