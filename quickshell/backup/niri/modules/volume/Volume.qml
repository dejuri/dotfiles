import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

Scope {
    id: root

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    property bool shouldShowOsd: false
    property real lastVolume: -1

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.shouldShowOsd = false
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio

    }

    LazyLoader {
        active: root.shouldShowOsd
        onActiveChanged: console.log("OSD active:", active)
    }
}