import QtQuick
import qs.config

Rectangle {
    id: root
    property string value: ""
    property string placeholder: ""
    property bool monospace: true
    signal edited(string value)

    width: 220; height: 32; radius: 10
    color: Theme.mid
    border.width: input.activeFocus ? 1 : 0
    border.color: Theme.primary

    TextInput {
        id: input
        anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
        verticalAlignment: TextInput.AlignVCenter
        clip: true
        color: Theme.text
        selectionColor: Theme.primary
        selectedTextColor: Theme.background
        font.family: Theme.font
        font.pixelSize: 14
        text: root.value
        onEditingFinished: if (text !== root.value) root.edited(text)

        Text {
            visible: input.text === "" && !input.activeFocus
            text: root.placeholder
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.lighter
            font: input.font
        }
    }
    onValueChanged: if (!input.activeFocus) input.text = value
}
