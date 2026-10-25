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
            description: "In pixels"
            SettingsStepper {
                value: Config.dock.height
                from: 50; to: 120; step: 2
                onValueModified: v => Config.dock.height = v
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

        Repeater {
            model: Config.dock.pinnedApps
            delegate: Rectangle {
                required property string modelData
                required property int index
                width: parent.width; height: 36; radius: 10
                color: Theme.mid

                Text {
                    anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                    text: modelData
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 14
                }
                Row {
                    anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
                    spacing: 4
                    HoverButton {
                        width: 28; height: 28; text: "↑"; fontSize: 14; baseColor: Theme.midnext
                        visible: index > 0
                        onClicked: {
                            const a = Config.dock.pinnedApps.slice()
                            a.splice(index - 1, 0, a.splice(index, 1)[0])
                            page.updateApps(a)
                        }
                    }
                    HoverButton {
                        width: 28; height: 28; text: Icons.close; fontSize: 14; baseColor: Theme.midnext
                        onClicked: {
                            const a = Config.dock.pinnedApps.slice()
                            a.splice(index, 1)
                            page.updateApps(a)
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
