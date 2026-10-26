import QtQuick
import qs.config

Item {
    id: root

    property string iconName: ""
    property bool showHighlight: false
    property bool focused: false
    property alias acceptedButtons: mouse.acceptedButtons
    readonly property bool hovered: mouse.containsMouse
    signal clicked(var mouse)

    readonly property real cell: Theme.dockCell

    readonly property real lift: cell * 0.08
    readonly property real hoverLift: cell * 0.04
    readonly property real iconScale: 0.93
    readonly property real iconHoverScale: 1.13
    readonly property real circleSize: cell * 0.94
    readonly property real baseCenterY: cell / 2 - lift

    width: cell
    height: cell

    // Focus circle
    Rectangle {
        id: circle
        visible: root.showHighlight
        width: root.circleSize
        height: width
        radius: width / 2
        x: (root.cell - width) / 2
        y: root.baseCenterY - height / 2
        color: Theme.primary
        scale: root.focused ? 1 : 0.8
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    Image {
        id: icon
        width: root.cell
        height: root.cell
        x: 0
        y: root.baseCenterY - height / 2 - (root.hovered ? root.hoverLift : 0)
        source: Paths.icon(root.iconName.toLowerCase())
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        sourceSize: Qt.size(128, 128)
        scale: root.hovered ? root.iconHoverScale : root.iconScale
        visible: status === Image.Ready

        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        onStatusChanged: if (status === Image.Error) source = Paths.icon("x-executable")
    }
    Text {
        x: (root.cell - width) / 2
        y: root.baseCenterY - height / 2
        visible: icon.status !== Image.Ready
        text: root.iconName.length ? root.iconName[0].toUpperCase() : "?"
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: root.cell * 0.5
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: m => root.clicked(m)
    }
    Rectangle {
        visible: root.showHighlight
        width: root.focused ? root.cell * 0.21 : root.cell * 0.1
        height: Math.max(3, root.cell * 0.1)
        radius: height
        color: Theme.text
        x: (root.cell - width) / 2
        y: root.baseCenterY + root.circleSize / 2 + root.cell * 0.05
        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    }
}