import QtQuick
import qs.config
import qs.modules.settings.controls

SettingsPage {
    SettingsSection {
        title: "Theme"

        Flow {
            width: parent.width
            spacing: 8
            Repeater {
                model: Presets.list
                delegate: Rectangle {
                    required property var modelData
                    width: label.implicitWidth + 110
                    height: 34
                    radius: 10
                    color: ma.containsMouse ? Theme.midnext : Theme.mid
                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Rectangle { width: 14; height: 14; radius: 7; color: modelData.background; border.width: 1; border.color: Theme.lighter }
                        Rectangle { width: 14; height: 14; radius: 7; color: modelData.mid }
                        Rectangle { width: 14; height: 14; radius: 7; color: modelData.primary }
                        Rectangle { width: 14; height: 14; radius: 7; color: modelData.lightest }
                        Text { id: label; text: modelData.name; color: Theme.text; font.family: Theme.font; font.pixelSize: 13 }
                    }
                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const c = Config.appearance.colors
                            c.background = modelData.background
                            c.mid = modelData.mid
                            c.midnext = modelData.midnext
                            c.primary = modelData.primary
                            c.lighter = modelData.lighter
                            c.lightest = modelData.lightest
                        }
                    }
                }
            }
        }
    }

    SettingsSection {
        title: "Colors"
        Repeater {
            model: [
                { key: "background", label: "Background", desc: "Panel, menu, frames" },
                { key: "mid", label: "Middle", desc: "Launcher, some buttons" },
                { key: "midnext", label: "Middle next", desc: "Buttons on bar" },
                { key: "primary", label: "Accent", desc: "Active element and highlight" },
                { key: "lighter", label: "Lighter", desc: "Separators and subtitles" },
                { key: "lightest", label: "Lightest", desc: "Main text color" }
            ]
            delegate: SettingsRow {
                required property var modelData
                label: modelData.label
                description: modelData.desc
                ColorField {
                    value: Config.appearance.colors[modelData.key]
                    onEdited: v => Config.appearance.colors[modelData.key] = v
                }
            }
        }
    }

    SettingsSection {
        title: "Display and fonts"
        SettingsRow {
            label: "Concave curves"
            description: "Concave curves radius in pixels"
            SettingsStepper {
                value: Config.appearance.cornerRadius
                from: 0; to: 80; step: 2
                onValueModified: v => Config.appearance.cornerRadius = v
            }
        }
        SettingsRow {
            label: "Primary font"
            description: "It has to be installed on the system, and support nerd font"
            SettingsTextField { value: Config.appearance.font; onEdited: v => Config.appearance.font = v }
        }
        SettingsRow {
            label: "Clock widget font"
            description: "The name of .ttf file from fonts folder (without extension)"
            SettingsTextField { value: Config.appearance.clockFont; onEdited: v => Config.appearance.clockFont = v }
        }
    }

    SettingsSection {
        title: "Desktop"
        SettingsRow {
            label: "Clock widget"
            description: "Show clock widget on desktop"
            SettingsSwitch { checked: Config.bar.desktopClock; onToggled: v => Config.bar.desktopClock = v }
        }
        SettingsRow {
            label: "Prefer dark clock"
            description: "Change clock widget color to dark"
            SettingsSwitch { checked: Config.bar.darkClock; onToggled: v => Config.bar.darkClock = v }
        }
    }
}
