import QtQuick
import qs.config

// Text animation for focused window title
Item {
    id: root

    property alias text: label.text
    property alias color: label.color
    property alias font: label.font

    clip: true
    implicitHeight: label.implicitHeight

    Text {
        id: label
        x: 0
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: 16

        readonly property bool overflowing: width > root.width
        readonly property real endX: root.width - width - 10

        onTextChanged: x = 0
        onOverflowingChanged: if (!overflowing) x = 0

        SequentialAnimation {
            running: label.overflowing
            loops: Animation.Infinite
            PauseAnimation { duration: 1200 }
            NumberAnimation { target: label; property: "x"; to: label.endX; duration: 4000; easing.type: Easing.InOutQuad }
            PauseAnimation { duration: 1200 }
            NumberAnimation { target: label; property: "x"; to: 0; duration: 4000; easing.type: Easing.InOutQuad }
        }
    }
}
