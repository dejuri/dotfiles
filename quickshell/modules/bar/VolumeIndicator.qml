import QtQuick
import qs.components
import qs.config
import qs.services

// Volume control, left click opens sound menu, right/middle click mutes, mouse wheel changes volume
HoverButton {
    id: root

    baseColor: Theme.midnext
    fontSize: 16 * Theme.barScale
    labelOffsetY: -8 * Theme.barScale
    text: Audio.muted ? Audio.icon + " няма" : Audio.icon + " " + Math.round(Audio.volume * 100) + "%"
    active: UiState.volumeMenuOpen
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton) UiState.toggleVolumeMenu()
        else Audio.toggleMute()
    }
    onScrolled: wheel => Audio.step(wheel.angleDelta.y > 0 ? 0.05 : -0.05)

    Rectangle {
        anchors { left: parent.left; bottom: parent.bottom; leftMargin: 10; bottomMargin: 6 * Theme.barScale }
        width: parent.width - 20
        height: 6 * Theme.barScale
        radius: height / 2
        color: root.lit ? Theme.midnext : Theme.mid
        Behavior on color { ColorAnimation { duration: Theme.animFast; easing.type: Easing.InOutQuad } }

        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width: parent.width * Audio.volume
            radius: 3
            color: root.lit ? Theme.background : (Audio.muted ? Theme.midnext : Theme.primary)
            Behavior on width { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: Theme.animFast; easing.type: Easing.InOutQuad } }
        }
    }
}
