import QtQuick
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
            label: "Clock format"
            description: "Qt format: hh:mm:ss, MMMM dd, ddd, yyyy"
            SettingsTextField { value: Config.bar.clockFormat; onEdited: v => Config.bar.clockFormat = v }
        }
    }

}
