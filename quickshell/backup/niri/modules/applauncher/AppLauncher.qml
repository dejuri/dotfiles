import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Top-anchored app launcher.
// Toggle: qs ipc call launcher toggle   (show / hide також є)
Scope {
    id: root

    property bool open: false

    // ── Тема: заміни на свої токени/синглтон ────────────────────────────
    readonly property QtObject theme: QtObject {
        readonly property color bg: "#e61e2327"
        readonly property color border: "#33ffffff"
        readonly property color text: "#d3c6aa"
        readonly property color subtext: "#859289"
        readonly property color accent: "#a7c080"
        readonly property color selection: "#2a3a30"
        readonly property int radius: 18
        readonly property string font: "sans-serif"
    }

    readonly property string terminal: "kitty"   // для Terminal=true
    readonly property int maxVisible: 7
    readonly property int rowHeight: 52

    IpcHandler {
        target: "launcher"
        function toggle(): void { root.open = !root.open; }
        function show(): void { root.open = true; }
        function hide(): void { root.open = false; }
    }

    PanelWindow {
        id: win

        visible: root.open || card.opacity > 0
        color: "transparent"

        anchors.top: true          // лише top → центр по горизонталі
        margins.top: 72
        implicitWidth: 640
        implicitHeight: card.implicitHeight
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.namespace: "quickshell:launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.open
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None

        Rectangle {
            id: card

            width: parent.width
            implicitHeight: col.implicitHeight + 28
            radius: root.theme.radius
            color: Theme.lighter
            border.color: Theme.lighter
            border.width: 1

            opacity: root.open ? 1 : 0
            scale: root.open ? 1 : 0.97
            transformOrigin: Item.Top
            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

            // ── Дані ────────────────────────────────────────────────────
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
                root.open = false;
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

                // ── Пошук ───────────────────────────────────────────────
                Item {
                    Layout.fillWidth: true
                    implicitHeight: 40

                    Text {
                        id: glyph
                        anchors.left: parent.left
                        anchors.leftMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: "⌕"
                        color: Theme.primary
                        font.pixelSize: 22
                    }

                    TextInput {
                        id: input
                        anchors {
                            left: glyph.right; right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: 10; rightMargin: 6
                        }
                        color: root.theme.text
                        selectionColor: Theme.primary
                        font.family: root.theme.font
                        font.pixelSize: 17
                        clip: true
                        focus: true

                        onTextChanged: {
                            card.query = text;
                            list.currentIndex = 0;
                        }

                        Keys.onPressed: event => {
                            const ctrl = event.modifiers & Qt.ControlModifier;
                            if (event.key === Qt.Key_Escape) {
                                root.open = false;
                            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab
                                       || (ctrl && (event.key === Qt.Key_N || event.key === Qt.Key_J))) {
                                list.incrementCurrentIndex();
                            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab
                                       || (ctrl && (event.key === Qt.Key_P || event.key === Qt.Key_K))) {
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
                            text: "Пошук застосунків…"
                            color: root.theme.subtext
                            font: input.font
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.primary
                    visible: list.count > 0
                }

                // ── Список ──────────────────────────────────────────────
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
                        radius: root.theme.radius - 6
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
                                    color: root.theme.text
                                    font.family: root.theme.font
                                    font.pixelSize: 15
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    text: row.modelData.comment || row.modelData.genericName || ""
                                    color: root.theme.subtext
                                    font.family: root.theme.font
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: list.count === 0 && input.text !== ""
                    horizontalAlignment: Text.AlignHCenter
                    text: "Нічого не знайдено"
                    color: root.theme.subtext
                    font.family: root.theme.font
                    font.pixelSize: 13
                    topPadding: 6
                    bottomPadding: 6
                }
            }
        }
    }
}