pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Opened windows list in niri
Singleton {
    id: root
    readonly property var model: windowModel

    ListModel { id: windowModel }

    Connections {
        target: NiriEvents
        function onWindowOrWorkspaceChanged() { loader.run() }
    }

    Process {
        id: loader
        command: ["niri", "msg", "-j", "windows"]
        function run() { running = false; running = true }
        stdout: SplitParser {
            onRead: (line) => {
                try { root.update(JSON.parse(line)) } catch (e) { }
            }
        }
    }

    function update(newWindows) {
        newWindows.sort((a, b) => a.id - b.id)
        for (let i = windowModel.count - 1; i >= 0; i--) {
            if (!newWindows.some(w => w.id === windowModel.get(i).winId))
                windowModel.remove(i)
        }
        newWindows.forEach((win, index) => {
            let found = -1
            for (let i = 0; i < windowModel.count; i++) {
                if (windowModel.get(i).winId === win.id) { found = i; break }
            }
            if (found !== -1) {
                windowModel.setProperty(found, "isFocused", win.is_focused || false)
                if (found !== index) windowModel.move(found, index, 1)
            } else {
                windowModel.insert(index, {
                    appId: win.app_id || "unknown",
                    winId: win.id,
                    isFocused: win.is_focused || false
                })
            }
        })
    }

    function focus(id) { Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", id.toString()]) }
    function close(id) { Quickshell.execDetached(["niri", "msg", "action", "close-window", "--id", id.toString()]) }

    Component.onCompleted: loader.run()
}
