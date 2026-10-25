import QtQuick
import qs.config

// Expandable tile that is used in control center
Column {
    id: root

    property string text: ""
    property string subtitle: ""
    property bool checked: false
    property bool expanded: false
    property int fontSize: 16

    signal toggled()

    default property alias content: body.data

    spacing: 4

    Rectangle {
        id: tile
        width: parent.width
        height: 50
        radius: 16
        color: root.checked ? Theme.primary : Theme.mid
        Behavior on color { ColorAnimation { duration: Theme.animFast; easing.type: Easing.InOutQuad } }

        readonly property color fg: root.checked ? Theme.background : Theme.text

        Row {
            anchors { left: parent.left; leftMargin: 10; right: chevron.left; rightMargin: 4; verticalCenter: parent.verticalCenter }
            spacing: 8
            Text {
                text: root.text
                font.family: Theme.font
                font.pixelSize: root.fontSize
                color: tile.fg
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
            Text {
                visible: root.subtitle !== ""
                text: root.subtitle
                font.family: Theme.font
                font.pixelSize: 13
                color: tile.fg
                elide: Text.ElideRight
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors { left: parent.left; right: chevron.left; top: parent.top; bottom: parent.bottom }
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggled()
        }

        Item {
            id: chevron
            anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
            width: 40
            Text {
                anchors.centerIn: parent
                text: Icons.chevron
                font.family: Theme.font
                font.pixelSize: 14
                color: tile.fg
                rotation: root.expanded ? 0 : -90
                Behavior on rotation { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.expanded = !root.expanded
            }
        }
    }

    Item {
        width: parent.width
        height: root.expanded ? body.implicitHeight + 8 : 0
        clip: true
        Behavior on height { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }

        Column {
            id: body
            y: 6
            width: parent.width
            spacing: 4
        }
    }
}
