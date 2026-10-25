import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services

// Control center yeah
Scope {
    id: root

    readonly property bool open: UiState.controlCenterOpen

    IpcHandler {
        target: "controlcenter"
        function toggle(): void { UiState.toggleControlCenter() }
        function show(): void { UiState.controlCenterOpen = true }
        function hide(): void { UiState.controlCenterOpen = false }
    }

    PanelWindow {
        id: win

        visible: root.open || card.opacity > 0
        color: "transparent"
        exclusiveZone: 0
        implicitWidth: 350
        anchors { left: true; top: true; bottom: true }
        WlrLayershell.namespace: "quickshell:controlcenter"

        HoverHandler {
            id: hover
            onHoveredChanged: {
                if (hovered) leaveTimer.stop()
                else if (root.open) leaveTimer.restart()
            }
        }
        Timer {
            id: leaveTimer
            interval: 200
            onTriggered: if (!hover.hovered) UiState.controlCenterOpen = false
        }

        Rectangle {
            id: card
            width: 350
            height: Math.min(950, parent.height - 500)
            anchors.verticalCenter: parent.verticalCenter
            radius: 25
            color: Theme.background
            transformOrigin: Item.Left
            scale: root.open ? 1 : 0.8
            opacity: root.open ? 1 : 0
            Behavior on scale { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

            // KOLOVOROT!!!
            Image {
                anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: - 180 }
                source: Paths.image("kolovrat.svg")
                scale: 0.5
                opacity: 0.6
                RotationAnimation on rotation { from: 0; to: 360; duration: 10000; loops: Animation.Infinite; running: root.open }
            }

            Flickable {
                anchors { top: parent.top; topMargin: 14; horizontalCenter: parent.horizontalCenter }
                width: parent.width - 24
                height: parent.height - 28
                clip: true
                contentWidth: width
                contentHeight: column.height
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: column
                    width: parent.width
                    spacing: 20

                    Row {
                        width: parent.width
                        Text {
                            text: Config.general.osName
                            font.family: Theme.font
                            font.pixelSize: 24
                            color: Theme.text
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 50
                        }
                        HoverButton {
                            width: 40; height: 40
                            text: Icons.settings
                            fontSize: 18
                            onClicked: { UiState.controlCenterOpen = false; UiState.settingsOpen = true }
                        }
                    }

                    PowerButtons { anchors.left: parent.left; onActionTriggered: UiState.controlCenterOpen = false; anchors.leftMargin: 45 }

                    Column {
                        width: parent.width
                        spacing: 10

                        VolumeSlider {
                            width: parent.width
                            value: Audio.volume
                            icon: Audio.muted ? Icons.volumeMuted : Icons.volumeHigh
                            onMoved: v => Audio.setVolume(v)
                        }

                        Row {
                            width: parent.width
                            spacing: 5
                            WifiTile { width: parent.width / 2 - 2.5 }
                            BluetoothTile { width: parent.width / 2 - 2.5 }
                        }
                    }
                }
            }
        }
    }
}
