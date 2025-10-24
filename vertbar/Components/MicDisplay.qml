import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects
import qs

ColumnLayout {
    id: volumeDisplay
    required property int barWidth
    spacing: 2

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSource ]
    }

    PropertyAnimation {
        id: hoverAnimation
        property: "scale"
        to: 1.1
        duration: 250
        easing.type: Easing.InOutQuad
    }

    // Exit: scale back
    PropertyAnimation {
        id: exitAnimation
        property: "scale"
        to: 1.0
        duration: 450
        easing.type: Easing.InOutQuad
    }

    Rectangle {
        id: rect
        width: 40
        height: 50
        //color: Matugen.colors.on_primary
        color: "transparent"
        Layout.alignment: Qt.AlignHCenter
        radius: 5

        Item {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: 30
            height: 30

            MouseArea {
                id: mouseArea
                acceptedButtons: Qt.RightButton | Qt.NoButton
                anchors.fill: parent
                hoverEnabled: true
                
                onPressed:  rect.scale = 0.90
                onReleased: rect.scale = 1.0

                onEntered: {
                    hoverAnimation.target = rect
                    audioText.color = Matugen.colors.on_tertiary_container
                    volumeOverlay.color = Matugen.colors.on_tertiary_container
                    hoverAnimation.start();
                }

                onExited: {
                    exitAnimation.target = rect
                    audioText.color = Matugen.colors.on_background
                    volumeOverlay.color = Matugen.colors.on_primary_container
                    exitAnimation.start();
                }

                onWheel: event => {
                    var minVolume = 0
                    var maxVolume = 1.5
                    var delta = (event.angleDelta.y / 120) * 0.05
                    Pipewire.defaultAudioSource.audio.volume = Math.max(minVolume, Math.min(maxVolume, Pipewire.defaultAudioSource.audio.volume + delta))
                    event.accepted = true
                }
                    onClicked: event => {
                    if (event.button === Qt.RightButton) {
                        event.accepted = true;
                        Pipewire.defaultAudioSource.audio.muted = !Pipewire.defaultAudioSource.audio.muted;
                    }
                }
                
                // Change the cursor
                cursorShape: Qt.PointingHandCursor

            }

            Image {
                id: volumeIcon
                source: `root:icons/${Pipewire.defaultAudioSource.audio.muted ? "mic-muted.svg" : "mic.svg"}`
                sourceSize: Qt.size(parent.width, parent.height)
                smooth: true
                visible: false
            }

            ColorOverlay {
                id:volumeOverlay
                anchors.fill: volumeIcon
                source: volumeIcon
                color: Matugen.colors.on_primary_container
            }
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            id: audioText
            text: Math.round(Pipewire.defaultAudioSource.audio.volume * 100) + "%"
            color: Matugen.colors.on_background
            font.pixelSize: 12
            font.bold: true
            font.family: "MesloLGM Nerd Font Propo"
            opacity: 1.0

            SequentialAnimation {
                running: true
                loops: Animation.Infinite
                
                PauseAnimation { duration: 200 }

                OpacityAnimator {
                    target: audioText
                    from: 1.0
                    to: 0.7
                    duration: 1000
                }
                OpacityAnimator {
                    target: audioText
                    from: 0.7
                    to: 1.0
                    duration: 1000
                }
                PauseAnimation { duration: 5000 }
            }            
        }
    }
}