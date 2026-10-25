pragma Singleton
import QtQuick
import Quickshell

// The source for info what is opened
Singleton {
    property bool launcherOpen: false
    property bool controlCenterOpen: false
    property bool settingsOpen: false

    function toggleLauncher() { launcherOpen = !launcherOpen }
    function toggleControlCenter() { controlCenterOpen = !controlCenterOpen }
    function toggleSettings() { settingsOpen = !settingsOpen }
}
