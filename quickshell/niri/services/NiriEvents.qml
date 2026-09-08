pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    property string focusedWindowTitle: ""
    signal keyboardLayoutChanged(int index, string name)
    signal windowOrWorkspaceChanged()
    property Process process: Process {
        command: ["niri", "msg", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.includes("Keyboard layout")) {
                    if (line.includes("0")) {
                        keyboardLayoutChanged(0, "us");
                    } else if (line.includes("1")) {
                        keyboardLayoutChanged(1, "укр");
                    }
                }
                if (line.includes("Window") || line.includes("Workspace")) {
                    windowOrWorkspaceChanged();
                }
                if (line.includes("Window opened or changed:")) {
                    if (line.includes("is_focused: true")) {
                        let titleMatch = line.match(/title: Some\("(.+?)"\)/)
                        if (titleMatch) {
                            focusedWindowTitle = titleMatch[1]
                        }
                    }
                }
                if (line.includes("Window focus changed:")) {
                    if (line.includes("None")) {
                        focusedWindowTitle = ""
                        return
                    }
                    let match = line.match(/Some\((\d+)\)/)
                    if (match) {
                        getWindowTitle(match[1])
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        getInitialFocusedWindow()
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
        stdout: SplitParser {
            onRead: (line) => {
                focusedWindowTitle = line
            }
        }
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

        stdout: SplitParser {
            onRead: (line) => {
                focusedWindowTitle = line
            }
        }
    }
}