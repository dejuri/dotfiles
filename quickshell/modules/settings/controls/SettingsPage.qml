import QtQuick
import qs.config

// Basic page
Flickable {
    id: root
    default property alias content: column.data

    clip: true
    contentHeight: column.height + 48
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: column
        x: 24; y: 24
        width: root.width - 48
        spacing: 24
    }
}
