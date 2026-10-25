import QtQuick
import qs.config

// The volume control in control center
Rectangle {
    id: root

    property real value: 0
    property string icon: ""
    signal moved(real value)

    implicitHeight: 40
    radius: height / 2
    color: Theme.mid

    Rectangle {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: root.height + (root.width - root.height) * Math.max(0, Math.min(1, root.value))
        radius: root.radius
        color: Theme.primary
        Behavior on width { NumberAnimation { duration: 80 } }
    }

    Text {
        x: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon
        font.family: Theme.font
        font.pixelSize: 16
        color: Theme.background
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function setFromX(x) {
            const v = (x - root.height / 2) / (root.width - root.height)
            root.moved(Math.max(0, Math.min(1, v)))
        }
        onPressed: m => setFromX(m.x)
        onPositionChanged: m => { if (pressed) setFromX(m.x) }
    }
}
