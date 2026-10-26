pragma Singleton
import QtQuick
import Quickshell

// Just config help
Singleton {

    // Colors
    readonly property color background: Config.appearance.colors.background
    readonly property color mid: Config.appearance.colors.mid
    readonly property color midnext: Config.appearance.colors.midnext
    readonly property color primary: Config.appearance.colors.primary
    readonly property color lighter: Config.appearance.colors.lighter
    readonly property color lightest: Config.appearance.colors.lightest
    readonly property color text: lightest

    readonly property string font: Config.appearance.font
    readonly property string clockFont: Config.appearance.clockFont

    // Animations speed
    readonly property int animFast: 100
    readonly property int animNormal: 200
    readonly property int animSlow: 300

    //
    readonly property real dockCell: Config.dock.height * 0.68
}
