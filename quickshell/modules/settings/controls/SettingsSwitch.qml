import QtQuick
import qs.config

Rectangle {
    id: root
    property bool checked: false
    signal toggled(bool value)

    width: 46; height: 26; radius: 13
    color: checked ? Theme.primary : Theme.midnext
    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Rectangle {
        width: 20; height: 20; radius: 10
        y: 3
        x: root.checked ? parent.width - width - 3 : 3
        color: root.checked ? Theme.background : Theme.text
        Behavior on x { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
