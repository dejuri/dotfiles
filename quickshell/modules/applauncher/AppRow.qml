import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

// One row in app list
Item {
    id: row

    required property var entry
    required property int index
    property bool selected: false
    signal hovered()
    signal activated()

    height: 52

    function iconSource() {
        const i = entry.icon ?? ""
        if (i.startsWith("/")) return "file://" + i
        return Quickshell.iconPath(i, "application-x-executable")
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: row.hovered()
        onClicked: row.activated()
    }

    RowLayout {
        anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
        spacing: 14

        Image {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            source: row.iconSource()
            sourceSize: Qt.size(64, 64)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: row.entry.name
                color: row.selected ? Theme.background : Theme.text
                font.family: Theme.font
                font.pixelSize: 15
                elide: Text.ElideRight
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: row.entry.comment || row.entry.genericName || ""
                color: row.selected ? Theme.background : Theme.text
                font.family: Theme.font
                font.pixelSize: 11
                elide: Text.ElideRight
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
        }
    }
}
