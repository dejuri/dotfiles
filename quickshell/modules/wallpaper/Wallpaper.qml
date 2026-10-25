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
        Rectangle {
            id: wallpaper
            anchors.fill: parent
            color: Theme.background
            Image {
                source: "wallpaper/" + Theme.wallpaper
                anchors.fill: parent
            }
        }
        Rectangle {
            id: main
            anchors.fill: parent
            anchors.topMargin: -0.0705 *1440
            anchors.bottomMargin: -0.0705 *1440
            anchors.leftMargin: -0.0708 *1440
            anchors.rightMargin: anchors.leftMargin
            color: "transparent"
            radius: 0.0902777777778 *1440 
            border.width: 0.03984375 *2560
            border.color: Theme.background
        }
    }
}
