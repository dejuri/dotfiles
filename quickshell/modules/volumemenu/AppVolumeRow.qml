import QtQuick
import qs.components
import qs.config
import qs.services

// Volume of one app that is playing sound
Column {
    id: root

    required property var node
    readonly property string detail: Audio.streamDetail(node)

    spacing: 4

    Item {
        width: parent.width
        height: appName.implicitHeight

        Text {
            id: appName
            text: Audio.streamName(root.node)
            font.family: Theme.font
            font.pixelSize: 14
            color: Theme.text
            elide: Text.ElideRight
            width: Math.min(implicitWidth, parent.width)
        }
        Text {
            visible: root.detail !== ""
            anchors { left: appName.right; leftMargin: 8; right: parent.right; baseline: appName.baseline }
            text: root.detail
            font.family: Theme.font
            font.pixelSize: 12
            color: Theme.lighter
            elide: Text.ElideRight
        }
    }

    VolumeSlider {
        width: parent.width
        compact: true
        value: root.node?.audio?.volume ?? 0
        muted: root.node?.audio?.muted ?? false
        icon: Audio.volumeIcon(value, muted)
        onMoved: v => Audio.setNodeVolume(root.node, v)
        onIconClicked: Audio.toggleNodeMute(root.node)
    }
}
