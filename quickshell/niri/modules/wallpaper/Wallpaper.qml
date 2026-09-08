import Quickshell
import Quickshell.Wayland
import QtQuick
import "../theme"

Item {
    id: root
    property var wallpaper: "prypyat.jpg"
    PanelWindow {
        WlrLayershell.layer: WlrLayer.Background 
        exclusiveZone: 0
        color: "transparent"
        mask: Region {}
        anchors.top: true
        anchors.left: true
        anchors.bottom: true
        anchors.right: true
        width: Screen.width
        height: Screen.height - 112.5
        Rectangle {
            id: wallpaper
            anchors.fill: parent
            color: Theme.background
            Image {
                fillMode: Image.TileHorizontally
                source: "wallpaper/" + root.wallpaper
                anchors.fill: parent
            }
        }
        Rectangle {
            id: main
            anchors.fill: parent
            anchors.topMargin: -0.0705 * Screen.height
            anchors.bottomMargin: -0.0705 * Screen.height
            anchors.leftMargin: -0.0708 * Screen.height
            anchors.rightMargin: anchors.leftMargin
            color: "transparent"
            radius: 130 
            border.width: 102
            border.color: Theme.background
        }
    }
}
