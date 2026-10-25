import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

Scope {
    PanelWindow {
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "quickshell:wallpaper"
        exclusiveZone: 0
        color: "transparent"
        mask: Region {}
        anchors { top: true; left: true; bottom: true; right: true }

        Rectangle {
            anchors.fill: parent
            color: Theme.background
            Image {
                anchors.fill: parent
                source: Paths.wallpaper(Config.appearance.wallpaper)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize: Qt.size(parent.width, parent.height)
            }
        }

        Rectangle {
            readonly property int thickness: 100
            anchors.fill: parent
            anchors.margins: -thickness
            color: "transparent"
            radius: thickness + Config.appearance.cornerRadius
            border.width: thickness
            border.color: Theme.background
            visible: Config.appearance.cornerRadius > 0
        }
    }
}
