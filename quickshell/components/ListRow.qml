import QtQuick
import qs.config

// Some tile highlight when active
Rectangle {
    id: root

    property string text: ""
    property string trailing: ""
    property bool active: false
    signal clicked()

    implicitHeight: 32
    radius: 12
    color: active ? Theme.primary : Theme.mid
    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Text {
        anchors { left: parent.left; leftMargin: 8; right: trailingText.left; rightMargin: 6; verticalCenter: parent.verticalCenter }
        text: root.text
        color: root.active ? Theme.background : Theme.text
        font.family: Theme.font
        font.pixelSize: 15
        elide: Text.ElideRight
    }
    Text {
        id: trailingText
        anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
        text: root.trailing
        color: root.active ? Theme.background : Theme.text
        font.family: Theme.font
        font.pixelSize: 14
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
