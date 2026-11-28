import QtQuick
import qs.components
import qs.config
import qs.services

// Battery with liquid icon and percent
HoverButton {
    id: root

    baseColor: Theme.midnext
    visible: Battery.present

    Row {
        anchors.centerIn: parent
        spacing: 6 * Theme.barScale

        // Lightning shows only when charging
        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: 10 * Theme.barScale
            horizontalAlignment: Text.AlignHCenter
            text: "󱐋"
            color: root.foreground
            font.family: Theme.font
            font.pixelSize: 15 * Theme.barScale
            opacity: Battery.charging ? bolt.value : 0
            scale: Battery.charging ? 1 : 0.4
            Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
            Behavior on scale { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutBack } }

            QtObject { id: bolt; property real value: 1 }
            SequentialAnimation {
                running: Battery.charging
                loops: Animation.Infinite
                NumberAnimation { target: bolt; property: "value"; to: 0.45; duration: 800; easing.type: Easing.InOutSine }
                NumberAnimation { target: bolt; property: "value"; to: 1; duration: 800; easing.type: Easing.InOutSine }
                onRunningChanged: if (!running) bolt.value = 1
            }
        }

        LiquidBattery {
            anchors.verticalCenter: parent.verticalCenter
            width: 32 * Theme.barScale
            height: 16 * Theme.barScale
            level: Battery.level
            charging: Battery.charging
            low: Battery.low
            lit: root.lit
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: Config.bar.batteryPercent
            text: Battery.percent + "%"
            color: root.foreground
            font.family: Theme.font
            font.pixelSize: 16 * Theme.barScale
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }
    }
}
