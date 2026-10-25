import QtQuick
import qs.config

Rectangle {
    id: root
    property string label: ""
    signal clicked()

    width: 32; height: 32; radius: 10
    color: ma.containsMouse ? Theme.primary : Theme.mid
    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Text {
        anchors.centerIn: parent
        text: root.label
        color: ma.containsMouse ? Theme.background : Theme.text
        font.family: Theme.font
        font.pixelSize: 18
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
