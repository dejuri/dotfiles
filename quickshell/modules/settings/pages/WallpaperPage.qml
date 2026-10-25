import QtQuick
import Qt.labs.folderlistmodel
import qs.config
import qs.modules.settings.controls

SettingsPage {
    SettingsSection {
        title: "Wallpaper"

        Text {
            text: "Files are from wallpaper/ directory in quickshell root, you should add wallpaper there"
            color: Theme.lighter
            font.family: Theme.font
            font.pixelSize: 12
        }

        Flow {
            width: parent.width
            spacing: 10

            Repeater {
                model: FolderListModel {
                    folder: Paths.fileUrl(Paths.wallpapers)
                    nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
                    showDirs: false
                    sortField: FolderListModel.Name
                }
                delegate: Rectangle {
                    id: cell
                    required property string fileName
                    readonly property bool selected: Config.appearance.wallpaper === fileName

                    width: 190; height: 130; radius: 12
                    color: Theme.mid
                    border.width: selected ? 3 : 0
                    border.color: Theme.primary

                    Image {
                        anchors { fill: parent; margins: 4 }
                        source: Paths.wallpaper(cell.fileName)
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(380, 260)
                        asynchronous: true
                    }
                    Rectangle {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 4 }
                        height: 22
                        color: "#99000000"
                        Text {
                            anchors { fill: parent; leftMargin: 6; rightMargin: 6 }
                            verticalAlignment: Text.AlignVCenter
                            text: cell.fileName
                            elide: Text.ElideMiddle
                            color: "#ffffff"
                            font.family: Theme.font
                            font.pixelSize: 11
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Config.appearance.wallpaper = cell.fileName
                    }

                    
                }
            }
            
        }
    }
}
