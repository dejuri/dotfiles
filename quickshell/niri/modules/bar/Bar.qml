import QtQuick
import QtQuick.Layouts
import QtQml.Models
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Niri 0.1
import qs.services
import "../theme"

Item {

// CONTROL CENTER
    property real currentVolume: Pipewire.defaultAudioSink?.audio?.volume ?? 0
    property bool wifiRadioEnabled: true
    property bool bluetoothRadioEnabled: false
    property string wifiPasswordTarget: ""
    property string wifiPasswordText: ""

    Connections {
        target: Pipewire.defaultAudioSink?.audio
        function onVolumeChanged() {
            currentVolume = Pipewire.defaultAudioSink.audio.volume
        }
    }
    Process { id: commandRunner }

    ListModel { id: wifiNetworksModel }
    Process {
        id: wifiRadioStatusProc
        command: ["nmcli", "radio", "wifi"]
        stdout: SplitParser {
            onRead: (data) => { wifiRadioEnabled = data.trim() === "enabled" }
        }
    }
    Process {
        id: wifiListProc
        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SECURITY,SSID", "dev", "wifi", "list"]
        onRunningChanged: if (running) wifiNetworksModel.clear()
        stdout: SplitParser {
            onRead: (data) => {
                let line = data.trim()
                if (line.length === 0) return
                let parts = line.split(":")
                if (parts.length < 4) return
                let inUse = parts[0] === "*"
                let signal = parts[1]
                let security = parts[2]
                let ssid = parts.slice(3).join(":")
                if (ssid.length === 0) return
                for (let i = 0; i < wifiNetworksModel.count; i++) {
                    if (wifiNetworksModel.get(i).ssid === ssid) {
                        wifiNetworksModel.setProperty(i, "inUse", inUse)
                        wifiNetworksModel.setProperty(i, "signal", signal)
                        wifiNetworksModel.setProperty(i, "security", security)
                        return
                    }
                }
                wifiNetworksModel.append({ ssid: ssid, signal: signal, security: security, inUse: inUse })
            }
        }
    }
    Process {
        id: wifiRescanProc
        command: ["nmcli", "device", "wifi", "rescan"]
        onRunningChanged: if (!running) wifiListProc.running = true
    }
    Process {
        id: wifiConnectProc
        onRunningChanged: if (!running) { wifiPasswordTarget = ""; wifiListProc.running = true }
    }
    Process {
        id: wifiDisconnectProc
        onRunningChanged: if (!running) wifiListProc.running = true
    }
    Process { id: wifiToggleProc }

    ListModel { id: btDevicesModel }


    Process {
        id: btPowerStatusProc
        command: ["sh", "-c", "busctl get-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered 2>/dev/null | awk '{print $2}'"]
        stdout: SplitParser {
            onRead: (data) => {
                let status = data.trim().toLowerCase()
                
                if (status === "true" || status === "false") {
                    let isPowered = (status === "true")
                    bluetoothRadioEnabled = isPowered

                    if (!isPowered) {
                        btDevicesModel.clear()
                    } else {
                        btDevicesProc.running = true
                    }
                } else {
                    fallbackPowerCheckProc.running = true
                }
            }
        }
        stderr: SplitParser {
            onRead: (data) => {
                fallbackPowerCheckProc.running = true
            }
        }
    }

    Process {
        id: fallbackPowerCheckProc
        command: ["sh", "-c", "bluetoothctl show | grep -i 'Powered:' | awk '{print $2}'"]
        stdout: SplitParser {
            onRead: (data) => {
                let isPowered = (data.trim().toLowerCase() === "yes")
                bluetoothRadioEnabled = isPowered
                if (!isPowered) {
                    btDevicesModel.clear()
                } else {
                    btDevicesProc.running = true
                }
            }
        }
    }
    Process {
        id: btDevicesProc
        command: ["sh", "-c", "busctl tree org.bluez | grep '/dev_' | awk -F'/' '{print $NF}' | sed 's/dev_//; s/_/:/g' | sort -u | while read -r mac; do
            path=$(busctl tree org.bluez | grep \"dev_${mac//:/_}\" | head -n1 | awk '{print $NF}')
            
            name=$(busctl get-property org.bluez \"$path\" org.bluez.Device1 Name 2>/dev/null | awk -F'\"' '{print $2}')
            if [ -z \"$name\" ]; then
                name=$(busctl get-property org.bluez \"$path\" org.bluez.Device1 Alias 2>/dev/null | awk -F'\"' '{print $2}')
            fi
            
            conn=$(busctl get-property org.bluez \"$path\" org.bluez.Device1 Connected 2>/dev/null | awk '{print $2}')
            
            if [ -z \"$name\" ]; then
                name=\"Unknown\"
            fi
            
            echo \"$mac|$name|$conn\"
        done"]
        onRunningChanged: {
            if (running) btDevicesModel.clear()
        }
        stdout: SplitParser {
            onRead: (data) => {
                let line = data.trim()
                if (!line) return
                let parts = line.split("|")
                if (parts.length < 3) return
                
                let mac = parts[0].trim()
                let name = parts[1].trim()
                let isConnected = parts[2].trim() === "true"

                if (name === "Unknown") return
                
                let cleanName = name.replace(/-/g, ":").toLowerCase()
                if (cleanName === mac.toLowerCase()) return

                for (let i = 0; i < btDevicesModel.count; i++) {
                    if (btDevicesModel.get(i).mac === mac) return
                }

                btDevicesModel.append({
                    mac: mac,
                    name: name,
                    connected: isConnected
                })
            }
        }
        stderr: SplitParser {
            onRead: (data) => console.warn("[bt devices] " + data)
        }
    }

    Process {
        id: btScanProc
        command: ["timeout", "8", "bluetoothctl"]
        stdinEnabled: true

        function startScan() {
            if (running) stopScan()
            running = true
        }

        function stopScan() {
            if (!running) return
            btScanProc.write("scan off\nexit\n")
            btScanStartTimer.stop()
            running = false
        }

        onRunningChanged: {
            if (running) {
                btScanStartTimer.start()
            } else {
                if (bluetoothRadioEnabled) btDevicesProc.running = true
            }
        }
        stderr: SplitParser {
            onRead: (data) => console.warn("[bt scan] " + data)
        }
    }

    Timer {
        id: btScanStartTimer
        interval: 1000
        onTriggered: {
            btScanProc.write("power on\n")
            btScanProc.write("scan on\n")
        }
    }

    Process {
        id: btConnectProc
        function connectDevice(mac) {
            let macUnderscore = mac.replaceAll(":", "_")
            command = ["sh", "-c", `path=$(busctl tree org.bluez | grep "dev_${macUnderscore}" | head -n1 | awk '{print $NF}'); busctl call org.bluez "$path" org.bluez.Device1 Connect`]
            running = true
        }
        onRunningChanged: if (!running && bluetoothRadioEnabled) btDevicesProc.running = true
        stderr: SplitParser {
            onRead: (data) => console.warn("[bt connect] " + data)
        }
    }

    Process {
        id: btDisconnectProc
        function disconnectDevice(mac) {
            let macUnderscore = mac.replaceAll(":", "_")
            command = ["sh", "-c", `path=$(busctl tree org.bluez | grep "dev_${macUnderscore}" | head -n1 | awk '{print $NF}'); busctl call org.bluez "$path" org.bluez.Device1 Disconnect`]
            running = true
        }
        onRunningChanged: if (!running && bluetoothRadioEnabled) btDevicesProc.running = true
        stderr: SplitParser {
            onRead: (data) => console.warn("[bt disconnect] " + data)
        }
    }

    Process {
        id: btToggleProc
        function toggle(enable) {
            if (!enable) {
                btDevicesModel.clear()
            }
            command = ["bluetoothctl", "power", enable ? "on" : "off"]
            running = true
        }
        onRunningChanged: {
            if (!running) {
                btPowerStatusProc.running = true
            }
        }
    }

    Timer {
        id: btInitTimer
        interval: 300
        running: false
        repeat: false
        onTriggered: {
            btPowerStatusProc.running = true
        }
    }

    Component.onCompleted: {
        wifiRadioStatusProc.running = true
        wifiListProc.running = true
        btInitTimer.start()
    }
    
    Connections {
        target: NiriEvents
        function onKeyboardLayoutChanged(index, name) {
            kbtoggler.slid = index;
            samlayout.text = name;
        }
    }
    PanelWindow {
        exclusiveZone: 0
        id: startMenu1
        color: "transparent"
        width: 430
        anchors {
            left: true
            top: true
            bottom: true
        }
        Timer {
            id: closeDelay
            interval: 100 
            onTriggered: {
                startMenu1.expanded = !startMenu1.expanded
                menuRect.opacity = 1
            }
        }
        property bool expanded: false
        visible: expanded

        MouseArea {
            id: mainMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onExited: {
                if (startMenu1.expanded == true) {
                    closeDelay.start()
                    menuRect.width = 0 * Screen.height
                    menuRect.height = 0.310 * Screen.height
                    menuRect.opacity = 0
                }
            }
        }
        Item {
            id: menuContainer
            property var rebootProcess: Process {
                command: ["sh", "-c", "reboot"]
            }
            property var logoutProcess: Process {
                command: ["sh", "-c", "niri msg action quit"]
            }
            property var poweroffProcess: Process {
                command: ["sh", "-c", "poweroff"]
            }
            property var hyprlockProcess: Process {
                command: ["sh", "-c", "hyprlock"]
            }
            width: parent.width
            height: parent.height
            Rectangle {
                id: blg
                anchors.left: parent.left
		        y: 0
                color: "transparent"
                radius: 30
            }
            Rectangle {
                id: menuRect
                height: startMenu1.expanded ? 0.710 * Screen.height : 0.310 * Screen.height
                width: startMenu1.expanded ? 0.1671875 * Screen.width : 0
                property var formr: (-0.0025)*Screen.width
                x: formr
                z: 1
                anchors.verticalCenter: parent.verticalCenter
                y: 0.007 * Screen.height
                radius: 25
                color: Theme.background
                opacity: startMenu1.expanded ? 1 : 0
                Behavior on height {
                    NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                }
                Behavior on width {
                    NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                }
                Flickable {
                    id: menuFlick
                    anchors.top: parent.top
                    anchors.topMargin: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.max(0, parent.width - 24)
                    height: Math.max(0, menuRect.height - 28)
                    clip: true
                    contentWidth: width
                    contentHeight: menuColumn.height
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: menuColumn
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "Radian 13.0 Dinit"
                            font.family: "Jetbrains Mono"
                            font.pixelSize: 0.01667 * Screen.height
                            color: Theme.text
                        }
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8
                            Rectangle {
                                id: pob
                                height: 0.035 * Screen.height
                                width: height
                                radius: 25
                                color: Theme.mid
                                Behavior on color {
                                    ColorAnimation { duration: 100; easing.type: Easing.InOutQuad }
                                }
                                Behavior on radius {
                                    NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                                }
                                Behavior on height {
                                    NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰤆"
                                    font.family: "FiraMono Nerd Font"
                                    color: Theme.text
                                    font.pixelSize: 0.0125 * Screen.height
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        menuContainer.poweroffProcess.startDetached()
                                        Qt.quit()
                                    }
                                    hoverEnabled: false
                                    onEntered: {
                                        pob.color = Theme.primary
                                        pob.radius = 5
                                    }
                                    onExited: {
                                        pob.color = Theme.mid
                                        pob.radius = 25
                                    }
                                }
                            }
                            Rectangle {
                                id: rebb
                                height: 0.035 * Screen.height
                                width: height
                                radius: 25
                                color: Theme.mid
                                Behavior on color {
                                    ColorAnimation { duration: 100; easing.type: Easing.InOutQuad }
                                }
                                Behavior on radius {
                                    NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                                }
                                Behavior on height {
                                    NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    font.family: "FiraMono Nerd Font"
                                    color: Theme.text
                                    font.pixelSize: 0.0125 * Screen.height
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        menuContainer.rebootProcess.startDetached()
                                        Qt.quit()
                                    }
                                    hoverEnabled: false
                                    onEntered: {
                                        rebb.color = Theme.primary
                                        rebb.radius = 5
                                    }
                                    onExited: {
                                        rebb.color = Theme.mid
                                        rebb.radius = 25
                                    }
                                }
                            }
                            Rectangle {
                                id: lob
                                height: 0.035 * Screen.height
                                width: height
                                radius: 25
                                color: Theme.mid
                                Behavior on color {
                                    ColorAnimation { duration: 100; easing.type: Easing.InOutQuad }
                                }
                                Behavior on radius {
                                    NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                                }
                                Behavior on height {
                                    NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰍃"
                                    font.family: "FiraMono Nerd Font"
                                    color: Theme.text
                                    font.pixelSize: 0.0125 * Screen.height
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        menuContainer.logoutProcess.startDetached()
                                    }
                                    hoverEnabled: false
                                    onEntered: {
                                        lob.color = Theme.primary
                                        lob.radius = 5
                                    }
                                    onExited: {
                                        lob.color = Theme.mid
                                        lob.radius = 25
                                    }
                                }
                            }
                            Rectangle {
                                id: hlb
                                height: 0.035 * Screen.height
                                width: height
                                radius: 25
                                color: Theme.mid
                                Behavior on color {
                                    ColorAnimation { duration: 100; easing.type: Easing.InOutQuad }
                                }
                                Behavior on radius {
                                    NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                                }
                                Behavior on height {
                                    NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    font.family: "FiraMono Nerd Font"
                                    color: Theme.text
                                    font.pixelSize: 0.0125 * Screen.height
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        menuContainer.hyprlockProcess.startDetached()
                                        startMenu1.expanded = 0
                                    }
                                    hoverEnabled: false
                                    onEntered: {
                                        hlb.color = Theme.primary
                                        hlb.radius = 5
                                    }
                                    onExited: {
                                        hlb.color = Theme.mid
                                        hlb.radius = 25
                                    }
                                }
                            }
                        }
                        Column {
                            id: controlCenterColumn
                            width: parent.width
                            spacing: 10
                            Rectangle {
                                width: parent.width
                                height: 0.03 * Screen.height
                                color: Theme.mid
                                radius: 15
                                Column {
                                    width: parent.width
                                    spacing: 4
                                    Text {
                                        text: Pipewire.defaultAudioSink?.audio?.muted ? "󰖁 няма" : "󰕾 " + Math.round(currentVolume * 100) + "%"
                                        font.family: "FiraMono Nerd Font"
                                        color: Theme.text
                                        x: (parent.width - width) / 2
                                        font.pixelSize: 0.0115 * Screen.height
                                    }
                                    Rectangle {
                                        id: ccVolumeBar
                                        width: parent.width - 20
                                        x: 10
                                        height: 0.008 * Screen.height
                                        radius: 4
                                        color: Theme.background
                                        Rectangle {
                                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                            width: parent.width * currentVolume
                                            radius: 4
                                            color: Theme.lightest
                                            Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                                            function setFromX(x) {
                                                let v = Math.max(0, Math.min(1, x / ccVolumeBar.width))
                                                if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio)
                                                    Pipewire.defaultAudioSink.audio.volume = v
                                            }
                                            onPressed: (mouse) => setFromX(mouse.x)
                                            onPositionChanged: (mouse) => { if (pressed) setFromX(mouse.x) }
                                        }
                                    }
                                }
                            }

                            Column {
                                id: wifiSection
                                width: parent.width
                                spacing: 4

                                Row {
                                    width: parent.width
                                    Text {
                                        width: parent.width - wifiRow2.width
                                        text: wifiRadioEnabled ? "󰤨 Wi-Fi" : "󰤭 Wi-Fi (вимкнено)"
                                        font.family: "FiraMono Nerd Font"
                                        color: Theme.text
                                        font.pixelSize: 0.0115 * Screen.height
                                    }
                                    Row {
                                        id: wifiRow2
                                        spacing: 4
                                        Rectangle {
                                            width: 0.028 * Screen.width
                                            height: 0.018 * Screen.height
                                            radius: 10
                                            color: Theme.mid
                                            Text { anchors.centerIn: parent; text: "󰑐"; color: Theme.text; font.family: "FiraMono Nerd Font"; font.pixelSize: 0.0095 * Screen.height }
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: wifiRescanProc.running = true
                                            }
                                        }
                                        Rectangle {
                                            width: 0.028 * Screen.width
                                            height: 0.018 * Screen.height
                                            radius: 10
                                            color: wifiRadioEnabled ? Theme.primary : Theme.mid
                                            Text { anchors.centerIn: parent; text: "󰤆"; color: Theme.text; font.pixelSize: 0.0095 * Screen.height }
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    wifiRadioEnabled = !wifiRadioEnabled
                                                    wifiToggleProc.command = ["nmcli", "radio", "wifi", wifiRadioEnabled ? "on" : "off"]
                                                    wifiToggleProc.running = true
                                                }
                                            }
                                        }
                                    }
                                }

                                Repeater {
                                    model: wifiNetworksModel
                                    delegate: Column {
                                        width: wifiSection.width
                                        spacing: 2
                                        Rectangle {
                                            width: parent.width
                                            height: 0.0225 * Screen.height
                                            radius: 12
                                            color: model.inUse ? Theme.primary : Theme.mid
                                            Behavior on color { ColorAnimation { duration: 100 } }
                                            Text {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 8
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: (model.security !== "--" ? "󰌾 " : "") + model.ssid
                                                color: Theme.text
                                                font.family: "FiraMono Nerd Font"
                                                font.pixelSize: 0.0105 * Screen.height
                                                elide: Text.ElideRight
                                                width: parent.width - 0.03 * Screen.width
                                            }
                                            Text {
                                                anchors.right: parent.right
                                                anchors.rightMargin: 8
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: model.signal + "%"
                                                color: Theme.text
                                                font.pixelSize: 0.0095 * Screen.height
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (model.inUse) {
                                                        wifiDisconnectProc.command = ["nmcli", "connection", "down", "id", model.ssid]
                                                        wifiDisconnectProc.running = true
                                                    } else if (model.security === "--") {
                                                        wifiConnectProc.command = ["nmcli", "device", "wifi", "connect", model.ssid]
                                                        wifiConnectProc.running = true
                                                    } else {
                                                        wifiPasswordTarget = (wifiPasswordTarget === model.ssid) ? "" : model.ssid
                                                        wifiPasswordText = ""
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            visible: wifiPasswordTarget === model.ssid
                                            width: parent.width
                                            height: visible ? 0.0225 * Screen.height : 0
                                            radius: 12
                                            color: Theme.background
                                            clip: true
                                            Row {
                                                anchors.fill: parent
                                                anchors.margins: 5
                                                spacing: 6
                                                TextInput {
                                                    id: wifiPwdInput
                                                    width: parent.width - 40
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    color: Theme.text
                                                    echoMode: TextInput.Password
                                                    font.pixelSize: 0.0105 * Screen.height
                                                    onTextChanged: wifiPasswordText = text
                                                    Keys.onReturnPressed: {
                                                        wifiConnectProc.command = ["nmcli", "device", "wifi", "connect", model.ssid, "password", wifiPasswordText]
                                                        wifiConnectProc.running = true
                                                    }
                                                }
                                                Text {
                                                    text: "OK"
                                                    color: Theme.text
                                                    font.pixelSize: 0.0105 * Screen.height
                                                    MouseArea {
                                                        anchors.fill: parent
                                                        anchors.margins: -6
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            wifiConnectProc.command = ["nmcli", "device", "wifi", "connect", model.ssid, "password", wifiPasswordText]
                                                            wifiConnectProc.running = true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Column {
                                id: btSection
                                width: parent.width
                                spacing: 4
                                Row {
                                    width: parent.width
                                    Text {
                                        width: parent.width - btRow2.width
                                        text: bluetoothRadioEnabled ? "󰂯 Bluetooth" : "󰂲 Bluetooth (вимкнено)"
                                        font.family: "FiraMono Nerd Font"
                                        color: Theme.text
                                        font.pixelSize: 0.0115 * Screen.height
                                    }
                                    Row {
                                        id: btRow2
                                        spacing: 4
                                        Rectangle {
                                            width: 0.028 * Screen.width
                                            height: 0.018 * Screen.height
                                            radius: 10
                                            color: Theme.mid
                                            Text { anchors.centerIn: parent; text: "󰑐"; color: Theme.text; font.family: "FiraMono Nerd Font"; font.pixelSize: 0.0095 * Screen.height }
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: btScanProc.running = true
                                            }
                                        }
                                        Rectangle {
                                            width: 0.028 * Screen.width
                                            height: 0.018 * Screen.height
                                            radius: 10
                                            color: bluetoothRadioEnabled ? Theme.primary : Theme.mid
                                            Text { anchors.centerIn: parent; text: "󰤆"; color: Theme.text; font.pixelSize: 0.0095 * Screen.height }
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    bluetoothRadioEnabled = !bluetoothRadioEnabled
                                                    btToggleProc.command = ["sh", "-c", "bluetoothctl power " + (bluetoothRadioEnabled ? "on" : "off")]
                                                    btToggleProc.running = true
                                                }
                                            }
                                        }
                                    }
                                }

                                Repeater {
                                    model: btDevicesModel
                                    delegate: Rectangle {
                                        width: btSection.width
                                        height: 0.0225 * Screen.height
                                        radius: 12
                                        color: model.connected ? Theme.primary : Theme.mid
                                        Behavior on color { ColorAnimation { duration: 100 } }
                                        Text {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 8
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.right: parent.right
                                            anchors.rightMargin: 8
                                            text: model.name
                                            color: Theme.text
                                            font.family: "FiraMono Nerd Font"
                                            font.pixelSize: 0.0105 * Screen.height
                                            elide: Text.ElideRight
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (model.connected) {
                                                    btDisconnectProc.command = ["bluetoothctl", "disconnect", model.mac]
                                                    btDisconnectProc.running = true
                                                } else {
                                                    btConnectProc.command = ["sh", "-c", "bluetoothctl pair " + model.mac + "; bluetoothctl trust " + model.mac + "; bluetoothctl connect " + model.mac]
                                                    btConnectProc.running = true
                                                }
                                            }
                                        }
                                    }
                                }
                                Text {
                                    visible: btDevicesModel.count === 0
                                    text: "No devices."
                                    color: Theme.text
                                    font.pixelSize: 0.0095 * Screen.height
                                    width: parent.width
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }
                    Rectangle {
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right

                        Image {
                            id: spinningImage
                            fillMode: Image.TileHorizontally
                            source: "images/kolovrat.svg"
                            x: -60
                            y: 300
                            scale: 0.5
                            RotationAnimation on rotation {
                                from: 0
                                to: 360
                                duration: 10000
                                loops: Animation.Infinite
                                running: true
                            }
                        }
                    }
                }
            }
        }
    }
    PanelWindow {
        WlrLayershell.layer: WlrLayer.Bottom
        exclusiveZone: 0.03123 * Screen.height
        color: "transparent"
        id: panel
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 0.03125 * Screen.height

        Rectangle {
            id: background
            anchors.fill: parent
            color: Theme.background

            Rectangle {
                id: rightDock
                color: Theme.mid
                anchors.topMargin: 0.00386 * Screen.height
                anchors.rightMargin: 0.00781 * Screen.width
                radius: 15
                height: 0.0229 * Screen.height
                anchors.leftMargin: 0.0039 * Screen.width
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.left: tmbg.right
            }

            Rectangle {
                id: leftDock
                color: Theme.mid
                anchors.topMargin: 0.00386 * Screen.height
                anchors.leftMargin: 0.00781 * Screen.width
                radius: 15
                height: 0.0229 * Screen.height
                anchors.rightMargin: 0.0039 * Screen.width
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: tmbg.left
            }
            Rectangle {
                id: wsbg
                color: Theme.midnext
                height: 0.0236 * Screen.height
                radius: 15
                anchors.verticalCenter: workspaces.verticalCenter
                anchors.left: workspaces.left
                anchors.leftMargin: (-0.005125) * Screen.width
                width: workspaces.width + 0.01025 * Screen.width
                Behavior on width {
                    NumberAnimation { duration: 50; }
                }
            }
            Rectangle {
                id: startMenu
                color: Theme.midnext
                height: 0.027777 * Screen.height
                radius: 25
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: background.left
                anchors.leftMargin: 5
                width: height
                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
                Behavior on radius {
                    NumberAnimation { duration: 100 }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // startMenu1.expanded = !startMenu1.expanded
                        closeDelay.start()
                        menuRect.width = 0 * Screen.height
                        menuRect.height = 0.310 * Screen.height
                        menuRect.opacity = 0
                    }
                    onEntered: {
                        parent.color = Theme.primary
                        parent.radius = 5
                        distroIcon.scale = 1
                    }
                    onExited: {
                        parent.color = Theme.midnext
                        parent.radius = 25
                        distroIcon.scale = 0.75
                    }
                }
            }
            Rectangle {
                id: audioDock
                color: Theme.midnext
                anchors.rightMargin: 0.0078125 * Screen.width
                anchors.right: parent.right
                anchors.top: leftDock.top
                anchors.bottom: rightDock.bottom
                radius: 25
                width: 0.078125 * Screen.width
                property real currentVolume: Pipewire.defaultAudioSink?.audio?.volume ?? 0
                Behavior on color {
                    ColorAnimation { duration: 100; easing.type: Easing.InOutQuad }
                }
                Behavior on radius {
                    NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                }
                Connections {
                    target: Pipewire.defaultAudioSink?.audio
                    function onVolumeChanged() {
                        if (Pipewire.defaultAudioSink?.audio?.volume !== undefined) {
                            audioDock.currentVolume = Pipewire.defaultAudioSink.audio.volume
                        } else {
                            audioDock.currentVolume = 0
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onEntered: {
                        parent.color = Theme.primary
                        parent.radius = 5
                    }
                    onExited: {
                        parent.color = Theme.midnext
                        parent.radius = 25
                    }
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onWheel: {
                        if (wheel.angleDelta.y > 0)
                            Pipewire.defaultAudioSink.audio.volume = Math.min(1.0, audioDock.currentVolume + 0.05)
                        else
                            Pipewire.defaultAudioSink.audio.volume = Math.max(0.0, audioDock.currentVolume - 0.05)
                    }
                    onClicked: {
                        if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                            let audio = Pipewire.defaultAudioSink.audio
                            audio.muted = !audio.muted
                        }
                    }
                }

                Text {
                    anchors.top: parent
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.left: parent
                    anchors.right: parent
                    color: Theme.text
                    font.pixelSize: 0.01111 * Screen.height
                    font.family: "FiraMono Nerd Font"
                    text: Pipewire.defaultAudioSink?.audio?.muted ? "󰖁 няма" : "󰕾 " + Math.round(audioDock.currentVolume * 100) + "%"
                }

                Rectangle {
                    id: volumeBar
                    anchors {
                        left: parent.left
                        bottom: parent.bottom
                        leftMargin: 0.003906 * Screen.width
                        bottomMargin: 0.004166 * Screen.height
                    }
                    height: 0.004166 * Screen.height
                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                    width: parent.width - (0.0078125 * Screen.width)
                    radius: 3
                    color: Theme.background

                    Rectangle {
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: parent.width * audioDock.currentVolume
                        radius: 3
                        color: Theme.lightest
                        Behavior on width {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }
            Rectangle {
                id: kblayoutrect
                anchors.top: rightDock.top
                anchors.right: audioDock.left
                anchors.bottom: rightDock.bottom
                anchors.rightMargin: 6
                width: 0.02 * Screen.width
                radius: 25
                color: Theme.midnext
                Behavior on color {
                    ColorAnimation { duration: 100; easing.type: Easing.InOutQuad }
                }
                Behavior on radius {
                    NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                }
                Text {
                    id: samlayout
                    text: slid
                    color: Theme.text
                    font.pixelSize: 0.012 * Screen.height
                    font.family: "Monospace"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
                MouseArea {
                    id: kbtoggler
                    property var slid: 1
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        parent.radius = 5
                        parent.color = Theme.primary
                    }
                    onExited: {
                        parent.radius = 25
                        parent.color = Theme.midnext
                    }
                    onClicked: {
                        if (slid < 1) {
                            commandRunner.command = ["niri", "msg", "action", "switch-layout", slid + 1]
                            commandRunner.running = true;
                        }
                        if (slid == 1) {
                            commandRunner.command = ["niri", "msg", "action", "switch-layout", "0"]
                            commandRunner.running = true;
                        }
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }
            Rectangle {
                id: fwrect
                anchors.leftMargin: 7
                color: "transparent"
                anchors.left: wsbg.right
                anchors.right: leftDock.right
                anchors.top: leftDock.top
                anchors.bottom: leftDock.bottom
                Text {
                    text: NiriEvents.focusedWindowTitle
                    color: Theme.text
                    font.pixelSize: 0.010888 * Screen.height
                    font.family: "Monospace"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Rectangle {
                id: tmbg
                color: Theme.midnext
                height: 0.023611 * Screen.height
                radius: 14
                anchors.verticalCenter: panel.verticalCenter
                anchors.topMargin: 5
                anchors.top: parent.top
                anchors.left: timeDisplay.left
                anchors.leftMargin: (-0.0125) * Screen.width
                width: timeDisplay.width + (0.025 * Screen.width)

                Behavior on width {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }
            }
            RowLayout {
                id: workspaces
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 0.03125 * Screen.width
                }
                spacing: 0.00078125 * Screen.width

                Repeater {
                    model: niri.workspaces

                    Rectangle {
                        id: wsrect
                        property bool hovered: false
                        width: 0.009084375 * Screen.width
                        height: 0.01484375 * Screen.height
                        scale: hovered ? 1 : (model.isActive ? 1 : 0.5)
                        radius: hovered ? 5 : 40
                        color: model.isActive ? Theme.primary : Theme.mid
                        visible: index < 10
                        Behavior on color {
                            ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                        }
                        Behavior on scale {
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }
                        Behavior on radius {
                            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: niri.focusWorkspaceById(model.id)
                            onEntered: wsrect.hovered = true
                            onExited: wsrect.hovered = false
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
            Text {
                id: timeDisplay
                anchors {
                    verticalCenter: parent.verticalCenter
                    centerIn: parent
                }

                property string currentTime: ""

                text: currentTime
                color: Theme.text
                font.pixelSize: 0.0138888 * Screen.height
                font.family: "Liberation Mono"
                
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        var now = new Date()
                        timeDisplay.currentTime = Qt.formatDate(now, "MMMM dd") + " " + Qt.formatTime(now, "hh:mm:ss")  
                    }
                }
                
                Component.onCompleted: {
                    var now = new Date()
                    currentTime = Qt.formatDate(now, "MMMM dd") + " " + Qt.formatTime(now, "hh:mm:ss")
                }
            }
            
            Text {
                id: distroIcon
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: startMenu.horizontalCenter
                }
                color: Theme.text
                font.family: "FiraMono Nerd Font"
                text: "󰌽"
                font.pixelSize: Screen.height * 0.02289
		scale: 0.75
                Behavior on scale {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
            }
        }
    }
}
