pragma Singleton
import QtQuick
import Quickshell
import qs.config

// The source for info what is opened
Singleton {
    property bool launcherOpen: false
    property bool controlCenterOpen: false
    property bool settingsOpen: false
    property bool volumeMenuOpen: false
    property bool dockMenuOpen: false
    property var dockMenuTarget: null
    property int dockMenuAnimX: 0

    function showDockMenu(info) { dockMenuTarget = info; dockMenuOpen = true; xTimer.restart() }
    function hideDockMenu() { dockMenuOpen = false; xTimer.restart() }
    function toggleLauncher() { launcherOpen = !launcherOpen }
    function toggleControlCenter() { controlCenterOpen = !controlCenterOpen; if (controlCenterOpen) volumeMenuOpen = false }
    function toggleVolumeMenu() { volumeMenuOpen = !volumeMenuOpen; if (volumeMenuOpen) controlCenterOpen = false }
    function openVolumeMenu() { volumeMenuOpen = true; controlCenterOpen = false }
    function toggleSettings() { settingsOpen = !settingsOpen }

    Timer {
        id: xTimer
        interval: 200
        onTriggered: dockMenuAnimX = dockMenuOpen ? Theme.animNormal : 0
    }
}
