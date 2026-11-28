pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Laptop battery from upower (the upower daemon must be running)
Singleton {
    readonly property var device: UPower.displayDevice
    readonly property bool present: !!device && device.isPresent
    readonly property real level: present ? Math.max(0, Math.min(1, device.percentage)) : 0   // 0..1
    readonly property int percent: Math.round(level * 100)
    readonly property bool charging: present && device.state === UPowerDeviceState.Charging
    readonly property bool full: present && device.state === UPowerDeviceState.FullyCharged
    readonly property bool low: present && !charging && !full && percent <= 15
}
