import QtQuick
import qs.config

Item {
    id: root

    property string iconName: ""
    property bool showHighlight: false
    property bool focused: false
    property alias acceptedButtons: mouse.acceptedButtons
    readonly property bool hovered: mouse.containsMouse
    signal clicked(var mouse)

    width: 48
    height: 48

    Rectangle {
        visible: root.showHighlight
        width: 45; height: 45; radius: 25
        anchors.horizontalCenter: parent.horizontalCenter
        y: -3
        color: Theme.primary
        scale: root.focused ? 1 : 0.8
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        visible: root.showHighlight
        width: root.focused ? 10 : 5
        height: 5
        radius: 10
        color: Theme.text
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: -3 }
        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    }

    Image {
        id: icon
        anchors.horizontalCenter: parent.horizontalCenter
        source: Paths.icon(root.iconName.toLowerCase())
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        sourceSize: Qt.size(64, 64)
        scale: root.hovered ? 0.85 : 0.7
        y: root.hovered ? -17 : -13
        visible: status === Image.Ready

        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        onStatusChanged: if (status === Image.Error) source = Paths.icon("x-executable")
    }
    Text {
        anchors.centerIn: parent
        visible: icon.status !== Image.Ready
        text: root.iconName.length ? root.iconName[0].toUpperCase() : "?"
        color: Theme.text
        font.family: Theme.font
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: m => root.clicked(m)
    }
}
