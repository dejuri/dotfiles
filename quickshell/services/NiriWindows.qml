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

    // Order set by dragging icons in the dock (window ids, not saved between sessions)
    property var customOrder: []

    function moveWindow(from, to) {
        if (from === to || to < 0 || to >= windowModel.count) return
        windowModel.move(from, to, 1)
        const ids = []
        for (let i = 0; i < windowModel.count; i++) ids.push(windowModel.get(i).winId)
        customOrder = ids
    }

    function update(newWindows) {
        customOrder = customOrder.filter(id => newWindows.some(w => w.id === id))
        const rank = id => { const i = customOrder.indexOf(id); return i === -1 ? Infinity : i }
        newWindows.sort((a, b) => {
            const ra = rank(a.id), rb = rank(b.id)
            return ra === rb ? a.id - b.id : (ra < rb ? -1 : 1)
        })
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
                windowModel.setProperty(found, "workspaceId", win.workspace_id ?? -1)
                if (found !== index) windowModel.move(found, index, 1)
            } else {
                windowModel.insert(index, {
                    appId: win.app_id || "unknown",
                    winId: win.id,
                    pid: win.pid ?? 0,
                    workspaceId: win.workspace_id ?? -1,
                    isFocused: win.is_focused || false
                })
            }
        })
    }

    readonly property string stashName: "stash"

    function focus(id) { Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", id.toString()]) }
    function close(id) { Quickshell.execDetached(["niri", "msg", "action", "close-window", "--id", id.toString()]) }

    function isStash(wsId) {
        const m = NiriService.workspaces
        for (let i = 0; i < m.count; i++) {
            const w = m.get(i)
            if (w.wsId === wsId) return w.name === stashName
        }
        return false
    }

    function focusedWorkspaceIdx() {
        const m = NiriService.workspaces
        for (let i = 0; i < m.count; i++)
            if (m.get(i).isFocused) return m.get(i).idx
        return 1
    }

    function minimize(id) {
        Quickshell.execDetached(["niri", "msg", "action", "move-window-to-workspace",
            "--window-id", String(id), "--focus", "false", stashName])
    }

    function restore(id) {
        Quickshell.execDetached(["sh", "-c",
            'niri msg action move-window-to-workspace --window-id "$1" --focus false "$2" && niri msg action focus-window --id "$1"',
            "sh", String(id), String(focusedWorkspaceIdx())])
    }

    function kill(pid) {
        if (pid > 0) Quickshell.execDetached(["kill", "-KILL", String(pid)])
    }
    Component.onCompleted: loader.run()
}
