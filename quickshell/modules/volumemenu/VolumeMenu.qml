import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services

Scope {
    id: root

    readonly property bool open: UiState.volumeMenuOpen

    // Section title
    component Title: Text {
        font.family: Theme.font
        font.pixelSize: 13
        color: Theme.lighter
        leftPadding: 4
    }

    IpcHandler {
        target: "volumemenu"
        function toggle(): void { UiState.toggleVolumeMenu() }
        function show(): void { UiState.openVolumeMenu() }
        function hide(): void { UiState.volumeMenuOpen = false }
    }

    PanelWindow {
        id: win

        visible: root.open || card.opacity > 0
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; right: true }
        width: 1000
        margins.top: Config.bar.height
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:volumemenu"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        // Esc
        Item {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: UiState.volumeMenuOpen = false
        }

        Rectangle {
            id: card

            readonly property int pad: 14

            width: 380
            height: Math.min(content.implicitHeight + pad * 2, win.height - 20)
            anchors { top: parent.top; topMargin: 6; right: parent.right; rightMargin: 6 }
            radius: 25
            color: Theme.background
            clip: true

            transformOrigin: Item.TopRight
            scale: root.open ? 1 : 0.9
            opacity: root.open ? 1 : 0
            Behavior on scale { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
            }

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
                onTriggered: if (!hover.hovered) UiState.volumeMenuOpen = false
            }

            Flickable {
                anchors { fill: parent; margins: card.pad }
                contentWidth: width
                contentHeight: content.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Column {
                    id: content
                    width: parent.width
                    spacing: 8

                    // Output
                    Title { text: "Output" }
                    VolumeSlider {
                        width: parent.width
                        value: Audio.volume
                        muted: Audio.muted
                        icon: Audio.icon
                        onMoved: v => Audio.setVolume(v)
                        onIconClicked: Audio.toggleMute()
                    }
                    DeviceSelector {
                        width: parent.width
                        devices: Audio.sinks
                        current: Audio.sink
                        emptyText: "No output devices"
                        onSelected: d => Audio.setDefault(d)
                    }

                    Item { width: 1; height: 6 }

                    // Input
                    Title { text: "Input" }
                    VolumeSlider {
                        width: parent.width
                        value: Audio.micVolume
                        muted: Audio.micMuted
                        icon: Audio.micMuted ? Icons.microphoneOff : Icons.microphone
                        onMoved: v => Audio.setMicVolume(v)
                        onIconClicked: Audio.toggleMicMute()
                    }
                    DeviceSelector {
                        width: parent.width
                        devices: Audio.sources
                        current: Audio.source
                        emptyText: "No input devices"
                        onSelected: d => Audio.setDefault(d)
                    }

                    Item { width: 1; height: 6 }

                    // Apps
                    Title { text: "Applications" }
                    Text {
                        visible: Audio.streams.length === 0
                        width: parent.width
                        leftPadding: 4
                        text: "Nothing is playing"
                        font.family: Theme.font
                        font.pixelSize: 14
                        color: Theme.lighter
                    }
                    Repeater {
                        model: Audio.streams
                        delegate: AppVolumeRow {
                            required property var modelData
                            width: content.width
                            node: modelData
                        }
                    }
                }
            }
        }
    }
}
