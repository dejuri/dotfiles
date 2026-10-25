import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services

// Niri workspace service
Item {
    id: root
    implicitWidth: row.width + 30
    implicitHeight: 34

    Rectangle {
        anchors.fill: parent
        radius: 15
        color: Theme.midnext
        Behavior on width { NumberAnimation { duration: 200 } }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: NiriService.workspaces

            Rectangle {
                id: ws
                property bool hovered: false
                implicitWidth: 23
                implicitHeight: 21
                scale: hovered || model.isActive ? 1 : 0.5
                radius: hovered ? 5 : 40
                color: model.isActive ? Theme.primary : Theme.mid
                visible: index < 10

                Behavior on color { ColorAnimation { duration: Theme.animNormal; easing.type: Easing.InOutQuad } }
                Behavior on scale { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
                Behavior on radius { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NiriService.focusWorkspace(model.id)
                    onEntered: ws.hovered = true
                    onExited: ws.hovered = false
                }
            }
        }
    }
}
