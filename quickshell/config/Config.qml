pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Shell settings, saved in settings.json
Singleton {
    id: root

    property QtObject appearance: QtObject {
        property string wallpaper: "my-forest.jpg"
        property int cornerRadius: 28
        property string font: "LiberationMono"
        property string clockFont: "MostWaztedRegular"
        property QtObject colors: QtObject {
            property string background: "#1c1c1f"
            property string mid: "#3f3f4a"
            property string midnext: "#60606f"
            property string primary: "#d4d2d4"
            property string lighter: "#6c6c7a"
            property string lightest: "#ebebfa"
            property string red: '#e24a4a'
        }
    }

    property QtObject bar: QtObject {
        property int height: 45
        property string clockFormat: "MMMM dd hh:mm:ss"
        property bool desktopClock: true
        property bool darkClock: false
        // Order of the widgets on the right side of the bar (left to right)
        property var rightItems: ["stats", "keyboard", "battery", "volume"]
        property bool batteryPercent: true
    }

    property QtObject dock: QtObject {
        property bool enabled: true
        property int height: 70
        property var pinnedApps: ["kitty", "nautilus", "helium-bin", "obs", "lutris", "qbittorrent", "steam", "AyuGram"]
        property bool cavaEnabled: true
        property int cavaWidth: 3
    }

    property QtObject general: QtObject {
        property string osName: "Radian 13"
        property string terminal: "kitty"
    }

    property QtObject sound: QtObject {
        property bool osdEnabled: true
        property int osdTimeout: 1200
    }

    function snapshot() {
        return {
            appearance: {
                wallpaper: appearance.wallpaper,
                cornerRadius: appearance.cornerRadius,
                font: appearance.font,
                clockFont: appearance.clockFont,
                colors: {
                    background: appearance.colors.background,
                    mid: appearance.colors.mid,
                    midnext: appearance.colors.midnext,
                    primary: appearance.colors.primary,
                    lighter: appearance.colors.lighter,
                    lightest: appearance.colors.lightest,
                    red: appearance.colors.red
                }
            },
            bar: {
                height: bar.height,
                clockFormat: bar.clockFormat,
                desktopClock: bar.desktopClock,
                darkClock: bar.darkClock,
                rightItems: bar.rightItems,
                batteryPercent: bar.batteryPercent
            },
            dock: {
                enabled: dock.enabled,
                height: dock.height,
                pinnedApps: dock.pinnedApps,
                cavaEnabled: dock.cavaEnabled,
                cavaWidth: dock.cavaWidth
            },
            general: {
                osName: general.osName,
                terminal: general.terminal,
            },
            sound: {
                osdEnabled: sound.osdEnabled,
                osdTimeout: sound.osdTimeout
            }
        }
    }

    readonly property string serialized: JSON.stringify(snapshot(), null, 2)
    property string lastSaved: ""

    onSerializedChanged: writeDebounce.restart()


    function applyData(target, data) {
        for (const k in data) {
            if (target[k] === undefined) continue
            const v = data[k]
            if (v !== null && typeof v === "object" && !Array.isArray(v))
                applyData(target[k], v)
            else
                target[k] = v
        }
    }

    // Old settings.json may not know about newer bar widgets
    function addMissingBarItems() {
        const known = ["stats", "keyboard", "battery", "volume"]
        const have = bar.rightItems.filter(k => known.includes(k))
        const missing = known.filter(k => !have.includes(k))
        if (missing.length === 0 && have.length === bar.rightItems.length) return
        const vol = have.indexOf("volume")
        if (missing.includes("battery") && vol !== -1) {
            have.splice(vol, 0, "battery")
            missing.splice(missing.indexOf("battery"), 1)
        }
        bar.rightItems = [...have, ...missing]
    }

    Timer {
        id: writeDebounce
        interval: 200
        onTriggered: {
            if (root.serialized === root.lastSaved) return
            root.lastSaved = root.serialized
            fileView.setText(root.serialized + "\n")
        }
    }

    FileView {
        id: fileView
        path: Quickshell.shellPath("settings.json")
        watchChanges: true

        onFileChanged: reload()

        onLoaded: {
            try {
                root.applyData(root, JSON.parse(fileView.text()))
            } catch (e) {
                console.warn("Config: bad settings.json:", e)
            }
            root.addMissingBarItems()
            root.lastSaved = root.serialized
        }

        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeDebounce.restart()
        }
    }
}