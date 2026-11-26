import QtQuick
import qs.components
import qs.config
import qs.modules.settings.controls

SettingsPage {
    id: page

    function updateApps(list) { Config.dock.pinnedApps = list }

    SettingsSection {
        title: "Dock"
        SettingsRow {
            label: "Show dock"
            description: "Show the app row in the bottom"
            SettingsSwitch { checked: Config.dock.enabled; onToggled: v => Config.dock.enabled = v }
        }
        SettingsRow {
            label: "Dock height"
            description: "Height of the dock (in pixels)"
            SettingsStepper {
                value: Config.dock.height
                from: 50; to: 120; step: 5
                onValueModified: v => Config.dock.height = v
            }
        }
    }

    SettingsSection {
        title: "Cava"
        SettingsRow {
            label: "Show cava"
            description: "Show audio visualizer on dock (requires 'cava' installed)"
            SettingsSwitch { checked: Config.dock.cavaEnabled; onToggled: v => Config.dock.cavaEnabled = v }
        }
        SettingsRow {
            label: "Cava bar width"
            description: "Width of the audio visualizer single bar (in pixels)"
            SettingsStepper {
                value: Config.dock.cavaWidth
                from: 2; to: 50; step: 2
                onValueModified: v => Config.dock.cavaWidth = v
            }
        }
    }
    SettingsSection {
        title: "Pinned apps"

        Text {
            text: "Command for the binary (.svg icon name must be the same, you can do link if they are different)"
            color: Theme.lighter
            font.family: Theme.font
            font.pixelSize: 12
        }

        // Drag a row to change the order; arrows are kept as a fallback
        ReorderList {
            id: pinnedList
            orientation: ListView.Vertical
            width: parent.width
            height: contentHeight
            spacing: 6
            keys: Config.dock.pinnedApps
            onReordered: list => page.updateApps(list)

            delegate: ReorderSlot {
                id: rowSlot
                required property string key
                width: pinnedList.width
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
                        text: rowSlot.key
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 14
                    }
                    Row {
                        anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
                        spacing: 4
                        HoverButton {
                            width: 28; height: 28; text: "↑"; fontSize: 14; baseColor: Theme.midnext
                            visible: rowSlot.index > 0
                            onClicked: {
                                const a = Config.dock.pinnedApps.slice()
                                a.splice(rowSlot.index - 1, 0, a.splice(rowSlot.index, 1)[0])
                                page.updateApps(a)
                            }
                        }
                        HoverButton {
                            width: 28; height: 28; text: "↓"; fontSize: 14; baseColor: Theme.midnext
                            visible: rowSlot.index < pinnedList.count - 1
                            onClicked: {
                                const a = Config.dock.pinnedApps.slice()
                                a.splice(rowSlot.index + 1, 0, a.splice(rowSlot.index, 1)[0])
                                page.updateApps(a)
                            }
                        }
                        HoverButton {
                            width: 28; height: 28; text: Icons.close; fontSize: 14; baseColor: Theme.midnext
                            onClicked: {
                                const a = Config.dock.pinnedApps.slice()
                                a.splice(rowSlot.index, 1)
                                page.updateApps(a)
                            }
                        }
                    }
                }
            }
        }

        SettingsRow {
            label: "Add an Application"
            SettingsTextField {
                id: addField
                placeholder: "Command..."

                value: ""
                onEdited: v => {
                    const name = v.trim()
                    if (name !== "") page.updateApps([...Config.dock.pinnedApps, name])
                    addField.value = ""
                }
            }
        }
    }
}
