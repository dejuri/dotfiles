pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Wifi controller with nmcli
Singleton {
    id: root

    property bool enabled: true
    readonly property bool scanning: rescanProc.running
    readonly property var networks: networksModel

    ListModel { id: networksModel }

    function refresh() { statusProc.running = true; listProc.running = true }
    function rescan()  { rescanProc.running = true }
    function stopScan() { rescanProc.running = false }

    function setEnabled(on) {
        enabled = on
        toggleProc.command = ["nmcli", "radio", "wifi", on ? "on" : "off"]
        toggleProc.running = true
    }
    function connect(ssid, password) {
        connectProc.command = password
            ? ["nmcli", "device", "wifi", "connect", ssid, "password", password]
            : ["nmcli", "device", "wifi", "connect", ssid]
        connectProc.running = true
    }
    function disconnect(ssid) {
        disconnectProc.command = ["nmcli", "connection", "down", "id", ssid]
        disconnectProc.running = true
    }

    Process {
        id: statusProc
        command: ["nmcli", "radio", "wifi"]
        stdout: SplitParser { onRead: data => root.enabled = data.trim() === "enabled" }
    }
    Process {
        id: listProc
        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SECURITY,SSID", "dev", "wifi", "list"]
        onRunningChanged: if (running) networksModel.clear()
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (line.length === 0) return
                const parts = line.split(":")
                if (parts.length < 4) return
                const inUse = parts[0] === "*"
                const signal = parts[1]
                const security = parts[2]
                const ssid = parts.slice(3).join(":")
                if (ssid.length === 0) return
                for (let i = 0; i < networksModel.count; i++) {
                    if (networksModel.get(i).ssid === ssid) {
                        networksModel.setProperty(i, "inUse", inUse)
                        networksModel.setProperty(i, "signal", signal)
                        networksModel.setProperty(i, "security", security)
                        return
                    }
                }
                networksModel.append({ ssid: ssid, signal: signal, security: security, inUse: inUse })
            }
        }
    }
    Process {
        id: rescanProc
        command: ["nmcli", "device", "wifi", "rescan"]
        onRunningChanged: if (!running) listProc.running = true
    }
    Process {
        id: connectProc
        onRunningChanged: if (!running) listProc.running = true
    }
    Process {
        id: disconnectProc
        onRunningChanged: if (!running) listProc.running = true
    }
    Process { id: toggleProc }

    Component.onCompleted: refresh()
}
