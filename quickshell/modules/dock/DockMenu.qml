import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

Scope {
    id: root

readonly property bool open: UiState.dockMenuOpen
readonly property var target: UiState.dockMenuTarget

function hide() { UiState.hideDockMenu() }
    readonly property bool isPinned:
        target ? Config.dock.pinnedApps.includes(target.appId) : false

    readonly property var items: {
        const t = root.target
        if (!t) return []
        if (t.kind === "pinned") return [
            { label: "Open",   action: "launch" },
            { label: "Unpin",  action: "unpin" }
        ]
        return [
            { label: t.minimized ? "Restore" : "Minimize", action: t.minimized ? "restore" : "minimize" },
            { label: root.isPinned ? "Unpin" : "Pin",      action: root.isPinned ? "unpin" : "pin" },
            { label: "Close window",  action: "close" },
            { label: "Kill process",  action: "kill", danger: true }
        ]
    }

    function run(action) {
        const t = target
        hide()
        if (!t) return
        switch (action) {
        case "launch":   Quickshell.execDetached([t.appId]); break
        case "pin":      Config.dock.pinnedApps = [...Config.dock.pinnedApps, t.appId]; break
        case "unpin":    Config.dock.pinnedApps = Config.dock.pinnedApps.filter(a => a !== t.appId); break
        case "minimize": NiriWindows.minimize(t.winId); break
        case "restore":  NiriWindows.restore(t.winId); break
        case "close":    NiriWindows.close(t.winId); break
        case "kill":     NiriWindows.kill(t.pid); break
        }
    }

    component MenuRow: Rectangle {
        id: row
        property string label: ""
        property bool danger: false
        signal activated()

        height: 34
        radius: 12
        color: ma.containsMouse ? (danger ? "#e5484d" : Theme.primary) : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        Text {
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            text: row.label
            font.family: Theme.font
            font.pixelSize: 14
            color: ma.containsMouse ? (row.danger ? "white" : Theme.background)
                                    : (row.danger ? "#e5484d" : Theme.text)
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.activated()
        }
    }

    PanelWindow {
        id: win

        visible: root.open || card.opacity > 0
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }
        margins.bottom: Config.dock.height
        margins.top: Screen.height - Config.dock.height - card.height
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:dockmenu"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        HoverHandler {
            id: hover
            onHoveredChanged: {
                if (hovered) leaveTimer.stop()
                else if (root.open) leaveTimer.restart()
            }
        }
        // Esc
        Item {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: root.hide()
        }

        Rectangle {
            id: card

            readonly property real wantedX: (root.target ? root.target.x : 0) - width / 2
            Timer {
                id: leaveTimer
                interval: 200
                onTriggered: if (!hover.hovered) UiState.dockMenuOpen = false
            }
            width: 190
            height: col.implicitHeight + 16
            x: Math.max(8, Math.min(win.width - width - 8, wantedX))
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8

            radius: 18
            color: Theme.background


            transformOrigin: Item.Bottom
            scale: root.open ? 1 : 0.9
            opacity: root.open ? 1 : 0
            Behavior on scale   { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }


            MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onExited: leaveTimer.restart() }

            Column {
                id: col
                x: 8
                y: 8
                width: parent.width - 16
                spacing: 2

                Repeater {
                    model: root.items
                    delegate: MenuRow {
                        required property var modelData
                        width: col.width
                        label: modelData.label
                        danger: !!modelData.danger
                        onActivated: root.run(modelData.action)
                    }
                }
            }
        }
    }
}
