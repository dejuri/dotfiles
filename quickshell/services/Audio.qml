pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.config

// Everything about sound: default output/input, devices, per-app streams
Singleton {
    id: root

    // Default output (speakers/headphones)
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property string icon: volumeIcon(volume, muted)

    // Default input (microphone)
    readonly property var source: Pipewire.defaultAudioSource
    readonly property real micVolume: source?.audio?.volume ?? 0
    readonly property bool micMuted: source?.audio?.muted ?? false

    // Lists for the volume menu. Filtered by media.class because it is unambiguous
    readonly property var nodes: Pipewire.nodes.values
    readonly property var sinks: nodes.filter(n => n.audio && mediaClass(n).startsWith("Audio/Sink"))
    readonly property var sources: nodes.filter(n => n.audio && mediaClass(n).startsWith("Audio/Source"))
    readonly property var streams: nodes
        .filter(n => n.audio && mediaClass(n) === "Stream/Output/Audio")
        .sort((a, b) => a.id - b.id)

    function mediaClass(n) { return (n?.properties ?? {})["media.class"] ?? "" }

    function volumeIcon(v, mute) {
        if (mute || v <= 0) return Icons.volumeMuted
        if (v < 0.34) return Icons.volumeLow
        if (v < 0.67) return Icons.volumeMedium
        return Icons.volumeHigh
    }

    // Human readable names
    function deviceName(n) {
        if (!n) return ""
        return n.nickname || n.description || n.name || ""
    }
    function streamName(n) {
        const p = n?.properties ?? {}
        return p["application.name"] || n?.description || n?.name || "Unknown"
    }
    function streamDetail(n) {
        const m = (n?.properties ?? {})["media.name"] ?? ""
        return m === streamName(n) ? "" : m
    }
    function deviceIcon(n) {
        const p = n?.properties ?? {}
        const hint = ((p["device.form-factor"] ?? "") + " " + (p["device.icon-name"] ?? "")).toLowerCase()
        return /headphone|headset|bluez|bluetooth/.test(hint) ? Icons.headphones : Icons.speaker
    }

    // Default output
    function setVolume(v) {
        if (sink?.audio) sink.audio.volume = Math.max(0, Math.min(1, v))
    }
    function step(delta) { setVolume(volume + delta) }
    function toggleMute() {
        if (sink?.audio) sink.audio.muted = !sink.audio.muted
    }

    // Default input
    function setMicVolume(v) {
        if (source?.audio) source.audio.volume = Math.max(0, Math.min(1, v))
    }
    function toggleMicMute() {
        if (source?.audio) source.audio.muted = !source.audio.muted
    }

    // Any node (app streams)
    function setNodeVolume(n, v) {
        if (n?.audio) n.audio.volume = Math.max(0, Math.min(1, v))
    }
    function toggleNodeMute(n) {
        if (n?.audio) n.audio.muted = !n.audio.muted
    }

    // wpctl so it works on any quickshell version, same tool as in niri binds
    function setDefault(n) {
        if (n) Quickshell.execDetached(["wpctl", "set-default", String(n.id)])
    }

    // Without tracking, node properties and audio are not available
    PwObjectTracker { objects: Pipewire.nodes.values }
}
