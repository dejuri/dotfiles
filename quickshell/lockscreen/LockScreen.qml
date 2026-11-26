import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import qs.config

Scope {
    id: root

    property int outDuration: 450
    property int outStagger: 120
    readonly property int outroTotal: outStagger * 2 + outDuration

    property bool closing: false

    Connections {
        target: LockScreenState
        function onLockedChanged() {
            if (LockScreenState.locked) {
                releaseTimer.stop()
                root.closing = false
                lock.locked = true
            } else if (lock.locked) {
                root.closing = true
                releaseTimer.restart()
            }
        }
    }

    Timer {
        id: releaseTimer
        interval: root.outroTotal + 80
        onTriggered: {
            lock.locked = false
            root.closing = false
        }
    }

    Component.onCompleted: lock.locked = LockScreenState.locked

    WlSessionLock {
        id: lock

        locked: false
        onLockedChanged: {
            if (LockScreenState.locked !== locked) {
                LockScreenState.locked = locked
            }
        }

        WlSessionLockSurface {
            id: surface

            Rectangle {
                id: mainContainer
                anchors.fill: parent
                color: "#000000"

                Image {
                    id: wallpaper
                    anchors.fill: parent
                    source: Paths.wallpaper(Config.appearance.wallpaper)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    sourceSize: Qt.size(parent.width, parent.height)
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#000000"
                    opacity: 0.45
                }

                Item {
                    id: card
                    width: 320
                    height: contentColumn.height
                    anchors.centerIn: parent

                    property real baseX: (parent.width - width) / 2
                    property real animOffsetX: 0

                    property real dropDistance: 140
                    property real riseDistance: 140

                    transform: Translate { x: card.animOffsetX }

                    SequentialAnimation {
                        id: shakeAnim
                        loops: 1
                        NumberAnimation { target: card; property: "animOffsetX"; to: -12; duration: 50; easing.type: Easing.OutQuad }
                        NumberAnimation { target: card; property: "animOffsetX"; to: 12; duration: 50; easing.type: Easing.OutQuad }
                        NumberAnimation { target: card; property: "animOffsetX"; to: -8; duration: 50; easing.type: Easing.OutQuad }
                        NumberAnimation { target: card; property: "animOffsetX"; to: 8; duration: 50; easing.type: Easing.OutQuad }
                        NumberAnimation { target: card; property: "animOffsetX"; to: 0; duration: 50; easing.type: Easing.OutQuad }
                    }

                    ParallelAnimation {
                        id: introAnim

                        ParallelAnimation {
                            NumberAnimation {
                                target: clockShift; property: "y"; to: 0
                                duration: 700
                                easing.type: Easing.OutBack; easing.overshoot: 0.9
                            }
                            NumberAnimation {
                                target: clockGroup; property: "opacity"; to: 1
                                duration: 450; easing.type: Easing.OutCubic
                            }
                        }

                        SequentialAnimation {
                            PauseAnimation { duration: 120 }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: avatarShift; property: "y"; to: 0
                                    duration: 700
                                    easing.type: Easing.OutBack; easing.overshoot: 0.9
                                }
                                NumberAnimation {
                                    target: avatar; property: "opacity"; to: 1
                                    duration: 450; easing.type: Easing.OutCubic
                                }
                            }
                        }

                        SequentialAnimation {
                            PauseAnimation { duration: 250 }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: fieldShift; property: "y"; to: 0
                                    duration: 650; easing.type: Easing.OutCubic
                                }
                                NumberAnimation {
                                    target: fieldWrap; property: "opacity"; to: 1
                                    duration: 450; easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    ParallelAnimation {
                        id: outroAnim

                        ParallelAnimation {
                            NumberAnimation {
                                target: fieldShift; property: "y"; to: card.riseDistance
                                duration: root.outDuration; easing.type: Easing.InCubic
                            }
                            NumberAnimation {
                                target: fieldWrap; property: "opacity"; to: 0
                                duration: root.outDuration; easing.type: Easing.InCubic
                            }
                        }

                        SequentialAnimation {
                            PauseAnimation { duration: root.outStagger }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: avatarShift; property: "y"; to: -card.dropDistance
                                    duration: root.outDuration
                                    easing.type: Easing.InBack; easing.overshoot: 0.9
                                }
                                NumberAnimation {
                                    target: avatar; property: "opacity"; to: 0
                                    duration: root.outDuration; easing.type: Easing.InCubic
                                }
                            }
                        }

                        SequentialAnimation {
                            PauseAnimation { duration: root.outStagger * 2 }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: clockShift; property: "y"; to: -card.dropDistance
                                    duration: root.outDuration
                                    easing.type: Easing.InBack; easing.overshoot: 0.9
                                }
                                NumberAnimation {
                                    target: clockGroup; property: "opacity"; to: 0
                                    duration: root.outDuration; easing.type: Easing.InCubic
                                }
                            }
                        }
                    }

                    function playIntro() {
                        outroAnim.stop()
                        introAnim.stop()
                        clockShift.y = -dropDistance
                        avatarShift.y = -dropDistance
                        fieldShift.y = riseDistance
                        clockGroup.opacity = 0
                        avatar.opacity = 0
                        fieldWrap.opacity = 0
                        introAnim.start()
                    }

                    function playOutro() {
                        introAnim.stop()
                        outroAnim.restart()
                    }

                    Column {
                        id: contentColumn
                        width: parent.width
                        spacing: 4

                        Column {
                            id: clockGroup
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 4
                            opacity: 0
                            transform: Translate { id: clockShift; y: -card.dropDistance }

                            Text {
                                id: clockText
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Qt.formatTime(currentTime, "hh:mm")
                                font.pixelSize: 80
                                font.weight: Font.Thin
                                color: "#FFFFFF"

                                property date currentTime: new Date()

                                Timer {
                                    interval: 1000
                                    running: true
                                    repeat: true
                                    onTriggered: clockText.currentTime = new Date()
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Qt.formatDate(clockText.currentTime, "dddd, MMMM d")
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: Qt.rgba(1, 1, 1, 0.75)
                            }
                        }

                        Item { height: 16; width: 1 }

                        Item {
                            id: avatar
                            width: 96
                            height: 96
                            anchors.horizontalCenter: parent.horizontalCenter
                            opacity: 0
                            transform: Translate { id: avatarShift; y: -card.dropDistance }

                            Image {
                                id: avatarImg
                                anchors.fill: parent
                                source: "file://" + Quickshell.env("HOME") + "/.face"
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: 192
                                sourceSize.height: 192
                                smooth: true
                                asynchronous: true
                                visible: false
                            }

                            Rectangle {
                                id: avatarMask
                                anchors.fill: parent
                                radius: width / 2
                                color: "black"
                                layer.enabled: true
                                visible: false
                            }

                            MultiEffect {
                                anchors.fill: parent
                                source: avatarImg
                                maskEnabled: true
                                maskSource: avatarMask
                                maskThresholdMin: 0.5
                                maskSpreadAtMin: 1.0
                                visible: avatarImg.status === Image.Ready
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: Qt.rgba(0, 0, 0, 0.5)
                                visible: avatarImg.status !== Image.Ready

                                Text {
                                    anchors.centerIn: parent
                                    text: (Quickshell.env("USER") || "?").charAt(0).toUpperCase()
                                    font.pixelSize: 40
                                    font.weight: Font.Medium
                                    color: "#FFFFFF"
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: "transparent"
                                border.width: 2
                                border.color: Qt.rgba(1, 1, 1, 0.25)
                            }
                        }

                        Item { height: 12; width: 1 }

                        // Password field
                        Rectangle {
                            id: fieldWrap
                            width: parent.width
                            height: 50
                            radius: 14
                            color: Qt.rgba(0, 0, 0, 0.5)
                            opacity: 0
                            transform: Translate { id: fieldShift; y: card.riseDistance }

                            border.width: pwField.activeFocus ? 2 : (LockScreenState.authFailed ? 2 : 1)
                            border.color: LockScreenState.authFailed
                                ? Colors.colRed
                                : (pwField.activeFocus ? Colors.colFg : Qt.rgba(1, 1, 1, 0.15))

                            Behavior on border.color { ColorAnimation { duration: 200 } }
                            Behavior on border.width { NumberAnimation { duration: 150 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 10

                                TextField {
                                    id: pwField
                                    Layout.fillWidth: true
                                    echoMode: TextInput.Password
                                    enabled: !LockScreenState.authenticating && !root.closing
                                    placeholderText: LockScreenState.authenticating ? "Verifying..." : "Enter Password"
                                    placeholderTextColor: Qt.rgba(1, 1, 1, 0.4)
                                    color: "#FFFFFF"
                                    background: null
                                    font.pixelSize: 15
                                    verticalAlignment: TextInput.AlignVCenter

                                    onAccepted: {
                                        if (text.length > 0)
                                            LockScreenState.authenticate(text)
                                    }
                                }

                                BusyIndicator {
                                    visible: LockScreenState.authenticating
                                    running: LockScreenState.authenticating
                                    implicitWidth: 18
                                    implicitHeight: 18
                                }
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Incorrect password"
                            color: Theme.red
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            opacity: LockScreenState.authFailed ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation { duration: 200; easing.type: Easing.InOutSine }
                            }
                        }
                    }
                }

                Connections {
                    target: LockScreenState
                    function onAuthFailedChanged() {
                        if (LockScreenState.authFailed) {
                            shakeAnim.start()
                            pwField.text = ""
                            pwField.forceActiveFocus()
                        }
                    }
                    function onLockedChanged() {
                        if (LockScreenState.locked) {
                            pwField.forceActiveFocus()
                            card.playIntro()
                        }
                    }
                }

                Connections {
                    target: root
                    function onClosingChanged() {
                        if (root.closing) {
                            pwField.text = ""
                            card.playOutro()
                        }
                    }
                }

                Component.onCompleted: {
                    pwField.forceActiveFocus()
                    card.playIntro()
                }
            }
        }
    }
}