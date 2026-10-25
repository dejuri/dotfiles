import QtQuick
import Quickshell
import qs.config
import qs.modules.settings.controls

SettingsPage {
    SettingsSection {
        title: "System"
        SettingsRow {
            label: "Distro name"
            description: "It is shown in control center"
            SettingsTextField { value: Config.general.osName; onEdited: v => Config.general.osName = v }
        }
        SettingsRow {
            label: "Terminal"
            description: "For some apps that are launched in terminal"
            SettingsTextField { value: Config.general.terminal; onEdited: v => Config.general.terminal = v }
        }
        SettingsRow {
            label: "Lock command"
            description: "Is used in control center"
            SettingsTextField { value: Config.general.lockCommand; onEdited: v => Config.general.lockCommand = v }
        }
    }
}
