pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects

Item {
    PanelWindow {
        color: "transparent"
        mask: Region {}
        width: 0.005 * Screen.height
        height: 0.02 * Screen.height
        Rectangle {
            anchors.fill: parent
            color: "#ffffff"
        }
    }
    PanelWindow {
        color: "transparent"
        mask: Region {}
        width: 0.02 * Screen.height
        height: 0.005 * Screen.height
        Rectangle {
            anchors.fill: parent
            color: "#ffffff"
        }
    }
}