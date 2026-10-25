import QtQuick
import qs.config

// Scan and stop buttons for bluetooth/wifi in control center
Row {
    id: root
    property bool scanning: false
    signal scan()
    signal stop()

    spacing: 4

    Rectangle {
        width: (root.width - 4) / 2; height: 28; radius: 12; color: Theme.mid
        Text {
            anchors.centerIn: parent
            text: root.scanning ? "Scanning..." : Icons.refresh + " Scan"
            color: Theme.text; font.family: Theme.font; font.pixelSize: 14
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.scan() }
    }
    Rectangle {
        width: (root.width - 4) / 2; height: 28; radius: 12; color: Theme.mid
        opacity: root.scanning ? 1 : 0.4
        Text {
            anchors.centerIn: parent
            text: Icons.close + " Stop"
            color: Theme.text; font.family: Theme.font; font.pixelSize: 14
        }
        MouseArea {
            anchors.fill: parent; enabled: root.scanning; cursorShape: Qt.PointingHandCursor
            onClicked: root.stop()
        }
    }
}
