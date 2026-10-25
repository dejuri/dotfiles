import QtQuick
import qs.config

// Round button that changes curves and color on mouse interaction
Rectangle {
    id: root

    property string text: ""
    property int fontSize: 18
    property color baseColor: Theme.mid
    property color hoverColor: Theme.primary
    property color idleForeground: Theme.text
    property real baseRadius: height / 2
    property real hoverRadius: 5
    property real labelScale: 1
    property real labelOffsetY: 0
    property bool active: false
    property int acceptedButtons: Qt.LeftButton

    readonly property bool hovered: mouse.containsMouse
    readonly property bool lit: hovered || active
    readonly property color foreground: lit ? Theme.background : idleForeground

    signal clicked(var mouse)
    signal scrolled(var wheel)

    implicitHeight: 50
    implicitWidth: 50
    color: lit ? hoverColor : baseColor
    radius: lit ? hoverRadius : baseRadius

    Behavior on color { ColorAnimation { duration: Theme.animFast; easing.type: Easing.InOutQuad } }
    Behavior on radius { NumberAnimation { duration: Theme.animFast; easing.type: Easing.InOutQuad } }

    Text {
        id: label
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.labelOffsetY
        text: root.text
        visible: root.text !== ""
        color: root.foreground
        font.family: Theme.font
        font.pixelSize: root.fontSize
        scale: root.labelScale
        Behavior on color { ColorAnimation { duration: Theme.animFast; easing.type: Easing.InOutQuad } }
        Behavior on scale { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: root.acceptedButtons
        onClicked: m => root.clicked(m)
        onWheel: w => root.scrolled(w)
    }
}
