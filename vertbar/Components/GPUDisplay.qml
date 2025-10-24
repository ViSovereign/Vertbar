import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import qs

ColumnLayout {
    id: gpuDisplay
    spacing: 2

    property bool isActive: false
    property real gpuUsage: 0
    property string gpuTemp: "?"

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
            hoverAnimation.targets = [canvas, letterlabel]
            hoverAnimation.start();
            rotateAnimation.target = letterlabel
            rotateAnimation.start();

        }

        onExited: {
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

        // GPU temp text
        Text {
            id: "temptext"
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: gpuDisplay.gpuTemp + ".0°"
            color: Matugen.colors.on_background
            font.pixelSize: 12
            font.bold: true
            font.family: "MesloLGM Nerd Font Propo"

            SequentialAnimation {
                running: true
                loops: Animation.Infinite

                PauseAnimation { duration: 200 }

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

        // GPU percentage text
        Text {
            id: "letterlabel"
            anchors.centerIn: canvas
            text: "sports_esports"
            color: gpuDisplay.gpuUsage > 80 ? Matugen.colors.error :
                gpuDisplay.gpuUsage > 50 ? Matugen.colors.on_tertiary_container : Matugen.colors.on_primary_container
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
                duration: 3000
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

                // GPU usage arc
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

            // Repaint when GPU usage changes
            Connections {
                target: gpuDisplay
                function onGpuUsageChanged() {
                    usageAnimation.to = Math.round(gpuDisplay.gpuUsage)
                    usageAnimation.restart()
                }
            }
        }
    }

    Process {
        id: gpuProcess
        command: ["/home/b/.config/quickshell/scripts/nvidia.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                //console.log(this.text.trim());
                var lines = this.text.trim().split('\n');
                gpuDisplay.gpuUsage = lines[0] || "";
                gpuDisplay.gpuTemp = lines[1] || "";
            }
        }
    }

    // On Click Action
    Process {
        id: onClick
        command: ["sh", "-c", "nvidia-smi"]
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            gpuProcess.running = true
        }
    }

    Component.onCompleted: {
        gpuProcess.running = true
    }
}
