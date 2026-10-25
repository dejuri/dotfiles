pragma Singleton
import QtQuick
import Quickshell

QtObject {
    readonly property color background: '#1c1f1c'
    readonly property color mid: "#3f4a3f"
    readonly property color midnext: "#606f5f"
    readonly property color primary: '#a9ba52'
    readonly property color lighter: "#6c7a6c"
    readonly property color lightest: "#ebfaeb"
    readonly property color text: lightest
    readonly property string font: "LiberationMono"
    readonly property string clock_font: "MostWaztedRegular"
    readonly property string os_name: "Radian 13"
    readonly property var pinned_apps: ["kitty", "nautilus", "helium-bin", "obs", "lutris", "qbittorrent", "steam", "AyuGram"]

    readonly property string wallpaper: "my-forest.jpg"
}