import QtQuick
import qs.components
import qs.config
import qs.services

ExpandableTile {
    id: root

    text: Bluetooth.enabled ? Icons.bluetoothOn : Icons.bluetoothOff
    subtitle: Bluetooth.connectedName ? Bluetooth.connectedName : "Bluetooth"
    fontSize: 20
    checked: Bluetooth.enabled
    onToggled: Bluetooth.setEnabled(!Bluetooth.enabled)
    onExpandedChanged: if (expanded) Bluetooth.refreshDevices()

    ScanControls {
        width: parent.width
        scanning: Bluetooth.scanning
        onScan: Bluetooth.startScan()
        onStop: Bluetooth.stopScan()
    }

    Repeater {
        model: Bluetooth.devices
        delegate: ListRow {
            required property string mac
            required property string name
            required property bool connected
            width: root.width
            text: name
            active: connected
            onClicked: connected ? Bluetooth.disconnectDevice(mac) : Bluetooth.connectDevice(mac)
        }
    }

    Text {
        visible: Bluetooth.devices.count === 0
        text: "No devices found"
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: 14
        width: parent.width
        wrapMode: Text.WordWrap
    }
}
