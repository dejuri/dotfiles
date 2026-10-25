pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Script in the scripts/bt-services.sh, uses bluetoothctl/busctl
Singleton {
    id: root

    property bool enabled: false
    readonly property bool scanning: scanProc.running
    readonly property var devices: devicesModel
    readonly property string connectedName: {
        for (let i = 0; i < devicesModel.count; i++)
            if (devicesModel.get(i).connected) return devicesModel.get(i).name
        return ""
    }

    ListModel { id: devicesModel }

    function refresh() { powerProc.running = true }
    function refreshDevices() { if (enabled) devicesProc.running = true }
    function setEnabled(on) {
        enabled = on
        if (!on) devicesModel.clear()
        toggleProc.command = ["bluetoothctl", "power", on ? "on" : "off"]
        toggleProc.running = true
    }
    function startScan() { if (scanProc.running) stopScan(); scanProc.running = true }
    function stopScan() {
        if (!scanProc.running) return
        scanProc.write("scan off\nexit\n")
        scanStartTimer.stop()
        scanProc.running = false
    }
    function connectDevice(mac)    { actionProc.command = ["bluetoothctl", "connect", mac]; actionProc.running = true }
    function disconnectDevice(mac) { actionProc.command = ["bluetoothctl", "disconnect", mac]; actionProc.running = true }

    function applyPower(isPowered) {
        enabled = isPowered
        if (isPowered) devicesProc.running = true
        else devicesModel.clear()
    }

    Process {
        id: powerProc
        command: ["sh", "-c", "busctl get-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered 2>/dev/null | awk '{print $2}'"]
        stdout: SplitParser {
            onRead: data => {
                const s = data.trim().toLowerCase()
                if (s === "true" || s === "false") root.applyPower(s === "true")
                else fallbackPowerProc.running = true
            }
        }
        stderr: SplitParser { onRead: data => fallbackPowerProc.running = true }
    }
    Process {
        id: fallbackPowerProc
        command: ["sh", "-c", "bluetoothctl show | grep -i 'Powered:' | awk '{print $2}'"]
        stdout: SplitParser { onRead: data => root.applyPower(data.trim().toLowerCase() === "yes") }
    }
    Process {
        id: devicesProc
        command: ["bash", Paths.script("bt-devices.sh")]
        onRunningChanged: if (running) devicesModel.clear()
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (!line) return
                const parts = line.split("|")
                if (parts.length < 3) return
                const mac = parts[0].trim()
                const name = parts[1].trim()
                const connected = parts[2].trim() === "true"
                if (name === "Unknown") return
                if (name.replace(/-/g, ":").toLowerCase() === mac.toLowerCase()) return
                for (let i = 0; i < devicesModel.count; i++)
                    if (devicesModel.get(i).mac === mac) return
                devicesModel.append({ mac: mac, name: name, connected: connected })
            }
        }
        stderr: SplitParser { onRead: data => console.warn("[bt devices] " + data) }
    }
    Process {
        id: scanProc
        command: ["timeout", "8", "bluetoothctl"]
        stdinEnabled: true
        onRunningChanged: {
            if (running) scanStartTimer.start()
            else root.refreshDevices()
        }
        stderr: SplitParser { onRead: data => console.warn("[bt scan] " + data) }
    }
    Timer {
        id: scanStartTimer
        interval: 1000
        onTriggered: { scanProc.write("power on\n"); scanProc.write("scan on\n") }
    }
    Process {
        id: actionProc
        stderr: SplitParser { onRead: data => console.warn("[bt] " + data) }
        onRunningChanged: if (!running) root.refreshDevices()
    }
    Process {
        id: toggleProc
        onRunningChanged: if (!running) powerProc.running = true
    }

    Timer { interval: 300; running: true; onTriggered: root.refresh() }
}
