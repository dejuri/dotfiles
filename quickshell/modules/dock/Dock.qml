import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

// The doooock
Scope {
    DockMenu {}

    LazyLoader {
        active: Config.dock.enabled
        PanelWindow {
            id: dockWindow
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.namespace: "quickshell:dock"
            anchors { bottom: true; left: true; right: true }
            color: Theme.background
            implicitHeight: Config.dock.height
            
            // Main dock panel
            Rectangle {

                height: dockWindow.height - 12
                width: row.width + (height * 0.4)
                anchors.centerIn: parent
                color: Theme.mid
                radius: height / 2.5

                Row {
                    id: row
                    anchors.centerIn: parent
                    height: parent.height - 8
                    spacing: Math.max(4, parent.height * 0.06)

                    // Pinned apps
                    Repeater {
                        model: Config.dock.pinnedApps
                        delegate: DockIcon {
                            id: pinnedIcon
                            required property string modelData
                            iconName: modelData
                            width: row.height
                            height: row.height
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => {
                                if (mouse.button === Qt.LeftButton) Quickshell.execDetached([modelData])
                                else UiState.showDockMenu({ kind: "pinned", appId: modelData,
                                    x: pinnedIcon.mapToItem(null, pinnedIcon.width / 2, 0).x })
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

                        delegate: Item {
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
                                    } else {
                                        if (UiState.dockMenuOpen) {
                                            UiState.hideDockMenu()
                                        }
                                        else {
                                            UiState.showDockMenu({ kind: "window", appId: slot.appId, winId: slot.winId,
                                                            pid: slot.pid, minimized: slot.minimized,
                                                            x: winIcon.mapToItem(null, winIcon.width / 2, 0).x })
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