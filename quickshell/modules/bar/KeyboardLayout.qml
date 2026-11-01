import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.services

// Keyboard layouts, click changes to next
HoverButton {
    baseColor: Theme.midnext
    text: NiriEvents.keyboardLayoutName
    fontSize: 17 * Theme.barScale
    labelOffsetY: -2 * Theme.barScale
    onClicked: Quickshell.execDetached(["niri", "msg", "action", "switch-layout", "next"])
}
