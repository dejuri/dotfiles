pragma Singleton
import QtQuick
import Quickshell

QtObject {

    // Colors
    readonly property color background: '#1c1c1f'
    readonly property color mid: "#3f3f4a"
    readonly property color midnext: "#60606f"
    readonly property color primary: '#96c2d4'
    readonly property color lighter: "#6c6c7a"
    readonly property color lightest: "#ebebfa"
    readonly property color text: lightest

    // Fonts
    readonly property string font: "LiberationMono"
    readonly property string clock_font: "MostWaztedRegular"

    // Distro Name
    readonly property string os_name: "Radian 13"

    // Pinned Apps
    readonly property var pinned_apps: ["kitty", "nautilus", "helium-bin", "obs", "lutris", "qbittorrent", "steam", "AyuGram"]

    // Wallpaper File
    readonly property string wallpaper: "my-forest.jpg"
}