import QtQuick
import QtQuick.Layouts
import Quickshell
import QtCore
import qs

ColumnLayout {
    id: root
    spacing: 0

    // One time string to parse them all
    property date now: new Date()

    // Add this to Settings to let it be stored on disk
    Settings {
        id: settings
        property bool use24h: false
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
        width: 38
        height: 75
        color: Matugen.colors.on_primary_container
        Layout.alignment: Qt.AlignHCenter
        radius: 6
        border.color: Matugen.colors.on_secondary
        border.width: 0

        // TIME SECTION
        ColumnLayout {
            id: timecolumn
            spacing: 0
            anchors.horizontalCenter: parent.horizontalCenter

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                hoverEnabled: true
                propagateComposedEvents: true

                onClicked: function(event) {
                    if (event.button === Qt.LeftButton) {
                        settings.use24h = !settings.use24h
                    }
                }

                onPressed:  timecolumn.scale = 0.90
                onReleased: timecolumn.scale = 1.0

                onEntered: {
                    hourText.color = Matugen.colors.on_tertiary
                    timeText.color = Matugen.colors.on_tertiary
                    colonText.color = Matugen.colors.on_tertiary
                    rect.color = Matugen.colors.on_tertiary_container
                    hoverAnimation.target = rect
                    hoverAnimation.start();

                }

                onExited: {
                    hourText.color = Matugen.colors.background
                    timeText.color = Matugen.colors.background
                    colonText.color = Matugen.colors.background
                    rect.color = Matugen.colors.on_primary_container
                    exitAnimation.target = rect
                    exitAnimation.start();
                }

                // Change the cursor
                cursorShape: Qt.PointingHandCursor

            }

            // Hour display
            Text {
                id: hourText
                text: {
                    if (settings.use24h) {
                        return Qt.formatTime(root.now, "HH")
                    } else {
                        const h = root.now.getHours()
                        const h12 = h % 12 || 12
                        return (h12 < 10 ? "0" : "") + h12
                    }
                }
                color: Matugen.colors.background
                font.pixelSize: 28
                font.family: "MesloLGM Nerd Font Propo"
                opacity: 1.0

                Behavior on color {
                    ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }

            }

            // Sideways colons are all the rage
            Text {
                id: colonText
                text: ".."
                color: Matugen.colors.background
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 10
                font.family: "MesloLGM Nerd Font Propo"
                Layout.topMargin: -16
                Layout.bottomMargin: -10
                opacity: 1.0

                SequentialAnimation on opacity {
                    running: true
                    loops: Animation.Infinite
                    OpacityAnimator { from: 1.0; to: 0.0; duration: 1000 }
                    OpacityAnimator { from: 0.0; to: 1.0; duration: 1000 }
                }

                Behavior on color {
                    ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }
            }

            // Minute display (bottom)
            Text {
                id: timeText
                text: Qt.formatTime(root.now, "mm")
                color: Matugen.colors.background
                font.pixelSize: 28
                font.family: "MesloLGM Nerd Font Propo"
                Layout.alignment: Qt.AlignHCenter
                opacity: 1.0

                Behavior on color {
                    ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }
            }
        }
    }

    // Update time every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.now = new Date()
        }
    }

    // Initialize time immediately
    Component.onCompleted: {
        root.now = new Date()
    }
}
