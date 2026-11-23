import QtQuick
import qs.config
import qs.services

// Current device with a list to pick another one
Column {
    id: root

    property var devices: []
    property var current: null
    property string emptyText: "No devices"
    property bool expanded: false
    readonly property bool selectable: devices.length > 1

    signal selected(var device)

    spacing: 4

    Rectangle {
        id: header
        width: parent.width
        height: 38
        radius: 14
        color: headerMouse.containsMouse && root.selectable ? Theme.midnext : Theme.mid
        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        Text {
            id: deviceIcon
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            text: root.current ? Audio.deviceIcon(root.current) : ""
            font.family: Theme.font
            font.pixelSize: 17
            color: Theme.text
        }
        Text {
            anchors {
                left: deviceIcon.right; leftMargin: 8
                right: chevron.left; rightMargin: 6
                verticalCenter: parent.verticalCenter
            }
            text: root.current ? Audio.deviceName(root.current) : root.emptyText
            font.family: Theme.font
            font.pixelSize: 14
            color: Theme.text
            elide: Text.ElideRight
        }
        Text {
            id: chevron
            visible: root.selectable
            anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
            text: Icons.chevron
            font.family: Theme.font
            font.pixelSize: 14
            color: Theme.text
            rotation: root.expanded ? 0 : -90
            Behavior on rotation { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
        }
        MouseArea {
            id: headerMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.selectable ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (root.selectable) root.expanded = !root.expanded
        }
    }

    Item {
        width: parent.width
        height: root.expanded && root.selectable ? list.implicitHeight + 4 : 0
        clip: true
        Behavior on height { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }

        Column {
            id: list
            y: 2
            width: parent.width
            spacing: 4

            Repeater {
                model: root.devices
                delegate: ListRow {
                    required property var modelData
                    width: list.width
                    text: Audio.deviceName(modelData)
                    trailing: root.current && modelData.id === root.current.id ? Icons.check : ""
                    active: root.current ? modelData.id === root.current.id : false
                    onClicked: { root.selected(modelData); root.expanded = false }
                }
            }
        }
    }
}
