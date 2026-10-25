import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

// The doooock
Scope {
    LazyLoader {
        active: Config.dock.enabled

        PanelWindow {
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.namespace: "quickshell:dock"
            anchors { bottom: true; left: true; right: true }
            color: Theme.background
            implicitHeight: Config.dock.height

            Rectangle {
                width: row.width + 20
                height: parent.height - 10
                anchors.centerIn: parent
                color: Theme.mid
                radius: 25

                Row {
                    id: row
                    anchors.centerIn: parent
                    spacing: 8

                    Repeater {
                        model: Config.dock.pinnedApps
                        delegate: DockIcon {
                            required property string modelData
                            iconName: modelData
                            onClicked: Quickshell.execDetached([modelData])
                        }
                    }

                    Rectangle {
                        width: 4; height: 30; radius: 10
                        color: Theme.lighter
                        anchors.verticalCenter: parent.verticalCenter
                        visible: Windows.model.count > 0
                    }

                    Repeater {
                        model: Windows.model
                        delegate: DockIcon {
                            required property string appId
                            required property int winId
                            required property bool isFocused
                            iconName: appId
                            focused: isFocused
                            showHighlight: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => {
                                if (mouse.button === Qt.LeftButton) Windows.focus(winId)
                                else Windows.close(winId)
                            }
                        }
                    }
                }
            }
        }
    }
}
