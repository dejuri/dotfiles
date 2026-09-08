import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Niri 0.1
import qs.services
import "../theme"

Item {
    property real currentVolume: Pipewire.defaultAudioSink?.audio?.volume ?? 0
    Connections {
        target: Pipewire.defaultAudioSink?.audio
        function onVolumeChanged() {
            currentVolume = Pipewire.defaultAudioSink.audio.volume
        }
    }
    Process { id: commandRunner }
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
                command: ["sh", "-c", "systemctl reboot"]
            }
            property var logoutProcess: Process {
                command: ["sh", "-c", "niri msg action quit"]
            }
            property var poweroffProcess: Process {
                command: ["sh", "-c", "systemctl poweroff"]
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
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.margins: 20
                    spacing: 2

                    Text {
                        text: "Radian 13.0 Dinit"
                        font.family: "Jetbrains Mono"
                        font.pixelSize: 0.01667 * Screen.height
                        color: Theme.text
                    }

                    Rectangle {
                        id: pob
                        height: 0.02777 * Screen.height
                        width: parent.width
                        radius: 20
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
                            text: "󰤆 Вимикаємся"
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
                                pob.radius = 20
                            }
                        }
                    }
                    Rectangle {
                        id: rebb
                        height: 0.027777 * Screen.height
                        width: parent.width
                        radius: 20
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
                            text: " Ребутаєм"
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
                                rebb.radius = 20
                            }
                        }
                    }
                    Rectangle {
                        id: lob
                        height: 0.027777 * Screen.height
                        width: parent.width
                        radius: 20
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
                            text: "󰍃 Виходім із сесії"
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
                                lob.radius = 20
                            }
                        }
                    }
                    Rectangle {
                        id: hlb
                        height: 0.027777 * Screen.height
                        width: parent.width
                        radius: 20
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
                            text: " Локаєм"
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
                                hlb.radius = 20
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
                // Behavior on width {
                //     NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                // }
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
                font.family: "URW Gothic"
                
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
