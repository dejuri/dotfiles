import QtQuick
import qs.components
import qs.config
import qs.services

// Just volume control in bar, very simple idea, mouse wheel to change, click to mute
HoverButton {
    id: root

    baseColor: Theme.midnext
    fontSize: 16
    labelOffsetY: -8
    text: Audio.muted ? Icons.volumeMuted + " няма" : Icons.volumeHigh + " " + Math.round(Audio.volume * 100) + "%"

    onClicked: Audio.toggleMute()
    onScrolled: wheel => Audio.step(wheel.angleDelta.y > 0 ? 0.05 : -0.05)

    Rectangle {
        anchors { left: parent.left; bottom: parent.bottom; leftMargin: 10; bottomMargin: 6 }
        width: parent.width - 20
        height: 6
        radius: 3
        color: Theme.background

        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width: parent.width * Audio.volume
            radius: 3
            color: Theme.lightest
            Behavior on width { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
        }
    }
}
