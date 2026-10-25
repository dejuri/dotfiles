pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    function setVolume(v) {
        if (sink?.audio) sink.audio.volume = Math.max(0, Math.min(1, v))
    }
    function step(delta) { setVolume(volume + delta) }
    function toggleMute() {
        if (sink?.audio) sink.audio.muted = !sink.audio.muted
    }

    PwObjectTracker { objects: [root.sink] }
}
