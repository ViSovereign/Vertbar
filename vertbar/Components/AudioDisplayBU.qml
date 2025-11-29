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

    PwObjectTracker { objects: [ Pipewire ] }

    // Values from your processes
    property real speakerVolume: 0      // 0-100
    property real micVolume: 0          // 0-100
    property bool speakerMuted: false
    property bool micMuted: false

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
        height: 80
        color: "transparent"
        Layout.alignment: Qt.AlignHCenter
        radius: 5

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 2
            spacing: 2

            // Top text - shows volume on hover or mute status
            Text {
                id: statusText
                Layout.alignment: Qt.AlignHCenter
                text: {
                    if (audioDisplay.hoverValue >= 0) {
                        return audioDisplay.hoverLabel + " " + Math.round(audioDisplay.hoverValue) + "%"
                    } else if (Pipewire.defaultAudioSink.audio.muted && Pipewire.defaultAudioSource.audio.muted) {
                        return "MUTE"
                    } else if (Pipewire.defaultAudioSink.audio.muted) {
                        return "🔇"
                    } else if (Pipewire.defaultAudioSource.audio.muted) {
                        return "🎤🔇"
                    } else {
                        return ""
                    }
                }
                color: (audioDisplay.speakerMuted || audioDisplay.micMuted)
                       ? Matugen.colors.error
                       : Matugen.colors.on_background
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
                    spacing: 4
                    anchors.bottomMargin: 12   // leave room for labels

                    // Helper to get volume color
                    function volumeColor(volume, muted) {
                        if (muted) return Matugen.colors.error
                        if (volume > 80) return Matugen.colors.on_tertiary_container
                        if (volume > 50) return Matugen.colors.on_secondary_container
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
                            width: 8
                            height: parent.height
                            color: Matugen.colors.on_secondary
                            radius: 2
                        }

                        Rectangle {
                            id: speakerFill
                            anchors.horizontalCenter: speakerBG.horizontalCenter
                            anchors.bottom: speakerBG.bottom
                            width: 5
                            height: speakerBG.height * (audioDisplay.speakerVolume / 150.0)
                            color: barsRow.volumeColor(audioDisplay.speakerVolume, audioDisplay.speakerMuted)
                            radius: 2
                            opacity: audioDisplay.speakerMuted ? 0.5 : 1.0

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
                                audioDisplay.hoverValue = Pipewire.defaultAudioSink.audio.volume
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
                            width: 8
                            height: parent.height
                            color: Matugen.colors.on_secondary
                            radius: 2
                        }

                        Rectangle {
                            id: micFill
                            anchors.horizontalCenter: micBG.horizontalCenter
                            anchors.bottom: micBG.bottom
                            width: 5
                            height: micBG.height * (audioDisplay.micVolume / 150.0)
                            color: barsRow.volumeColor(audioDisplay.micVolume, audioDisplay.micMuted)
                            radius: 2
                            opacity: audioDisplay.micMuted ? 0.5 : 1.0

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
                                audioDisplay.hoverValue = audioDisplay.micVolume
                            }
                            onExited: {
                                audioDisplay.hoverValue = -1
                            }
                            onClicked: function(event) {
                                if (event.button === Qt.RightButton) {
                                    toggleMicMute.running = true
                                }
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
                    spacing: 4
                    layoutDirection: Qt.LeftToRight

                    Repeater {
                        model: ["volume_up", "mic"]
                        delegate: Text {
                            text: modelData
                            font.pixelSize: 12
                            font.family: "Material Symbols Rounded"
                            color: {
                                if (index === 0) {
                                    return audioDisplay.speakerMuted ? Matugen.colors.error : Matugen.colors.on_background
                                } else {
                                    return audioDisplay.micMuted ? Matugen.colors.error : Matugen.colors.on_background
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

    // -------- PROCESSES (Speaker, Mic volumes and mute status) --------

    // Get speaker volume (using pactl or amixer - adjust for your system)
    Process {
        id: speakerVolumeProcess
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+%' | head -1 | tr -d '%'"]
        stdout: StdioCollector {
            onStreamFinished: audioDisplay.speakerVolume = parseFloat(this.text.trim())
        }
    }

    // Get speaker mute status
    Process {
        id: speakerMuteProcess
        command: ["sh", "-c", "pactl get-sink-mute @DEFAULT_SINK@ | grep -q 'yes' && echo '1' || echo '0'"]
        stdout: StdioCollector {
            onStreamFinished: audioDisplay.speakerMuted = (this.text.trim() === "1")
        }
    }

    // Get mic volume
    Process {
        id: micVolumeProcess
        command: ["sh", "-c", "pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\\d+%' | head -1 | tr -d '%'"]
        stdout: StdioCollector {
            onStreamFinished: audioDisplay.micVolume = parseFloat(this.text.trim())
        }
    }

    // Get mic mute status
    Process {
        id: micMuteProcess
        command: ["sh", "-c", "pactl get-source-mute @DEFAULT_SOURCE@ | grep -q 'yes' && echo '1' || echo '0'"]
        stdout: StdioCollector {
            onStreamFinished: audioDisplay.micMuted = (this.text.trim() === "1")
        }
    }

    // Toggle speaker mute (right-click on speaker bar)
    Process {
        id: toggleSpeakerMute
        command: ["sh", "-c", "pactl set-sink-mute @DEFAULT_SINK@ toggle"]
        onExited: {
            speakerMuteProcess.running = true
        }
    }

    // Toggle mic mute (right-click on mic bar)
    Process {
        id: toggleMicMute
        command: ["sh", "-c", "pactl set-source-mute @DEFAULT_SOURCE@ toggle"]
        onExited: {
            micMuteProcess.running = true
        }
    }

    // On Click Action - open audio settings
    Process {
        id: onClick
        command: ["sh", "-c", "pavucontrol"]  // or "gnome-control-center sound" or your preferred audio mixer
    }

    Timer {
        interval: 1000 * 1  // Update every second
        running: true
        repeat: true
        onTriggered: {
            speakerVolumeProcess.running = true
            speakerMuteProcess.running = true
            micVolumeProcess.running = true
            micMuteProcess.running = true
        }
    }

    Component.onCompleted: {
        speakerVolumeProcess.running = true
        speakerMuteProcess.running = true
        micVolumeProcess.running = true
        micMuteProcess.running = true
    }
}
