import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.services
import '../theme'

Scope {
    id: root

    readonly property bool open: LauncherState.open
    readonly property string terminal: "kitty"
    readonly property int maxVisible: 7
    readonly property int rowHeight: 52

    IpcHandler {
        target: "launcher"
        function toggle(): void { LauncherState.toggle(); }
        function show(): void { LauncherState.show(); }
        function hide(): void { LauncherState.hide(); }
    }

    PanelWindow {
        id: win

        visible: root.open || card.opacity > 0
        color: "transparent"

        anchors.top: true
        margins.top: 45
        implicitWidth: 640
        implicitHeight: card.implicitHeight
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.namespace: "quickshell:launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        Rectangle {
            id: card

            property bool suppressLeave: false

            width: parent.width
            implicitHeight: col.implicitHeight + 28
            radius: 20
            color: Theme.mid
            opacity: root.open ? 1 : 0
            scale: root.open ? 1 : 0.9
            transformOrigin: Item.Top
            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            HoverHandler {
                id: hover
                onHoveredChanged: {
                    if (hovered) {
                        leaveTimer.stop();
                    } else if (root.open && !card.suppressLeave) {
                        leaveTimer.restart();
                    }
                }
            }
            Timer {
                id: leaveTimer
                interval: 200
                onTriggered: if (!hover.hovered) LauncherState.open = false
            }
            Timer {
                id: resizeGuard
                interval: 300
                onTriggered: card.suppressLeave = false
            }
            onImplicitHeightChanged: {
                card.suppressLeave = true;
                leaveTimer.stop();
                resizeGuard.restart();
            }
            Connections {
                target: root
                function onOpenChanged() {
                    leaveTimer.stop();
                    card.suppressLeave = false;
                }
            }
            property string query: ""
            
            readonly property var results: {
                const q = query.trim().toLowerCase();
                const apps = DesktopEntries.applications.values.filter(a => !a.noDisplay);

                if (q === "")
                    return apps.sort((a, b) => a.name.localeCompare(b.name));

                const score = a => {
                    const name = (a.name ?? "").toLowerCase();
                    if (name.startsWith(q)) return 100;
                    if (name.includes(" " + q)) return 80;
                    if (name.includes(q)) return 60;
                    if ((a.genericName ?? "").toLowerCase().includes(q)) return 40;
                    if ((a.keywords ?? []).join(" ").toLowerCase().includes(q)) return 30;
                    if ((a.comment ?? "").toLowerCase().includes(q)) return 15;
                    return 0;
                };

                return apps
                    .map(a => ({ a, s: score(a) }))
                    .filter(x => x.s > 0)
                    .sort((x, y) => y.s - x.s || x.a.name.localeCompare(y.a.name))
                    .map(x => x.a);
            }

            function launch(entry) {
                if (!entry) return;
                LauncherState.open = false;
                if (entry.runInTerminal)
                    Quickshell.execDetached([root.terminal, "-e", ...entry.command]);
                else
                    entry.execute();
            }

            Connections {
                target: root
                function onOpenChanged() {
                    if (root.open) {
                        input.text = "";
                        list.currentIndex = 0;
                        input.forceActiveFocus();
                    }
                }
            }

            ColumnLayout {
                id: col
                anchors {
                    left: parent.left; right: parent.right; top: parent.top
                    margins: 14
                }
                spacing: 10
                Item {
                    Layout.fillWidth: true
                    implicitHeight: 40

                    Text {
                        id: glyph
                        anchors.left: parent.left
                        anchors.leftMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: ""
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 22
                    }
                    TextInput {
                        id: input
                        anchors {
                            left: glyph.right; right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: 10; rightMargin: 6
                        }
                        color: Theme.text
                        selectionColor: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 17
                        clip: true
                        focus: true

                        onTextChanged: {
                            card.query = text;
                            list.currentIndex = 0;
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                LauncherState.open = false;
                            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                                list.incrementCurrentIndex();
                            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) {
                                list.decrementCurrentIndex();
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                card.launch(card.results[list.currentIndex]);
                            } else {
                                return;
                            }
                            event.accepted = true;
                        }

                        Text {
                            visible: input.text === ""
                            text: "Search an application"
                            color: Theme.text
                            font: input.font
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 5
                    radius: 2
                    color: Theme.midnext
                    visible: list.count > 0
                }
                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(count, root.maxVisible) * root.rowHeight
                    visible: count > 0
                    clip: true
                    model: card.results
                    currentIndex: 0
                    boundsBehavior: Flickable.StopAtBounds
                    highlightMoveDuration: 80
                    highlightFollowsCurrentItem: true
                    keyNavigationEnabled: false

                    highlight: Rectangle {
                        radius: 10
                        color: Theme.primary
                        border.color: Theme.primary
                        border.width: 1
                    }
                    delegate: Item {
                        id: row
                        required property var modelData
                        required property int index

                        width: ListView.view.width
                        height: root.rowHeight

                        function iconSource() {
                            const i = modelData.icon ?? "";
                            if (i.startsWith("/")) return "file://" + i;
                            return Quickshell.iconPath(i, "application-x-executable");
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: list.currentIndex = row.index
                            onClicked: card.launch(row.modelData)
                            
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 14

                            Image {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                source: row.iconSource()
                                sourceSize: Qt.size(64, 64)
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                smooth: true
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    Layout.fillWidth: true
                                    text: row.modelData.name
                                    color: list.currentIndex == row.index ? Theme.background : Theme.text
                                    font.family: Theme.font
                                    font.pixelSize: 15
                                    elide: Text.ElideRight

                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    text: row.modelData.comment || row.modelData.genericName || ""
                                    color: list.currentIndex == row.index ? Theme.background : Theme.text
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    elide: Text.ElideRight

                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }
                            }
                        }
                    }
                }
                Text {
                    Layout.fillWidth: true
                    visible: list.count === 0 && input.text !== ""
                    horizontalAlignment: Text.AlignHCenter
                    text: "Nichts gefunden :("
                    color: Theme.text
                    font.family: root.theme.font
                    font.pixelSize: 13
                    topPadding: 6
                    bottomPadding: 6
                }
            }
        }
    }
}