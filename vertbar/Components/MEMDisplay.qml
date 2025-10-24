import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import qs

ColumnLayout {
    id: memDisplay
    spacing: 2

    property bool isActive: false
    property real memUsage: 0
    property string memTemp: "?"

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

        onEntered: {
            // Hover enter animation
            hoverAnimation.targets = [canvas, letterlabel]
            hoverAnimation.start();
            rotateAnimation.target = letterlabel
            rotateAnimation.start();

        }

        onExited: {
            // Exit animation
            exitAnimation.targets = [canvas, letterlabel]
            exitAnimation.start();
        }

        // Change the cursor
        cursorShape: Qt.PointingHandCursor
    }

    Rectangle {
        id: rect
        width: 40
        height: 55
        //color: Matugen.colors.on_primary
        color: "transparent"
        Layout.alignment: Qt.AlignHCenter
        radius: 5

        // MEM temp text (Not really)
        Text {
            id: "temptext"
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: memDisplay.memTemp + "°"
            color: Matugen.colors.on_background
            font.pixelSize: 12
            font.bold: true
            font.family: "MesloLGM Nerd Font Propo"

            SequentialAnimation {
                running: true
                loops: Animation.Infinite

                PauseAnimation { duration: 100 }

                OpacityAnimator {
                    target: temptext
                    from: 1.0
                    to: 0.7
                    duration: 1000
                }
                OpacityAnimator {
                    target: temptext
                    from: 0.7
                    to: 1.0
                    duration: 1000
                }
                PauseAnimation { duration: 5000 }
            }

        }

        // MEM percentage text
        Text {
            id: "letterlabel"
            anchors.centerIn: canvas
            text: "memory_alt"
            color: memDisplay.memUsage > 80 ? Matugen.colors.error :
                memDisplay.memUsage > 50 ? Matugen.colors.on_tertiary_container : Matugen.colors.on_primary_container
            font.pixelSize: 22
            font.family: "Material Symbols Rounded"
            opacity: 0.75

        }

        // Circular progress indicator
        Canvas {
            id: canvas
            width: parent.width - 0
            height: width
            anchors.top: temptext.bottom
            anchors.topMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter

            property real animatedUsage: 0

            NumberAnimation {
                id: usageAnimation
                target: canvas
                property: "animatedUsage"
                duration: 2000
                easing.type: Easing.InOutQuad
            }

            onPaint: {
                var ctx = getContext("2d")
                var centerX = width / 2
                var centerY = height / 2
                var radius = Math.min(width, height) / 2 - 5
                var startAngle = Math.PI / 2
                var endAngle = startAngle + (animatedUsage / 100) * 2 * Math.PI

                // Clear canvas
                ctx.clearRect(0, 0, width, height)

                // Background circle
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                ctx.strokeStyle = Matugen.colors.on_secondary
                ctx.lineWidth = 3
                ctx.stroke()

                // MEM usage arc
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                ctx.strokeStyle = animatedUsage > 80 ? Matugen.colors.error :
                                animatedUsage > 50 ? Matugen.colors.on_tertiary_container : Matugen.colors.on_primary_container
                ctx.lineWidth = 4
                ctx.lineCap = "round"
                ctx.stroke()

            }

            onAnimatedUsageChanged: {
                requestPaint()
            }

            // Repaint when MEM usage changes
            Connections {
                target: memDisplay
                function onMemUsageChanged() {
                    usageAnimation.to = Math.round(memDisplay.memUsage)
                    usageAnimation.restart()
                }
            }
        }
    }

    // MEM monitoring process
    Process {
        id: memUsage
        command: ["sh", "-c", "free | grep Mem | awk '{usage=($3/$2)*100} END {print usage}'"]

        stdout: StdioCollector {
            onStreamFinished: {
                //console.log(this.text.trim());
                memDisplay.memUsage = this.text.trim();
            }
        }
    }

   // MEM temp process (Ambient)
    Process {
        id: memTemp
        command: ["/home/b/.config/quickshell/scripts/ambtemp.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                memDisplay.memTemp = this.text.trim()
            }
        }
    }

    // On Click Action
    Process {
        id: onClick
        command: ["sh", "-c", "missioncenter"]
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            memUsage.running = true
            memTemp.running = true
        }    }

    Component.onCompleted: {
        memUsage.running = true
        memTemp.running = true
    }
}
