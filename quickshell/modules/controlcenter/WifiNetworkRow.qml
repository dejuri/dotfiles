import QtQuick
import qs.components
import qs.config
import qs.services

// One wifi network
Column {
    id: root

    property string ssid: ""
    property string strength: ""
    property string security: ""
    property bool inUse: false
    property bool askingPassword: false
    signal passwordToggled()

    spacing: 2

    ListRow {
        width: parent.width
        active: root.inUse
        text: (root.security !== "--" ? Icons.wifiSecure + " " : "") + root.ssid
        trailing: root.strength + "%"
        onClicked: {
            if (root.inUse) Network.disconnect(root.ssid)
            else if (root.security === "--") Network.connect(root.ssid)
            else root.passwordToggled()
        }
    }

    Rectangle {
        visible: root.askingPassword
        width: parent.width
        height: visible ? 32 : 0
        radius: 12
        color: Theme.background
        clip: true

        Row {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 6
            TextInput {
                id: pwd
                width: parent.width - 40
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.text
                echoMode: TextInput.Password
                font.family: Theme.font
                font.pixelSize: 15
                focus: root.askingPassword
                onAccepted: Network.connect(root.ssid, text)
            }
            Text {
                text: "OK"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 15
                MouseArea {
                    anchors.fill: parent; anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Network.connect(root.ssid, pwd.text)
                }
            }
        }
    }
}
