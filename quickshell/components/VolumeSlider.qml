import QtQuick
import qs.config

// Volume slider: drag or scroll to change, click on the icon to mute
Rectangle {
    id: root

    property real value: 0
    property string icon: ""
    property bool muted: false
    property bool compact: false
    property bool showPercent: true
    property real wheelStep: 0.05

    signal moved(real value)
    signal iconClicked()

    readonly property bool dragging: drag.pressed

    implicitHeight: compact ? 30 : 40
    radius: height / 2
    color: Theme.mid

    Rectangle {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: root.height + (root.width - root.height) * Math.max(0, Math.min(1, root.value))
        radius: root.radius
        color: root.muted ? Theme.midnext : Theme.primary
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on width {
            enabled: !root.dragging
            NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
        }
    }

    // Slider area, covers everything so dragging can leave the edges
    MouseArea {
        id: drag
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function setFromX(x) {
            const v = (x - root.height / 2) / (root.width - root.height)
            root.moved(Math.max(0, Math.min(1, v)))
        }
        onPressed: m => setFromX(m.x)
        onPositionChanged: m => { if (pressed) setFromX(m.x) }
        onWheel: w => root.moved(Math.max(0, Math.min(1, root.value + (w.angleDelta.y > 0 ? root.wheelStep : -root.wheelStep))))
    }

    // Icon button, above the slider area so it takes clicks first
    Item {
        id: iconBox
        width: root.height
        height: root.height

        Rectangle {
            anchors.centerIn: parent
            width: parent.width - 8
            height: width
            radius: width / 2
            color: Theme.background
            opacity: iconMouse.containsMouse ? 0.25 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
        }
        Text {
            anchors.centerIn: parent
            text: root.icon
            font.family: Theme.font
            font.pixelSize: root.compact ? 14 : 18
            color: root.muted ? Theme.text : Theme.background
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }
        MouseArea {
            id: iconMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.iconClicked()
        }
    }

    Text {
        visible: root.showPercent
        anchors { right: parent.right; rightMargin: root.compact ? 10 : 14; verticalCenter: parent.verticalCenter }
        text: Math.round(root.value * 100) + "%"
        font.family: Theme.font
        font.pixelSize: root.compact ? 12 : 14
        color: (!root.muted && root.value > 0.9) ? Theme.background : Theme.text
        opacity: root.muted ? 0.6 : 1
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }
}
