import QtQuick
import qs.components
import qs.config
import qs.modules.settings.controls

SettingsPage {
    SettingsSection {
        title: "Top bar"
        SettingsRow {
            label: "Bar height"
            description: "In pixels"
            SettingsStepper {
                value: Config.bar.height
                from: 30; to: 80; step: 1
                onValueModified: v => Config.bar.height = v
            }
        }
        SettingsRow {
            label: "Battery percent"
            description: "Show the number next to the battery icon"
            SettingsSwitch { checked: Config.bar.batteryPercent; onToggled: v => Config.bar.batteryPercent = v }
        }
        SettingsRow {
            label: "Clock format"
            description: "Qt format: hh:mm:ss, MMMM dd, ddd, yyyy"
            SettingsTextField { value: Config.bar.clockFormat; onEdited: v => Config.bar.clockFormat = v }
        }
    }

    SettingsSection {
        title: "Right side"

        Text {
            text: "Drag the rows to change the order of the widgets (you can also drag them in the bar itself)"
            color: Theme.lighter
            font.family: Theme.font
            font.pixelSize: 12
            width: parent.width
            wrapMode: Text.WordWrap
        }

        ReorderList {
            id: rightList
            readonly property var names: ({
                stats: "System monitor",
                keyboard: "Keyboard layout",
                battery: "Battery",
                volume: "Volume"
            })

            orientation: ListView.Vertical
            width: parent.width
            height: contentHeight
            spacing: 6
            keys: Config.bar.rightItems
            onReordered: list => Config.bar.rightItems = list

            delegate: ReorderSlot {
                id: rowSlot
                required property string key
                width: rightList.width
                height: 36

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: rowSlot.dragging ? Theme.midnext : Theme.mid
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    Text {
                        id: grip
                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                        text: "⋮⋮"
                        color: Theme.lighter
                        font.family: Theme.font
                        font.pixelSize: 16
                    }
                    Text {
                        anchors { left: grip.right; leftMargin: 8; verticalCenter: parent.verticalCenter }
                        text: rightList.names[rowSlot.key] ?? rowSlot.key
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 14
                    }
                }
            }
        }
    }
}
