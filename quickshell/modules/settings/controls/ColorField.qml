import QtQuick
import qs.config

Row {
    id: root
    property string value: "#000000"
    signal edited(string value)

    spacing: 8

    Rectangle {
        width: 32; height: 32; radius: 10
        color: root.value
        border.width: 1
        border.color: Theme.lighter
    }
    Rectangle {
        id: box
        width: 110; height: 32; radius: 10
        color: Theme.mid
        border.width: 1
        border.color: input.activeFocus ? (input.acceptableInput ? Theme.primary : "#e06c75") : "transparent"

        TextInput {
            id: input
            anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 14
            text: root.value
            maximumLength: 7
            validator: RegularExpressionValidator { regularExpression: /^#[0-9a-fA-F]{6}$/ }
            onEditingFinished: if (acceptableInput && text.toLowerCase() !== root.value.toLowerCase()) root.edited(text.toLowerCase())
        }
    }
    onValueChanged: if (!input.activeFocus) input.text = value
}
