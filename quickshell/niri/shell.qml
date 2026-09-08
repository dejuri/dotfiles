//@ pragma UseQApplication

import QtQuick
import Quickshell
import Niri 0.1
import "./modules/bar/"
import "./modules/wallpaper/"
import "./modules/cava/"
import "./modules/lock/"
import "./modules/volume/"
import "./modules/clock/"
import "./modules/custom/"
import "./modules/dock/"
import "./modules/theme"
import "./services"

ShellRoot {
    id: root
        Niri {
        id: niri
        Component.onCompleted: connect()
        onConnected: console.info("Connected to niri")
        onErrorOccurred: function(error) { console.error("Niri error:", error) }
    }
    LazyLoader { active: true; component: Bar{} }
    LazyLoader { active: true; component: Dock{} }
    LazyLoader { active: true; component: Wallpaper{} }
    LazyLoader { active: true; component: Clock{} }
    LazyLoader { active: true; component: Volume{} }
    LazyLoader { active: true; component: Lock{} }
}
