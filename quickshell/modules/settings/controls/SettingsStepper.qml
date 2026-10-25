import QtQuick
import qs.config

Row {
    id: root
    property int value: 0
    property int from: 0
    property int to: 100
    property int step: 1
    signal valueModified(int value)

    spacing: 6

    StepperButton { label: "−"; onClicked: root.valueModified(Math.max(root.from, root.value - root.step)) }
    Text {
        width: 48; height: 32
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: root.value
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: 15
    }
    StepperButton { label: "+"; onClicked: root.valueModified(Math.min(root.to, root.value + root.step)) }
}
