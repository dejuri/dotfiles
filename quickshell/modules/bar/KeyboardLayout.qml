import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.services

// Keyboard layouts, click changes to next
HoverButton {
    baseColor: Theme.midnext
    text: NiriEvents.keyboardLayoutName
    fontSize: 17
    labelOffsetY: -2
    onClicked: Quickshell.execDetached(["niri", "msg", "action", "switch-layout", "next"])
}
