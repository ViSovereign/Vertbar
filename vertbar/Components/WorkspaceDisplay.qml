import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import qs

ColumnLayout {
    id: workspaceDisplay
    spacing: 2

    property string activeWorkspace1: "?"
    property string activeWorkspace2: "?"
    property string currentMonitor: "DP-1"

    // Workspace to monitor mapping
    property var workspaceMonitorMap: {
        1: "DP-1",
        2: "DP-1",
        3: "DP-1",
        4: "DP-2",
        5: "DP-2",
        6: "DP-2"
    }

    // Connects to workspace values
    Connections {
        target: Hyprland

        function onRawEvent(event) {

        if (event.name.includes("workspace")) {
            Qt.callLater(() => { activeWorkspace.running = true })
        }

            if (event.name.includes("focusedmon")) {
                Qt.callLater(updateCurrentMonitor)
            }
        }
    }

    Connections {
        target: Hyprland.monitors
        function onValuesChanged() {
            Qt.callLater(updateCurrentMonitor)
        }
    }

    function updateCurrentMonitor() {
        try {

            // Get the currently focused workspace
            const workspaces = Hyprland.workspaces.values
            for (let i = 0; i < workspaces.length; i++) {
                const ws = workspaces[i]
                if (ws.focused === true) {
                    const newMonitor = workspaceMonitorMap[ws.id] || "DP-1"
                    //console.log("Active workspace:", ws.id, "Mapped to monitor:", newMonitor)
                    workspaceDisplay.currentMonitor = newMonitor
                    return
                }
            }
        } catch (error) {
            console.log("Error in updateCurrentMonitor:", error)
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

    MouseArea {
        id: mouseArea
        acceptedButtons: Qt.LeftButton
        anchors.fill: parent
        hoverEnabled: true

        onPressed:  workspaceDisplay.scale = 0.90
        onReleased: workspaceDisplay.scale = 1.0

        onEntered: {
            hoverAnimation.target = workspaceDisplay
            monitorIcon.color = Matugen.colors.on_tertiary_container
            activeMonitorText.color = Matugen.colors.on_tertiary_container
            activeWorkSpacetext.color = Matugen.colors.on_tertiary_container
            activeMonitorRectange.color = Matugen.colors.on_tertiary
            hoverAnimation.start();
        }

        onExited: {
            exitAnimation.target = workspaceDisplay
            monitorIcon.color = Matugen.colors.on_primary_container
            activeMonitorText.color = Matugen.colors.background
            activeWorkSpacetext.color = Matugen.colors.on_primary_container
            activeMonitorRectange.color = Matugen.colors.on_primary_container
            exitAnimation.start();
        }

        onClicked: event => {
            if (event.button === Qt.LeftButton) {
                event.accepted = true;
                deepLinkKeyBinds.running = true
            }
        }

        // Change the cursor
        cursorShape: Qt.PointingHandCursor

    }

    Item {
        Layout.topMargin: -5
        Layout.preferredHeight: monitorIcon.height
        Layout.preferredWidth: monitorIcon.width

        Rectangle {
            id: "activeMonitorRectange"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -2
            anchors.horizontalCenterOffset: -1
            color: Matugen.colors.on_primary_container
            width: 22
            height: 16
        }

        Text {
            id: "monitorIcon"
            text: "monitor"
            color: Matugen.colors.on_primary_container
            font.pixelSize: 30
            font.family: "Material Symbols Rounded"
            opacity: 1.0
            anchors.centerIn: parent
        }

        Text {
            id: "activeMonitorText"
            anchors.centerIn: parent
            text: workspaceDisplay.currentMonitor.replace("DP-", "")
            color: Matugen.colors.background
            font.pixelSize: 12
            font.bold: true
            font.family: "MesloLGM Nerd Font Propo"
            opacity: 1.0
        }
    }

    Text {
        id: "activeWorkSpacetext"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: workspaceDisplay.activeWorkspace2 + "|" + workspaceDisplay.activeWorkspace1
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
                target: activeWorkspacetext1
                from: 1.0
                to: 0.7
                duration: 1000
            }
            OpacityAnimator {
                target: activeWorkspacetext1
                from: 0.7
                to: 1.0
                duration: 1000
            }
            PauseAnimation { duration: 5000 }

        }

    }

    // Get Monitor Active Workspaces
    Process {
        id: activeWorkspace
        command: ["/home/b/.config/quickshell/scripts/activeWorkspace.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split('\n')
                workspaceDisplay.activeWorkspace1 = lines[0]
                workspaceDisplay.activeWorkspace2 = lines[1]
            }
        }
    }

    Component.onCompleted: {
        activeWorkspace.running = true
        updateCurrentMonitor()
    }

    // Deep Link to Hypr Keybind Extension in vicinae
    Process {
        id: deepLinkKeyBinds
        command: ["sh", "-c", "vicinae vicinae://extensions/vicinae/wm/switch-windows"]
    }
}
