import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import qs

ColumnLayout {
    id: diskDisplay
    spacing: 0
    property bool isActive: false
    property real diskUsed: 50
    property string diskTemp: "?"
    property string diskShown: "/"

    // Expose the signal on the component itself so VertBar can connect to it
    signal directoryRequested()

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
                diskDisplay.directoryRequested()         
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
            exitAnimation.target = canvas
            exitAnimation.start();
        }
        
        // Change the cursor
        cursorShape: Qt.PointingHandCursor
    }

    Rectangle {
        id: rect
        width: 40
        height: 55
        color: "transparent"
        Layout.alignment: Qt.AlignHCenter
        radius: 5

        // Temp Text
        Text {
            id: "temptext"
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: diskDisplay.diskTemp + "°"
            //text: diskDisplay.diskShown
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
                PauseAnimation { duration: 5000 }
            }
        }

        Text {
            id: "letterlabel"
            anchors.centerIn: canvas
            text: diskDisplay.diskShown === "/" ? "home" : "hard_drive"
            color: diskDisplay.diskUsed > 80 ? Matugen.colors.error : 
                diskDisplay.diskUsed > 50 ? Matugen.colors.on_tertiary_container : Matugen.colors.on_primary_container
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
                duration: 1500
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
                
                // Usage Arc
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

            // Repaint when usage changes
            Connections {
                target: diskDisplay
                function onDiskUsedChanged() {
                    usageAnimation.to = Math.round(diskDisplay.diskUsed)
                    usageAnimation.restart()
                }
            }
        }
    }

    // Disk Free Space Process
    Process {
        id: diskUsedP
        command: [
        "sh", "-c",
        "df -P \"$1\" | awk 'NR==2 {gsub(/%/, \"\", $5); print $5}'",
        "sh", diskDisplay.diskShown
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                diskDisplay.diskUsed = this.text.trim();
            }
        }
    }

    // Temp Process
    Process {
        id: diskTemp
        command: [
        "sh", "-c",
        "sensors | awk '/^nvme-pci-0a00$/{f=1;next} f&&/Composite/{match($0,/([+\\-]?[0-9]+\\.?[0-9]*)°C/,m); gsub(/^\\+/, \"\", m[1]); print m[1]; exit}'"]   
        stdout: StdioCollector {
            onStreamFinished: {
                diskDisplay.diskTemp = this.text.trim()
            }
        }
    }

    // On Click Action
    Process {
        id: onClick
        command: ["sh", "-c", "nemo $1", "sh", "/"]
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            if (diskDisplay.diskShown === "/") {
                diskDisplay.diskShown = "/mnt/xyz"        
            }else{
                diskDisplay.diskShown = "/"        
            }
            diskUsedP.running = true
            diskTemp.running = true
        }
    }

    Component.onCompleted: {
        diskUsedP.running = true
        diskTemp.running = true
    }
}