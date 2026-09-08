import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    function isRealWindow(win) {
        if (!win) return false;

        // 1. Головний фільтр: якщо немає монітора або воркспейса - це тупой привид
        if (!win.monitor || !win.workspace) return false;

        // 2. Фільтруємо вікна з порожнім заголовком (ну тіпа на всякій)
        const title = (win.title || "").trim();
        if (title === "") return false;

        // 3. Додатково прибираємо технічні назви, якщо вони раптом отримають монітор (тож на всякій пажарний)
        const hardBlacklist = ["steamwebhelper", "vrstream", "wine64-preloader", "fl64.exe"];
        if (hardBlacklist.includes(title.toLowerCase())) return false;
        return true;
    }
    id: lowPanel
    WlrLayershell.layer: WlrLayer.Bottom
    anchors { bottom: true; left: true; right: true }
    implicitHeight: 0.04308 * Screen.height
    color: "#2c2c2c"
    
    // Отримання іконочки для докочку!
    function getIcon(win) {
        if (!win) return "";
        
        // Якщо передали рядок (для закріплених програм)
        if (typeof win === "string") {
            return Qt.resolvedUrl("./icons/" + win.toLowerCase() + ".svg");
        }
        let name = win.initialClass || win.klass || win.id || win.appId || "";
        
        if (!name && win.title) {
            name = win.title;
        }

        if (!name) return "";

        let cleanName = name.toLowerCase();

        // Я мапєр
        const mapping = {
            "dolphin": "dolphin",
            "org.telegram.desktop": "telegram",
            "alacritty": "alacritty",
            "root": "alacritty",
            "librewolf": "librewolf",
            "code": "vscode",
            "visual-studio-code": "vscode",
            "vlc": "vlc",
            "sober": "sober",
            "fl studio": "flstudio",
            "legacy launcher": "minetest",
            "minecraft": "minetest",
            "org-springframework-boot-loader": "minetest",
            "discord": "discord",
            "gimp": "gimp",
            "element": "element",
            "vscodium": "vscodium",
            "firefox": "firefox",
            "telegram": "telegram",
            "syrik2000": "alacritty",
            "software": "distributor-logo-nixos",
        };

        // Перевірка через mapping
        for (let key in mapping) {
            if (cleanName.includes(key)) {
                cleanName = mapping[key];
                break;
            }
        }

        // Якщо це складне ім'я типу org.kde.dolphin
        if (cleanName.includes(".")) {
            let parts = cleanName.split(".");
            cleanName = parts[parts.length - 1];
        }

        return Qt.resolvedUrl("./icons/" + cleanName.trim() + ".svg");
    }

    // Процес для запуску
    function launchApp(name) {
        const proc = Qt.createQmlObject(`
            import Quickshell.Io; 
            Process { 
                command: ["${name}"]; 
                onExited: destroy(); 
                onRunningChanged: if (!running) destroy();
            }
        `, lowPanel);
        
        proc.running = true;
    }

    Rectangle {
        id: panelContent
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: row.width + 30 
        height: lowPanel.height
        color: "#3c3c3c"
        radius: 25

        Behavior on width {
            NumberAnimation {
                duration: 200; easing.type: Easing.OutCubic
            }
        }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 12
            Behavior on width {
                NumberAnimation {
                    duration: 300; easing.type: Easing.OutCubic
                }
            }

            // Закріплені іконки:
            Repeater {
                model: ["alacritty", "dolphin", "nix-software-center", "librewolf", "lutris", "steam", "AyuGram"]
                
                delegate: Rectangle {
                    width: 48; height: 48; color: "transparent"
                    Image {
                        id: pinnedIcon
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: getIcon(modelData)
                        fillMode: Image.PreserveAspectFit
                        visible: status === Image.Ready
                        scale: mouseDetector.containsMouse ? 0.8 : 0.7
                        y: mouseDetector.containsMouse ? -15 : -10

                        // Анімка!~
                        Behavior on scale {
                            NumberAnimation {
                                duration: 150; easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on y {
                            NumberAnimation {
                                duration: 150; easing.type: Easing.OutCubic
                            }
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: modelData[0].toUpperCase()
                        color: "white"
                        visible: pinnedIcon.status !== Image.Ready
                    }
                    MouseArea {
                        id: mouseDetector
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: launchApp(modelData)
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            // Сєпар
            Rectangle {
                width: 4; height: 30; color: "#555"; radius: 10
                anchors.verticalCenter: parent.verticalCenter
                visible: runningAppsRepeater.count > 0
            }

            // Запущені іконки:
            Repeater {
                id: runningAppsRepeater
                model: Hyprland.toplevels.values.filter(win => isRealWindow(win))
                onCountChanged: {
                    console.log("--- АНАЛІЗ ВІКОН ---");
                    const allWins = Hyprland.toplevels.values;
                    allWins.forEach((win, i) => {
                        const w = win.size ? win.size.width : (win.width || 0);
                        const h = win.size ? win.size.height : (win.height || 0);
                        const isFiltered = isRealWindow(win);

                        // Це лог, братуха!! (Можна коментувати, якшо треба)
                        allWins.forEach((win, i) => {
                            const isFiltered = isRealWindow(win);
                            console.log(
                                (isFiltered ? "[✅]" : "[❌]") + " #" + i +
                                " | Title: " + (win.title || "EMPTY") +
                                " | Class/AppId: " + (win.class || win.appId || "N/A") +
                                " | Class: " + win.hyprlandId +
                                " | Floating: " + win.floating +
                                " | Monitor: " + (win.monitor ? win.monitor.name : "N/A") +
                                " | Workspace: " + (win.workspace ? win.workspace.id : "N/A") +
                                " | Addr: " + win.address
                            );
                        });
                    });
                }
                delegate: Rectangle {
                    width: 48
                    height: 48
                    color: modelData.focus ? "#555" : "transparent"
                    radius: 8
                
                    Image {
                        id: activeIcon
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: getIcon(modelData)
                        fillMode: Image.PreserveAspectFit
                        
                        // Анімка!~
                        scale: mouseDetector2.containsMouse ? 0.8 : 0.7
                        y: mouseDetector2.containsMouse ? -15 : -10
                        
                        Behavior on scale {
                            NumberAnimation {
                                duration: 150; easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on y {
                            NumberAnimation {
                                duration: 150; easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: (modelData.class || "N").substring(0, 1).toUpperCase()
                        color: "white"
                        visible: activeIcon.status !== Image.Ready
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 10; height: 3; radius: 2
                        color: "#ff2b2b"
                        visible: modelData.focus
                    }

                    MouseArea {
                        id: mouseDetector2
                        hoverEnabled: true
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton) {
                                Hyprland.dispatch(`focuswindow address:0x${modelData.address.toString(16)}`);
                            } else if (mouse.button === Qt.RightButton) {
                                Hyprland.dispatch(`closewindow address:0x${modelData.address.toString(16)}`);
                            }
                        }
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
}
