import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

// Just top bar
PanelWindow {
    id: bar

    readonly property int pillMargin: 6
    readonly property int pillHeight: height - pillMargin * 2
    readonly property int sideMargin: 20
    readonly property int gap: 10

    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell:bar"
    exclusiveZone: Config.bar.height
    implicitHeight: Config.bar.height
    color: "transparent"

    anchors { top: true; left: true; right: true }

    Rectangle {
        anchors.fill: parent
        color: Theme.background

        // Just cool mini docks
        Rectangle {
            id: leftDock
            color: Theme.mid
            radius: 15
            height: bar.pillHeight
            anchors { top: parent.top; topMargin: bar.pillMargin; left: parent.left; leftMargin: bar.sideMargin; right: clock.left; rightMargin: bar.gap }
        }
        Rectangle {
            id: rightDock
            color: Theme.mid
            radius: 15
            height: bar.pillHeight
            anchors { top: parent.top; topMargin: bar.pillMargin; left: clock.right; leftMargin: bar.gap; right: parent.right; rightMargin: bar.sideMargin }
        }

        // Left side
        StartButton {
            id: startButton
            anchors { top: parent.top; bottom: parent.bottom; left: parent.left; leftMargin: 5 }
        }
        Workspaces {
            id: workspaces
            anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 67 }
        }
        WindowTitle {
            anchors { left: workspaces.right; leftMargin: 7; right: leftDock.right; rightMargin: 10; top: leftDock.top; bottom: leftDock.bottom }
        }

        // Center
        BarClock {
            id: clock
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: bar.pillMargin - 0.5 }
        }

        // Right side
        VolumeIndicator {
            id: volume
            width: 200
            anchors { right: parent.right; rightMargin: bar.sideMargin; top: rightDock.top; bottom: rightDock.bottom }
        }
        KeyboardLayout {
            width: 51
            anchors { right: volume.left; rightMargin: 6; top: rightDock.top; bottom: rightDock.bottom }
        }
    }
}
