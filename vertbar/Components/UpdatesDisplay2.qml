import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import qs

ColumnLayout {
    id: updateDisplay
    spacing: 2

    property int packageCount: 0
    property bool isLoading: false

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
                acceptedButtons: Qt.LeftButton
                anchors.fill: parent
                hoverEnabled: true

                onPressed:  rect.scale = 0.90
                onReleased: rect.scale = 1.0

                onEntered: {
                    hoverAnimation.target = rect
                    updateText.color = Matugen.colors.on_tertiary_container
                    volumeOverlay.color = Matugen.colors.on_tertiary_container
                    hoverAnimation.start();
                }

                onExited: {
                    exitAnimation.target = rect
                    updateText.color = Matugen.colors.on_background
                    volumeOverlay.color = Matugen.colors.on_primary_container
                    exitAnimation.start();
                }

                onClicked: event => {
                    if (event.button === Qt.LeftButton) {
                        event.accepted = true;
                        startUpdateProcess.running = true
                    }
                }

                // Change the cursor
                cursorShape: Qt.PointingHandCursor

            }

            Image {
                id: volumeIcon
                source: packageCount > 75 ? "root:icons/update.svg" : "root:icons/no_update.svg"
                sourceSize: Qt.size(parent.width, parent.height)
                smooth: true
                visible: false
            }

            ColorOverlay {
                id:volumeOverlay
                anchors.fill: volumeIcon
                source: volumeIcon
                color: Matugen.colors.on_primary_container

                Behavior on color {
                    ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }
            }
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            id: updateText
            text: updateDisplay.packageCount
            color: Matugen.colors.on_background
            font.pixelSize: 12
            font.bold: true
            font.family: "MesloLGM Nerd Font Propo"
            opacity: 1.0

            Behavior on color {
                ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }

            SequentialAnimation {
                running: true
                loops: Animation.Infinite

                PauseAnimation { duration: 100 }

                OpacityAnimator {
                    target: updateText
                    from: 1.0
                    to: 0.7
                    duration: 1000
                }
                OpacityAnimator {
                    target: updateText
                    from: 0.7
                    to: 1.0
                    duration: 1000
                }
                PauseAnimation { duration: 5000 }

            }
        }
    }

	Process {
		id: updateProcess
		command: ["/home/b/.config/quickshell/scripts/updates.sh"]
		stdout: StdioCollector {
			onStreamFinished: updateDisplay.packageCount = this.text, updateDisplay.isLoading = false
		}
	}

	Process {
		id: startUpdateProcess
		command: ["alacritty", "-e", "/home/b/.config/quickshell/scripts/installupdates.sh"]
	}

    Timer {
        // Setting the millisecond X 60 to seconds X 60 to minutes
        interval: 1000 * 60 * 60
        running: true
        repeat: true
        onTriggered: updateProcess.running = true
    }

    Component.onCompleted: updateProcess.running = true

}
