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
    height:1440 / 2
    anchors {
        top: true
        left: true
        right: true
    }

    FontLoader {
        id: sfFont
        source: Qt.resolvedUrl("../../fonts/" + Theme.clock_font + ".ttf")
    }
    
    Text {
        text: Qt.formatDateTime(clock.date, "hh:mm")
        font.family: sfFont.name
        font.pixelSize: 0.175 *1440
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -10
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 10
        color: Theme.background
        opacity: 0.1
    }

    Text {
        id: main
        text: Qt.formatDateTime(clock.date, "hh:mm")
        font.family: sfFont.name
        font.pixelSize: 0.175 *1440
        anchors.centerIn: parent
        color: Theme.text
    }

    WlrLayershell.layer: WlrLayer.Bottom
    mask: Region {}
}