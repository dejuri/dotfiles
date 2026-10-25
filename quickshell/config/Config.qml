pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Shell settings, they are saved in settings.json
Singleton {
    id: root

    property alias appearance: adapter.appearance
    property alias bar: adapter.bar
    property alias dock: adapter.dock
    property alias general: adapter.general

    property bool isWriting: false

    // Таймер для запису з невеликою затримкою (debounce)
    Timer {
        id: writeDebounce
        interval: 50
        repeat: false
        onTriggered: {
            root.isWriting = true;
            fileView.writeAdapter();
            // Одразу після запису на диск робимо швидкий reload,
            // щоб вкладені об'єкти (кольори тощо) оновилися в інтерфейсі з першого кліку
            reloadTimer.restart();
        }
    }

    // Таймер завершення запису
    Timer {
        id: reloadTimer
        interval: 50
        repeat: false
        onTriggered: {
            fileView.reload();
            root.isWriting = false;
        }
    }

    FileView {
        id: fileView
        path: Quickshell.shellPath("settings.json")
        blockLoading: true
        watchChanges: true

        onFileChanged: {
            if (root.isWriting) return;
            fileView.reload();
        }

        onAdapterUpdated: {
            writeDebounce.restart();
        }

        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                root.isWriting = true;
                fileView.writeAdapter();
                root.isWriting = false;
            }
        }

        adapter: JsonAdapter {
            id: adapter

            property JsonObject appearance: JsonObject {
                property string wallpaper: "my-forest.jpg"
                property int cornerRadius: 28
                property string font: "LiberationMono"
                property string clockFont: "MostWaztedRegular"
                property JsonObject colors: JsonObject {
                    property string background: "#1c1c1f"
                    property string mid: "#3f3f4a"
                    property string midnext: "#60606f"
                    property string primary: "#d4d2d4"
                    property string lighter: "#6c6c7a"
                    property string lightest: "#ebebfa"
                }
            }

            property JsonObject bar: JsonObject {
                property int height: 45
                property string clockFormat: "MMMM dd hh:mm:ss"
                property bool desktopClock: true
                property bool darkClock: false
            }

            property JsonObject dock: JsonObject {
                property bool enabled: true
                property int height: 70
                property var pinnedApps: ["kitty", "nautilus", "helium-bin", "obs", "lutris", "qbittorrent", "steam", "AyuGram"]
            }

            property JsonObject general: JsonObject {
                property string osName: "Radian 13"
                property string terminal: "kitty"
                property string lockCommand: "hyprlock"
            }
        }
    }
}