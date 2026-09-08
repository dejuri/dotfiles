import QtQuick 2.15
import Quickshell

Item {
    width: 300
    height: 100

    Row {
        id: barRow
        anchors.fill: parent
        spacing: 2
        property int barCount: 16

        Component.onCompleted: {
            for (var i=0; i<barRow.barCount; i++) {
                barRow.addItem(Rectangle {
                    width: (parent.width - (barRow.barCount-1)*2)/barRow.barCount
                    height: 10
                    color: "lime"
                    radius: 2
                    Behavior on height { NumberAnimation { duration: 50 } }
                })
            }
            Timer {
                interval: 50
                repeat: true
                running: true
                onTriggered: {
                    var file = "/tmp/cava.json"
                    var content = Qt.resolvedUrl(file)
                }
            }
        }
    }
}
