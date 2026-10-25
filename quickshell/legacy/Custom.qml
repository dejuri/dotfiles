pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects

Item {
    PanelWindow {
        color: "transparent"
        mask: Region {}
        width: 0.005 *1440
        height: 28
        Rectangle {
            anchors.fill: parent
            color: "#ffffff"
        }
    }
    PanelWindow {
        color: "transparent"
        mask: Region {}
        width: 28
        height: 0.005 *1440
        Rectangle {
            anchors.fill: parent
            color: "#ffffff"
        }
    }
}