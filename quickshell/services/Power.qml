pragma Singleton
import QtQuick
import Quickshell
import qs.config

// Power button processes
Singleton {
    function poweroff() { Quickshell.execDetached(["poweroff"]) }
    function reboot() { Quickshell.execDetached(["reboot"]) }
    function logout() { Quickshell.execDetached(["niri", "msg", "action", "quit"]) }
    function lock() { Quickshell.execDetached(["sh", "-c", Config.general.lockCommand]) }
}
