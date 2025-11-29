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

    // Values from your processes
    property real cpuUsage: 0
    property real memUsage: 0
    property real gpuUsage: 0
    property string cpuTemp: "?"

    // For hover label
    property string hoverLabel: ""
    property real hoverValue: -1

    // --- Animations (kept from your code, just retargeted) ---
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
            //hoverAnimation.targets = [barsRow]
            //hoverAnimation.start()
            //rotateAnimation.target = temptext    // or some icon if you prefer
            //rotateAnimation.start()
        }

        onExited: {
            //exitAnimation.targets = [barsRow]
            //exitAnimation.start()
        }

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
            spacing: 2

            // Temp text at top
            Text {
                id: temptext
                Layout.alignment: Qt.AlignHCenter
                text: cpumemDisplay.hoverValue >= 0
                      ? (cpumemDisplay.hoverLabel + " " +
                         Math.round(cpumemDisplay.hoverValue) + "%")
                      : (cpumemDisplay.cpuTemp + "°")
                color: Matugen.colors.on_background
                font.pixelSize: 10
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

                    // Helper to avoid repeated color logic
                    function usageColor(usage) {
                        if (usage > 80) return Matugen.colors.error
                        if (usage > 50) return Matugen.colors.on_tertiary_container
                        return Matugen.colors.on_secondary_container
                    }

                    // ==== CPU BAR ====
                    Item {
                        id: cpuBarItem
                        anchors.bottom: parent.bottom
                        width: (parent.width - 2*spacing) / 3
                        height: parent.height

                        Rectangle {
                            id: cpuBG
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            width: 8
                            height: parent.height
                            color: Matugen.colors.on_secondary
                            radius: 2
                        }

                        Rectangle {
                            id: cpuFill
                            anchors.horizontalCenter: cpuBG.horizontalCenter
                            anchors.bottom: cpuBG.bottom
                            width: 5
                            height: cpuBG.height * (cpumemDisplay.cpuUsage / 100.0)
                            color: barsRow.usageColor(cpumemDisplay.cpuUsage)
                            radius: 2

                            Behavior on height {
                                NumberAnimation {
                                    duration: 400
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                        // Hover for CPU
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                cpumemDisplay.hoverLabel = ""
                                cpumemDisplay.hoverValue = cpumemDisplay.cpuUsage
                            }
                            onExited: {
                                cpumemDisplay.hoverValue = -1
                            }
                        }

                    }

                    // ==== MEM BAR ====
                    Item {
                        id: memBarItem
                        anchors.bottom: parent.bottom
                        width: (parent.width - 2*spacing) / 3
                        height: parent.height

                        Rectangle {
                            id: memBG
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            width: 8
                            height: parent.height
                            color: Matugen.colors.on_secondary
                            radius: 2
                        }

                        Rectangle {
                            id: memFill
                            anchors.horizontalCenter: memBG.horizontalCenter
                            anchors.bottom: memBG.bottom
                            width: 5
                            height: memBG.height * (cpumemDisplay.memUsage / 100.0)
                            color: barsRow.usageColor(cpumemDisplay.memUsage)
                            radius: 2

                            Behavior on height {
                                NumberAnimation {
                                    duration: 400
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                        // Hover for MEM
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                cpumemDisplay.hoverLabel = ""
                                cpumemDisplay.hoverValue = cpumemDisplay.memUsage
                            }
                            onExited: {
                                cpumemDisplay.hoverValue = -1
                            }
                        }
                    }

                    // ==== GPU BAR ====
                    Item {
                        id: gpuBarItem
                        anchors.bottom: parent.bottom
                        width: (parent.width - 2*spacing) / 3
                        height: parent.height

                        Rectangle {
                            id: gpuBG
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            width: 8
                            height: parent.height
                            color: Matugen.colors.on_secondary
                            radius: 2
                        }

                        Rectangle {
                            id: gpuFill
                            anchors.horizontalCenter: gpuBG.horizontalCenter
                            anchors.bottom: gpuBG.bottom
                            width: 5
                            height: gpuBG.height * (cpumemDisplay.gpuUsage / 100.0)
                            color: barsRow.usageColor(cpumemDisplay.gpuUsage)
                            radius: 2

                            Behavior on height {
                                NumberAnimation {
                                    duration: 400
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                        // Hover for GPU
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                cpumemDisplay.hoverLabel = ""
                                cpumemDisplay.hoverValue = cpumemDisplay.gpuUsage
                            }
                            onExited: {
                                cpumemDisplay.hoverValue = -1
                            }
                        }
                    }
                }

                // Bottom labels C M G
                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 10
                    spacing: 1
                    layoutDirection: Qt.LeftToRight

                    Repeater {
                        model: ["memory", "memory_alt", "sports_esports"]
                        delegate: Text {
                            text: modelData    // replace with icon glyph if you want
                            font.pixelSize: 12
                            font.family: "Material Symbols Rounded"
                            color: Matugen.colors.on_background
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            width: (parent.width - 2*spacing) / 3
                        }
                    }
                }
            }
        }
    }

    // -------- PROCESSES (CPU, MEM, GPU, Temp) --------
    Process {
        id: cpuProcess
        command: ["sh", "-c", "awk '/^cpu / {usage=($2+$4+$6)*100/($2+$3+$4+$5+$6+$7+$8+$9+$10)} END {print usage}' /proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: cpumemDisplay.cpuUsage = parseFloat(this.text.trim())
        }
    }

    Process {
        id: memUsage
        command: ["sh", "-c", "free | grep Mem | awk '{usage=($3/$2)*100} END {print usage}'"]
        stdout: StdioCollector {
            onStreamFinished: cpumemDisplay.memUsage = parseFloat(this.text.trim())
        }
    }

    // NVIDIA GPU usage (0–100)
    Process {
        id: gpuProcess
        command: ["sh", "-c", "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: cpumemDisplay.gpuUsage = parseFloat(this.text.trim())
        }
    }

    Process {
        id: cpuTemp
        command: ["/home/b/.config/quickshell/scripts/cputemp.sh"]
        stdout: StdioCollector {
            onStreamFinished: cpumemDisplay.cpuTemp = this.text.trim()
        }
    }

    Process {
        id: onClick
        command: ["sh", "-c", "missioncenter"]
    }

    Timer {
        interval: 1000 * 2
        running: true
        repeat: true
        onTriggered: {
            cpuProcess.running = true
            memUsage.running = true
            gpuProcess.running = true
            cpuTemp.running = true
        }
    }

    Component.onCompleted: {
        cpuProcess.running = true
        memUsage.running = true
        gpuProcess.running = true
        cpuTemp.running = true
    }
}
