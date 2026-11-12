pragma Singleton
import QtQuick
import Quickshell

// The source for info what is opened
Singleton {
    property bool launcherOpen: false
    property bool controlCenterOpen: false
    property bool settingsOpen: false
    property bool dockMenuOpen: false
    property var dockMenuTarget: null

    function showDockMenu(info) { dockMenuTarget = info; dockMenuOpen = true }
    function hideDockMenu() { dockMenuOpen = false }
    function toggleLauncher() { launcherOpen = !launcherOpen }
    function toggleControlCenter() { controlCenterOpen = !controlCenterOpen }
    function toggleSettings() { settingsOpen = !settingsOpen }
}
