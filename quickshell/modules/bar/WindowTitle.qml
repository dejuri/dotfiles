import QtQuick
import qs.components
import qs.config
import qs.services

// Just focused window title, has animation if too long
MarqueeText {
    text: NiriEvents.focusedWindowTitle ?? ""
    font.pixelSize: 16
}
