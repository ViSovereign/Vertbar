import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import qs

ColumnLayout {
    id: cpumemDisplay
    spacing: 0

    property real cpuUsage: 0
    property real memUsage: 0
    property string cpuTemp: "?"

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
            hoverAnimation.targets = [canvas1 , canvas2]
            hoverAnimation.start();
            rotateAnimation.target = letterlabel
            rotateAnimation.start();
        }

        onExited: {
            exitAnimation.targets = [canvas1 , canvas2]
            exitAnimation.start();
        }

        // Change the cursor
        cursorShape: Qt.PointingHandCursor

    }

    Rectangle {
        id: rect
        width: 40
        height: 50
        //color: Matugen.colors.on_primary
        color: "transparent"
        Layout.alignment: Qt.AlignHCenter
        radius: 5

        // Temp Text
        Text {
            id: "temptext"
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: cpumemDisplay.cpuTemp + "°"
            color: Matugen.colors.on_background
            font.pixelSize: 12
            font.bold: true
            font.family: "MesloLGM Nerd Font Propo"

            SequentialAnimation {
                running: true
                loops: Animation.Infinite

                PauseAnimation { duration: 300 }

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
            }
        }

        // MEM percentage text
        Text {
            id: "letterlabel"
            anchors.centerIn: canvas2
            text: "memory"
            color: cpumemDisplay.memUsage > 80 ? Matugen.colors.error :
                cpumemDisplay.memUsage > 50 ? Matugen.colors.on_tertiary_container : Matugen.colors.on_primary_container
            font.pixelSize: 18
            font.family: "Material Symbols Rounded"
            opacity: 0.75

        }

        // Circular progress indicator
        Canvas {
            id: canvas1
            width: parent.width - 0
            height: width
            anchors.top: temptext.bottom
            anchors.topMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter

            property real animatedUsage: 0

            NumberAnimation {
                id: usageAnimation1
                target: canvas
                property: "animatedUsage"
                duration: 3000
                easing.type: Easing.InOutQuad
            }

            onPaint: {
                var ctx = getContext("2d")
                var centerX = width / 2
                var centerY = height / 2
                var radius = Math.min(width, height) / 2 - 5
                var startAngle = Math.PI / 2
                var endAngle = startAngle + (Math.round(cpumemDisplay.cpuUsage) / 100) * 2 * Math.PI

                // Clear canvas
                ctx.clearRect(0, 0, width, height)

                // Background circle
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                ctx.strokeStyle = Matugen.colors.on_secondary
                ctx.lineWidth = 3
                ctx.stroke()

                // Usage Arc
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                ctx.strokeStyle = cpumemDisplay.cpuUsage > 80 ? Matugen.colors.error :
                                cpumemDisplay.cpuUsage > 50 ? Matugen.colors.on_tertiary_container : Matugen.colors.on_secondary_container
                ctx.lineWidth = 4
                ctx.lineCap = "round"
                ctx.stroke()

            }

            // Repaint when CPU usage changes
            Connections {
                target: cpumemDisplay
                function oncpuUsageChanged() {
                    canvas1.requestPaint()
                }
            }
        }

        // Circular progress indicator
        Canvas {
            id: canvas2
            width: parent.width - 9
            height: width
            anchors.centerIn: canvas1

            property real animatedUsage: 0

            NumberAnimation {
                id: usageAnimation2
                target: canvas
                property: "animatedUsage"
                duration: 3000
                easing.type: Easing.InOutQuad
            }

            onPaint: {
                var ctx = getContext("2d")
                var centerX = width / 2
                var centerY = height / 2
                var radius = Math.min(width, height) / 2 - 5
                var startAngle = Math.PI / 2
                var endAngle = startAngle + (Math.round(cpumemDisplay.memUsage) / 100) * 2 * Math.PI

                // Clear canvas
                ctx.clearRect(0, 0, width, height)

                // Background circle
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                ctx.strokeStyle = Matugen.colors.on_secondary
                ctx.lineWidth = 3
                ctx.stroke()

                // Usage Arc
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                ctx.strokeStyle = cpumemDisplay.memUsage > 80 ? Matugen.colors.error :
                                cpumemDisplay.memUsage > 50 ? Matugen.colors.on_tertiary_container : Matugen.colors.on_secondary_container
                ctx.lineWidth = 4
                ctx.lineCap = "round"
                ctx.stroke()

            }

            // Repaint when CPU usage changes
            Connections {
                target: cpumemDisplay
                function onmemUsageChanged() {
                    canvas2.requestPaint()
                }
            }
        }
    }

    // CPU monitoring process
    Process {
        id: cpuProcess
        //command: ["sh", "-c", "grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$3+$4+$5)} END {print usage}'"]
        command: ["sh", "-c", "awk '/^cpu / {usage=($2+$4+$6)*100/($2+$3+$4+$5+$6+$7+$8+$9+$10)} END {print usage}' /proc/stat"]

        stdout: StdioCollector {
            onStreamFinished: {
                //console.log(this.text.trim());
                cpumemDisplay.cpuUsage = this.text.trim();
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
                cpumemDisplay.memUsage = this.text.trim();
            }
        }
    }

    // CPU temp process
    Process {
        id: cpuTemp
        command: ["/home/b/.config/quickshell/scripts/cputemp.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                cpumemDisplay.cpuTemp = this.text.trim()
            }
        }
    }

    // On Click Action
    Process {
        id: onClick
        command: ["sh", "-c", "missioncenter"]
    }

    Timer {
        interval: 1000 * 60
        running: true
        repeat: true
        onTriggered: {
            cpuProcess.running = true
            memUsage.running = true
            cpuTemp.running = true
        }
    }

    Component.onCompleted: {
        cpuProcess.running = true
        memUsage.running = true
        cpuTemp.running = true
    }
}
