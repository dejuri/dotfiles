pragma Singleton
import QtQuick
import Quickshell
import Niri 0.1

// Just niri import
Singleton {
    id: root

    readonly property var workspaces: niri.workspaces
    function focusWorkspace(id) { niri.focusWorkspaceById(id) }

    Niri {
        id: niri
        Component.onCompleted: connect()
        onConnected: console.info("Connected to niri")
        onErrorOccurred: error => console.error("Niri error:", error)
    }
}
