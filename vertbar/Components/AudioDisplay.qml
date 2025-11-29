import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import qs

ColumnLayout {
    id: audioDisplay
    spacing: 0

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSource ]
    }

    // For hover label
    property string hoverLabel: ""
    property real hoverValue: -1

    // --- Animations ---
    PropertyAnimation {
        id: hoverAnimation
        property: "scale"
        to: 1.1
        duration: 250
        easing.type: Easing.InOutQuad
    }

    PropertyAnimation {
        id: exitAnimation
        property: "scale"
        to: 1.0
        duration: 450
        easing.type: Easing.InOutQuad
    }

    PropertyAnimation {
        id: rotateAnimation
        property: "rotation"
        from: 0
        to: 359
        duration: 1000
        easing.type: Easing.InOutQuad
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        propagateComposedEvents: true

        onClicked: function(event) {
            if (event.button === Qt.LeftButton) {
                onClick.running = true
            }
        }

        onPressed:  rect.scale = 0.90
        onReleased: rect.scale = 1.0

        cursorShape: Qt.PointingHandCursor
    }

    Rectangle {
        id: rect
        width: 40
        height: 120
        color: "transparent"
        Layout.alignment: Qt.AlignHCenter
        radius: 5

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 2
            spacing: 0

            // Top text - shows volume on hover or mute status
            Text {
                id: statusText
                Layout.alignment: Qt.AlignHCenter
                text: {
                    if (audioDisplay.hoverValue >= 0) {
                        return audioDisplay.hoverLabel + " " + Math.round(audioDisplay.hoverValue) + "%"
                    } else {
                        return ""
                    }
                }
                color: Matugen.colors.on_background
                font.pixelSize: 10
                font.bold: true
                font.family: "MesloLGM Nerd Font Propo"

                SequentialAnimation {
                    running: true
                    loops: Animation.Infinite

                    PauseAnimation { duration: 300 }

                    OpacityAnimator {
                        target: statusText
                        from: 1.0
                        to: 0.7
                        duration: 1000
                    }
                    OpacityAnimator {
                        target: statusText
                        from: 0.7
                        to: 1.0
                        duration: 1000
                    }
                }
            }

            // Bars region
            Item {
                id: barsArea
                Layout.fillWidth: true
                Layout.fillHeight: true

                Row {
                    id: barsRow
                    anchors.fill: parent
                    anchors.margins: 2
                    spacing: 2
                    anchors.bottomMargin: 12   // leave room for labels

                    // Helper to get volume color
                    function volumeColor(volume, muted) {
                        if (muted) return Matugen.colors.error
                        if (volume > 80) return Matugen.colors.on_secondary_container
                        if (volume > 50) return Matugen.colors.on_tertiary_container
                        return Matugen.colors.on_primary_container
                    }

                    // ==== SPEAKER BAR ====
                    Item {
                        id: speakerBarItem
                        anchors.bottom: parent.bottom
                        width: (parent.width - spacing) / 2
                        height: parent.height

                        Rectangle {
                            id: speakerBG
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            width: 10
                            height: parent.height
                            color: Matugen.colors.on_secondary
                            radius: 2
                        }

                        Rectangle {
                            id: speakerFill
                            anchors.horizontalCenter: speakerBG.horizontalCenter
                            anchors.bottom: speakerBG.bottom
                            width: 8
                            height: speakerBG.height * (Math.round(Pipewire.defaultAudioSink.audio.volume * 100) / 150.0)
                            color: barsRow.volumeColor(Math.round(Pipewire.defaultAudioSink.audio.volume * 100), Pipewire.defaultAudioSink.audio.muted)
                            radius: 2
                            opacity: Pipewire.defaultAudioSink.audio.muted ? 0.5 : 1.0

                            Behavior on height {
                                NumberAnimation {
                                    duration: 400
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }

                        // Hover for Speaker
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onEntered: {
                                audioDisplay.hoverLabel = ""
                                audioDisplay.hoverValue = Math.round(Pipewire.defaultAudioSink.audio.volume * 100)
                            }
                            onExited: {
                                audioDisplay.hoverValue = -1
                            }
                            onClicked: function(event) {
                                if (event.button === Qt.RightButton) {
                                    Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
                                }
                            }
                            onWheel: function(event) {
                                const minVolume = 0
                                const maxVolume = 1.5
                                const delta = (event.angleDelta.y / 120) * 0.05
                                Pipewire.defaultAudioSink.audio.volume =
                                    Math.max(minVolume, Math.min(maxVolume, Pipewire.defaultAudioSink.audio.volume + delta))
                                audioDisplay.hoverValue = Math.round(Pipewire.defaultAudioSink.audio.volume * 100)
                                event.accepted = true
                            }
                        }
                    }

                    // ==== MIC BAR ====
                    Item {
                        id: micBarItem
                        anchors.bottom: parent.bottom
                        width: (parent.width - spacing) / 2
                        height: parent.height

                        Rectangle {
                            id: micBG
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            width: 10
                            height: parent.height
                            color: Matugen.colors.on_secondary
                            radius: 2
                        }

                        Rectangle {
                            id: micFill
                            anchors.horizontalCenter: micBG.horizontalCenter
                            anchors.bottom: micBG.bottom
                            width: 8
                            height: micBG.height * (Math.round(Pipewire.defaultAudioSource.audio.volume * 100) / 150.0)
                            color: barsRow.volumeColor(Math.round(Pipewire.defaultAudioSource.audio.volume * 100), Pipewire.defaultAudioSource.audio.muted)
                            radius: 2
                            opacity: Pipewire.defaultAudioSource.audio.muted ? 0.5 : 1.0

                            Behavior on height {
                                NumberAnimation {
                                    duration: 400
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }

                        // Hover for Mic
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onEntered: {
                                audioDisplay.hoverLabel = ""
                                audioDisplay.hoverValue = Math.round(Pipewire.defaultAudioSource.audio.volume * 100)
                            }
                            onExited: {
                                audioDisplay.hoverValue = -1
                            }
                            onClicked: function(event) {
                                if (event.button === Qt.RightButton) {
                                    Pipewire.defaultAudioSource.audio.muted = !Pipewire.defaultAudioSource.audio.muted;
                                }
                            }
                            onWheel: function(event) {
                                const minVolume = 0
                                const maxVolume = 1.5
                                const delta = (event.angleDelta.y / 120) * 0.05
                                Pipewire.defaultAudioSource.audio.volume =
                                    Math.max(minVolume, Math.min(maxVolume, Pipewire.defaultAudioSource.audio.volume + delta))
                                audioDisplay.hoverValue = Math.round(Pipewire.defaultAudioSource.audio.volume * 100)
                                event.accepted = true
                            }
                        }
                    }
                }

                // Bottom labels (speaker and mic icons)
                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 10
                    spacing: 1
                    layoutDirection: Qt.LeftToRight

                    Repeater {
                        model: ["volume_up", "mic"]
                        delegate: Text {
                            text: {
                                if (index === 0) {
                                    return Pipewire.defaultAudioSink.audio.muted ? "volume_off" : modelData
                                } else {
                                    return Pipewire.defaultAudioSource.audio.muted ? "mic_off": modelData
                                }
                            }
                            font.pixelSize: 16
                            font.family: "Material Symbols Rounded"
                            color: {
                                if (index === 0) {
                                    return Pipewire.defaultAudioSink.audio.muted ? Matugen.colors.error : Matugen.colors.on_background
                                } else {
                                    return Pipewire.defaultAudioSource.audio.muted ? Matugen.colors.error : Matugen.colors.on_background
                                }
                            }
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            width: (parent.width - spacing) / 2
                        }
                    }
                }
            }
        }
    }
}
