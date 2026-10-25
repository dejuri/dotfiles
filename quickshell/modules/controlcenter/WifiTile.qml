import QtQuick
import qs.components
import qs.config
import qs.services

ExpandableTile {
    id: root

    property string passwordTarget: ""

    text: (Network.enabled ? Icons.wifiOn : Icons.wifiOff) + " Wi-Fi"
    fontSize: 20
    checked: Network.enabled
    onToggled: Network.setEnabled(!Network.enabled)
    onExpandedChanged: if (expanded) Network.refresh()

    ScanControls {
        width: parent.width
        scanning: Network.scanning
        onScan: Network.rescan()
        onStop: Network.stopScan()
    }

    Repeater {
        model: Network.networks
        delegate: WifiNetworkRow {
            width: root.width
            ssid: model.ssid
            strength: model.signal
            security: model.security
            inUse: model.inUse
            askingPassword: root.passwordTarget === model.ssid
            onPasswordToggled: root.passwordTarget = root.passwordTarget === model.ssid ? "" : model.ssid
        }
    }

    Text {
        visible: Network.networks.count === 0
        text: "No networks found"
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: 14
        width: parent.width
        wrapMode: Text.WordWrap
    }
}
