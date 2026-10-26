pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property string focusedWindowTitle: ""
    property int keyboardLayoutIndex: 0
    property string keyboardLayoutName: ""
    property var keyboardLayoutNames: []

    signal keyboardLayoutChanged(int index, string name)
    signal windowOrWorkspaceChanged()

    function setLayout(index, name) {
        keyboardLayoutIndex = index
        keyboardLayoutName = name ? name.substring(0, 2).toLowerCase() : ""
        keyboardLayoutChanged(index, keyboardLayoutName)
    }

    Component.onCompleted: {
        getInitialFocusedWindow()
    }

    property Process process: Process {
        command: ["niri", "msg", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.includes("Keyboard layouts changed:")) {
                    let namesMatch = line.match(/names:\s*\[(.*?)\]/)
                    let idxMatch = line.match(/current_idx:\s*(\d+)/)

                    if (namesMatch) {
                        keyboardLayoutNames = namesMatch[1].split(/,\s*/).map(s => s.replace(/^"|"$/g, ''))
                    }
                    if (idxMatch) {
                        let idx = parseInt(idxMatch[1])
                        let name = keyboardLayoutNames[idx] || ("l" + idx)
                        setLayout(idx, name)
                    }
                }

                if (line.includes("Keyboard layout switched:")) {
                    let match = line.match(/Keyboard layout switched:\s*(\d+)/)
                    if (match) {
                        let idx = parseInt(match[1])
                        let name = keyboardLayoutNames[idx] || ("l" + idx)
                        setLayout(idx, name)
                    }
                }

                if (line.includes("Window") || line.includes("Workspace")) {
                    windowOrWorkspaceChanged()
                }
                if (line.includes("Window opened or changed:")) {
                    if (line.includes("is_focused: true")) {
                        let titleMatch = line.match(/title: Some\("(.+?)"\)/)
                        if (titleMatch) focusedWindowTitle = titleMatch[1]
                    }
                }
                if (line.includes("Window focus changed:")) {
                    if (line.includes("None")) {
                        focusedWindowTitle = ""
                        return
                    }
                    let match = line.match(/Some\((\d+)\)/)
                    if (match) getWindowTitle(match[1])
                }
            }
        }
    }

    function getInitialFocusedWindow() {
        initProcess.command = [
            "sh", "-c",
            "niri msg windows | sed -n '/(focused)/{n;s/.*Title: \"\\(.*\\)\"/\\1/p}'"
        ]
        initProcess.running = true
    }
    property Process initProcess: Process {
        running: false
        stdout: SplitParser { onRead: (line) => focusedWindowTitle = line }
    }

    function getWindowTitle(id) {
        titleProcess.command = [
            "sh", "-c",
            `niri msg windows | awk '/Window ID ${id}:/{f=1} f && /Title:/{gsub(/.*Title: "|"/,""); print; exit}'`
        ]
        titleProcess.running = true
    }
    property Process titleProcess: Process {
        running: false
        stdout: SplitParser { onRead: (line) => focusedWindowTitle = line }
    }
}