import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components
import qs.services

// Just top bar
PanelWindow {
    id: bar

    readonly property int pillMargin: 6
    readonly property int pillHeight: Config.bar.height - pillMargin * 2
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

        // Right side, items can be dragged to change order (saved in Config.bar.rightItems)
        Component { id: statsWidget;    SystemMonitor   { anchors.fill: parent } }
        Component { id: keyboardWidget; KeyboardLayout  { anchors.fill: parent } }
        Component { id: batteryWidget;  BatteryIndicator { anchors.fill: parent } }
        Component { id: volumeWidget;   VolumeIndicator { anchors.fill: parent } }

        ReorderList {
            id: rightItems
            readonly property var widths: ({ stats: 165, keyboard: 51, battery: 105, volume: 200 })

            anchors { right: parent.right; rightMargin: bar.sideMargin; top: rightDock.top; bottom: rightDock.bottom }
            width: contentWidth
            orientation: ListView.Horizontal
            spacing: 6
            keys: Config.bar.rightItems
            onReordered: list => Config.bar.rightItems = list

            delegate: ReorderSlot {
                id: slot
                required property string key
                width: (key === "battery" && !Battery.present) ? 0 : (rightItems.widths[key] ?? 60)
                height: rightItems.height

                Loader {
                    anchors.fill: parent
                    sourceComponent: slot.key === "stats" ? statsWidget
                                   : slot.key === "keyboard" ? keyboardWidget
                                   : slot.key === "battery" ? batteryWidget
                                   : slot.key === "volume" ? volumeWidget : null
                }
            }
        }
    }
}
