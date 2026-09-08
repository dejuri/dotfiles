//@ pragma UseQApplication

import QtQuick
import Quickshell
import "./modules/bar/"
import "./modules/frame/"
import "./modules/cava/"
import "./modules/lock/"
import "./modules/volume/"
import "./modules/clock/"
import "./modules/custom/"
import "./modules/dock/"

ShellRoot {
    id: root
    Loader {
        active: true
        sourceComponent: Dock {}
    }
    Loader {
        active: true
        sourceComponent: Bar {}
    }
    Loader {
        active: true
        sourceComponent: Frame {}
    }
    Loader {
        active: true
        sourceComponent: Lock {}
    }
    Loader {
        active: true
        sourceComponent: Volume {}
    }
    Loader {
        active: true
        sourceComponent: Clock {}
    }
}
