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

                    Repeater {
                        model: Config.dock.pinnedApps
                        delegate: DockIcon {
                            required property string modelData
                            iconName: modelData
                            width: row.height
                            height: row.height
                            onClicked: Quickshell.execDetached([modelData])
                        }
                    }

                    Rectangle {
                        width: Math.max(2, parent.height * 0.08)
                        height: parent.height * 0.6
                        radius: width / 2
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
                            width: row.height
                            height: row.height
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