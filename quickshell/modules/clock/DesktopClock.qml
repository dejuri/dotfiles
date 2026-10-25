import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

// Clock desktop widget
Scope {
    LazyLoader {
        active: Config.bar.desktopClock

        PanelWindow {
            id: win
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.namespace: "quickshell:desktop-clock"
            exclusiveZone: 0
            color: "transparent"
            mask: Region {}
            implicitHeight: screen.height / 2
            anchors { top: true; left: true; right: true }

            SystemClock { id: clock; precision: SystemClock.Minutes }
            FontLoader { id: fontLoader; source: Paths.font(Theme.clockFont) }

            readonly property string timeText: Qt.formatDateTime(clock.date, "hh:mm")
            readonly property real fontSize: screen.height * 0.175

            Text {
                text: win.timeText
                font.family: fontLoader.name
                font.pixelSize: win.fontSize
                anchors.centerIn: parent
                color: Config.bar.darkClock ? Theme.background : Theme.text
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
        }
    }
}
