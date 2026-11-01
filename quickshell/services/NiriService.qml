pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Workspaces via niri IPC event-stream (без Niri QML-модуля)
Singleton {
    id: root

    readonly property alias workspaces: wsModel

    ListModel { id: wsModel }

    function focusWorkspace(wsId) {
        for (let i = 0; i < wsModel.count; i++) {
            const w = wsModel.get(i)
            if (w.wsId !== wsId) continue
            Quickshell.execDetached([
                "sh", "-c",
                'niri msg action focus-workspace "$2"',
                "sh", w.output, String(w.idx)
            ])
            return
        }
    }

    function indexOfId(wsId) {
        for (let i = 0; i < wsModel.count; i++)
            if (wsModel.get(i).wsId === wsId) return i
        return -1
    }

    function toRow(w) {
        return {
            wsId: w.id,
            idx: w.idx,
            output: w.output || "",
            name: w.name || "",
            isActive: !!w.is_active,
            isFocused: !!w.is_focused,
            isUrgent: !!w.is_urgent
        }
    }

    function setWorkspaces(list) {
        list = list.slice().sort((a, b) =>
            a.output === b.output ? a.idx - b.idx : (a.output || "").localeCompare(b.output || ""))

        let same = list.length === wsModel.count
        for (let i = 0; same && i < list.length; i++)
            same = wsModel.get(i).wsId === list[i].id

        if (same) {
            list.forEach((w, i) => wsModel.set(i, toRow(w)))
        } else {
            wsModel.clear()
            list.forEach(w => wsModel.append(toRow(w)))
        }
    }

    function activate(wsId, focused) {
        const pos = indexOfId(wsId)
        if (pos < 0) return
        const out = wsModel.get(pos).output
        for (let i = 0; i < wsModel.count; i++) {
            const w = wsModel.get(i)
            if (w.output === out)
                wsModel.setProperty(i, "isActive", w.wsId === wsId)
            if (focused)
                wsModel.setProperty(i, "isFocused", w.wsId === wsId)
        }
    }

    function handleEvent(ev) {
        if (ev.WorkspacesChanged) {
            setWorkspaces(ev.WorkspacesChanged.workspaces)
        } else if (ev.WorkspaceActivated) {
            activate(ev.WorkspaceActivated.id, ev.WorkspaceActivated.focused)
        } else if (ev.WorkspaceUrgencyChanged) {
            const pos = indexOfId(ev.WorkspaceUrgencyChanged.id)
            if (pos >= 0) wsModel.setProperty(pos, "isUrgent", ev.WorkspaceUrgencyChanged.urgent)
        }
    }

    Process {
        id: stream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                try { root.handleEvent(JSON.parse(line)) }
                catch (e) { console.warn("NiriService: bad event line:", line) }
            }
        }
        onExited: (code) => {
            console.warn("niri event-stream exited:", code)
            restartTimer.start()
        }
    }

    Timer {
        id: restartTimer
        interval: 2000
        onTriggered: stream.running = true
    }
}