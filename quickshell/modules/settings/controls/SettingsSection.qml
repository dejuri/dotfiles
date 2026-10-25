import QtQuick
import qs.config

Column {
    id: root
    property string title: ""
    default property alias content: body.data

    width: parent ? parent.width : 0
    spacing: 8

    Text {
        text: root.title
        color: Theme.primary
        font.family: Theme.font
        font.pixelSize: 13
        font.bold: true
        font.capitalization: Font.AllUppercase
    }
    Rectangle { width: parent.width; height: 1; color: Theme.midnext }
    Column { id: body; width: parent.width; spacing: 6 }
}
