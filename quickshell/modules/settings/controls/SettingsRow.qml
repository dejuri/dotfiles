import QtQuick
import qs.config

Item {
    id: root
    property string label: ""
    property string description: ""
    default property alias control: slot.data

    width: parent ? parent.width : 0
    implicitHeight: Math.max(44, textCol.implicitHeight + 12)

    Column {
        id: textCol
        anchors { left: parent.left; right: slot.left; rightMargin: 12; verticalCenter: parent.verticalCenter }
        spacing: 2
        Text {
            text: root.label
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 15
            width: parent.width
            elide: Text.ElideRight
        }
        Text {
            visible: text !== ""
            text: root.description
            color: Theme.lighter
            font.family: Theme.font
            font.pixelSize: 12
            width: parent.width
            wrapMode: Text.WordWrap
        }
    }
    Item {
        id: slot
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        width: childrenRect.width
        height: childrenRect.height
    }
}
