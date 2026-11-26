import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components
import qs.services

// The doooock
Scope {
    DockMenu {
        id: dm
    }

    LazyLoader {
        active: Config.dock.enabled
        PanelWindow {
            id: dockWindow
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.namespace: "quickshell:dock"
            anchors { bottom: true; left: true; right: true }
            color: Theme.background
            implicitHeight: Config.dock.height

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: event => flick.scrollBy((event.angleDelta.y || event.angleDelta.x))
            }

            // Cava on left side
            CavaSide {
                visible: Config.dock.cavaEnabled
                mirrored: true
                anchors {
                    top: parent.top; bottom: parent.bottom
                    left: parent.left; right: dockPanel.left
                    topMargin: 6; bottomMargin: 6
                    leftMargin: 12; rightMargin: 12
                }
            }

            // Cava on right side
            CavaSide {
                visible: Config.dock.cavaEnabled
                anchors {
                    top: parent.top; bottom: parent.bottom
                    left: dockPanel.right; right: parent.right
                    topMargin: 6; bottomMargin: 6
                    leftMargin: 12; rightMargin: 12
                }
            }

            // Main dock panel
            Rectangle {
                id: dockPanel
                readonly property real sideSpace: 160
                readonly property real padding: height * 0.4
                readonly property real maxContentWidth: dockWindow.width - 2 * sideSpace - padding

                height: dockWindow.height - 10
                width: flick.width + padding
                anchors.centerIn: parent
                color: Theme.mid
                radius: height / 2.5

                Flickable {
                    id: flick
                    anchors.centerIn: parent
                    height: dockWindow.height
                    width: Math.min(row.width, dockPanel.maxContentWidth)
                    contentWidth: row.width
                    contentHeight: height
                    clip: true

                    interactive: false
                    flickableDirection: Flickable.HorizontalFlick
                    boundsBehavior: Flickable.StopAtBounds

                    NumberAnimation {
                        id: wheelAnim
                        target: flick
                        property: "contentX"
                        duration: 140
                        easing.type: Easing.OutCubic
                    }

                    function scrollBy(delta) {
                        const max = Math.max(0, contentWidth - width)
                        const base = wheelAnim.running ? wheelAnim.to : contentX
                        const to = Math.max(0, Math.min(max, base + delta))
                        wheelAnim.stop()
                        wheelAnim.to = to
                        wheelAnim.start()
                    }


                    Row {
                        id: row
                        height: dockPanel.height - 8
                        y: (flick.height - height) / 2
                        spacing: Math.max(4, dockPanel.height * 0.06)

                        // Pinned apps, drag to reorder
                        ReorderList {
                            id: pinnedList
                            orientation: ListView.Horizontal
                            height: row.height
                            width: contentWidth
                            spacing: row.spacing
                            keys: Config.dock.pinnedApps
                            onReordered: list => Config.dock.pinnedApps = list

                            delegate: ReorderSlot {
                                id: pinnedSlot
                                required property string key
                                width: row.height
                                height: row.height

                                DockIcon {
                                    id: pinnedIcon
                                    iconName: pinnedSlot.key
                                    width: pinnedSlot.width
                                    height: pinnedSlot.height
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onClicked: mouse => {
                                        if (mouse.button === Qt.LeftButton) {
                                            Quickshell.execDetached([pinnedSlot.key])
                                        } else if (mouse.button === Qt.RightButton) {
                                            const t = UiState.dockMenuTarget
                                            const isSamePinned = UiState.dockMenuOpen && t &&
                                                t.kind === "pinned" &&
                                                t.appId === pinnedSlot.key

                                            if (isSamePinned) {
                                                UiState.hideDockMenu()
                                            } else {
                                                UiState.showDockMenu({
                                                    kind: "pinned",
                                                    appId: pinnedSlot.key,
                                                    x: pinnedIcon.mapToItem(null, pinnedIcon.width / 2, 0).x
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Separator
                        Rectangle {
                            width: Math.max(2, parent.height * 0.08)
                            height: parent.height * 0.6
                            radius: width / 2
                            color: Theme.lighter
                            anchors.verticalCenter: parent.verticalCenter
                            visible: NiriWindows.model.count > 0
                        }

                        // Active windows
                        ListView {
                            id: windowsListView
                            orientation: ListView.Horizontal
                            height: row.height
                            width: contentWidth
                            interactive: false
                            spacing: 0

                            model: NiriWindows.model

                            // Used by ReorderSlot while dragging
                            function moveItem(from, to) { NiriWindows.moveWindow(from, to) }
                            function commit() {}

                            move: Transition { NumberAnimation { properties: "x"; duration: 150; easing.type: Easing.OutCubic } }
                            displaced: Transition { NumberAnimation { properties: "x"; duration: 150; easing.type: Easing.OutCubic } }

                            delegate: ReorderSlot {
                                id: slot

                                required property string appId
                                required property int winId
                                required property bool isFocused
                                required property int pid
                                required property int workspaceId
                                readonly property bool minimized: NiriWindows.isStash(workspaceId)

                                property real progress: 0

                                width: (row.height + row.spacing) * progress
                                height: row.height

                                Component.onCompleted: appearAnim.start()
                                NumberAnimation {
                                    id: appearAnim
                                    target: slot
                                    property: "progress"
                                    from: 0
                                    to: 1
                                    duration: 260
                                    easing.type: Easing.OutCubic
                                }

                                ListView.onRemove: SequentialAnimation {
                                    PropertyAction { target: slot; property: "ListView.delayRemove"; value: true }
                                    NumberAnimation {
                                        target: slot
                                        property: "progress"
                                        to: 0
                                        duration: 220
                                        easing.type: Easing.InCubic
                                    }
                                    PropertyAction { target: slot; property: "ListView.delayRemove"; value: false }
                                }


                                DockIcon {
                                    id: winIcon
                                    x: (slot.width - row.spacing * slot.progress - width) / 2
                                    width: row.height
                                    height: row.height

                                    scale: slot.progress

                                    iconName: slot.appId
                                    focused: slot.isFocused
                                    showHighlight: slot.minimized ? false : true
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    opacity: Math.min(1, slot.progress * 1.5) * (slot.minimized ? 0.45 : 1)
                                    onClicked: mouse => {
                                        if (mouse.button === Qt.LeftButton) {
                                            if (slot.minimized) NiriWindows.restore(slot.winId)
                                            else NiriWindows.focus(slot.winId)
                                        } else if (mouse.button === Qt.RightButton) {
                                            const t = UiState.dockMenuTarget
                                            const isSameWindowMenu = UiState.dockMenuOpen && t &&
                                                t.kind === "window" &&
                                                t.winId === slot.winId

                                            if (isSameWindowMenu) {
                                                UiState.hideDockMenu()
                                            } else {
                                                UiState.showDockMenu({
                                                    kind: "window",
                                                    appId: slot.appId,
                                                    winId: slot.winId,
                                                    pid: slot.pid,
                                                    minimized: slot.minimized,
                                                    x: winIcon.mapToItem(null, winIcon.width / 2, 0).x
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}