import Quickshell
import Quickshell.Wayland
import QtQuick
import "../theme"

PanelWindow {
    exclusiveZone: 0
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
    color: "transparent"
    height: Screen.height /2
    anchors {
        top: true
        left: true
        right: true
    }
    FontLoader {
        id: sfFont
        source: "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    }
    Text {
	text: Qt.formatDateTime(clock.date, "hh:mm")
        font.family: sfFont.name
        font.pixelSize: 0.175 * Screen.height
        x: main.x - 10
        y: main.y + 10
        color: Theme.background
        width: implicitWidth
        height: 0.18 * Screen.height
        opacity: 0.1
    }
    Text {
        id: main
        text: Qt.formatDateTime(clock.date, "hh:mm")
        font.family: sfFont.name
        font.pixelSize: 0.175 * Screen.height
	    anchors.centerIn: parent
        color: Theme.text
        width: implicitWidth
        height: 0.18 * Screen.height
    }
    WlrLayershell.layer: WlrLayer.Bottom
    // aboveWindows: false
    mask: Region {}
}
