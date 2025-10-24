import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import qs

ColumnLayout {
    id: notificationDisplay
    spacing: 2

    property int notiCount: 0
    property bool isLoading: false

    // Expose the signal on the component itself so VertBar can connect to it
    signal settingsRequested()

	Connections {
		target: NotificationManager

		function onHasNotifsChanged() {
			if (!NotificationManager.hasNotifs) {
				root.controlsOpen = false;
			}
		}
	}

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

                onPressed:  {
                    rect.scale = 0.90
                    settingsRequested()
                }
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
            }

            Image {
                id: volumeIcon
                source: notiCount > 0 ? "root:icons/bell-unread.svg" : "root:icons/bell-none.svg"
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
            text: notificationDisplay.notiCount
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
                
                PauseAnimation { duration: 0 }

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
                PauseAnimation { duration: 1000 }

            }
        }
    }

}