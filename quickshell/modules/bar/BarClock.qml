import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.services

// Clock in bar center
HoverButton {
    id: root

    SystemClock { id: clock; precision: SystemClock.Seconds }

    implicitWidth: label.implicitWidth + 64
    implicitHeight: 34
    baseColor: Theme.midnext
    baseRadius: 14
    active: UiState.launcherOpen
    onClicked: UiState.toggleLauncher()

    Behavior on implicitWidth { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.InOutQuad } }

    Text {
        id: label
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, Config.bar.clockFormat)
        color: root.foreground
        font.family: Theme.font
        font.pixelSize: 20
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }
}
