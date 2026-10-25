import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config
import qs.services
import qs.modules.settings.pages

// Settings window
Scope {
    id: root

    IpcHandler {
        target: "settings"
        function toggle(): void { UiState.toggleSettings() }
        function show(): void { UiState.settingsOpen = true }
        function hide(): void { UiState.settingsOpen = false }
    }

    readonly property var pages: [
        { name: "General", icon: Icons.settings, page: "general" },
        { name: "Appearance", icon: Icons.palette, page: "appearance" },
        { name: "Wallpaper", icon: Icons.apps, page: "wallpaper" },
        { name: "Bar", icon: Icons.bar, page: "bar" },
        { name: "Dock", icon: Icons.apps, page: "dock" },
    ]

    LazyLoader {
        active: UiState.settingsOpen

        FloatingWindow {
            id: win
            title: "Shell Settings"
            implicitWidth: 860
            implicitHeight: 600
            minimumSize: Qt.size(640, 420)
            color: Theme.background
            visible: true
            onVisibleChanged: if (!visible) UiState.settingsOpen = false

            property int current: 0

            Item {
                anchors.fill: parent
                focus: true

                // Sidebar
                Rectangle {
                    id: sidebar
                    width: 200
                    anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                    color: Theme.mid

                    Column {
                        anchors { fill: parent; margins: 12 }
                        spacing: 6

                        Text {
                            text: Icons.settings + " Settings"
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 20
                            bottomPadding: 12
                        }

                        Repeater {
                            model: root.pages
                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                readonly property bool active: win.current === index

                                width: parent.width
                                height: 40
                                radius: active || ma.containsMouse ? 8 : 20
                                color: active ? Theme.primary : (ma.containsMouse ? Theme.midnext : Theme.mid)
                                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                Behavior on radius { NumberAnimation { duration: Theme.animFast } }

                                Text {
                                    anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                                    text: modelData.icon + "  " + modelData.name
                                    color: parent.active ? Theme.background : Theme.text
                                    font.family: Theme.font
                                    font.pixelSize: 15
                                }
                                MouseArea {
                                    id: ma
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: win.current = index
                                }
                            }
                        }
                    }
                }

                StackLayout {
                    anchors { top: parent.top; bottom: parent.bottom; left: sidebar.right; right: parent.right }
                    currentIndex: win.current

                    GeneralPage {}
                    AppearancePage {}
                    WallpaperPage {}
                    BarPage {}
                    DockPage {}
                    
                }
            }
        }
    }
}
