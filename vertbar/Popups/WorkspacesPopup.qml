import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import qs

Scope {
    id: root

    property int totalWorkspaces: 6
    property int currentWorkspace: 1
    property bool shouldShowOsd: false
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

    // Auto hides after interval
    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: shouldShowOsd = false
    }

    // Connects to workspace values
    Connections {
        target: Hyprland
        
        function onRawEvent(event) {
            if (event.name.includes("workspace")) {
                Qt.callLater(updateCurrentWorkspace)
            }
        }
    }

    // Connect to workspace values changes
    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            Qt.callLater(updateCurrentWorkspace)
        }
    }

    // Update current workspace function
    function updateCurrentWorkspace() {
        try {
            const workspaces = Hyprland.workspaces.values
            
            for (let i = 0; i < workspaces.length; i++) {
                const ws = workspaces[i]
                if (ws.focused === true) {
                    if (ws.id !== currentWorkspace) {
                        currentWorkspace = ws.id
                        currentMonitor = workspaceMonitorMap[ws.id] || "DP-1"
                    }
                    break
                }
            }
        } catch (error) {
            // Error handling
        }
        shouldShowOsd = true;
        hideTimer.restart();
    }

    // The OSD window will be created and destroyed based on shouldShowOsd.
    // PanelWindow.visible could be set instead of using a loader, but using
    // a loader will reduce the memory overhead when the window isn't open.
    LazyLoader {
    active: shouldShowOsd

        PanelWindow {
            screen: Quickshell.screens.find(s => s.name === currentMonitor)

            anchors.top: true
            margins.top: screen.height / 10
            exclusiveZone: 0
            implicitWidth: 200
            implicitHeight: 235
            color: "transparent"

            // Set layer name for Hyprland blur effects
            WlrLayershell.namespace: "quickshell:wspopup:blur"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            mask: Region {}

            Rectangle {
                id: bgrect
                anchors.fill: parent
                color: Matugen.colors.background
                opacity: 0.75
                radius: 10
                border.color: Matugen.colors.inverse_primary
                border.width: 2

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 0

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Workspace".toUpperCase()
                        font.pixelSize: 24
                        font.family: "MesloLGM Nerd Font Propo"
                        font.bold: true
                        color: Matugen.colors.on_background
                    }

                    Text {

                        Layout.alignment: Qt.AlignHCenter
                        text: `${currentWorkspace}`
                        font.pixelSize: 72
                        font.family: "MesloLGM Nerd Font Propo"
                        font.bold: true
                        color: Matugen.colors.on_background

                    }

                    GridLayout {
                        id: grid
                        Layout.alignment: Qt.AlignHCenter
                        columns: 3

                        Repeater {
                            model: totalWorkspaces

                            Rectangle {
                                id: rect
                                width: 50
                                height: 30
                                radius: 10
                                color: (index + 1) === currentWorkspace
                                        ? Matugen.colors.on_secondary_container
                                        : Matugen.colors.secondary
                                opacity: (index + 1) === currentWorkspace ? 1.0 : 0.3
                                Behavior on color { ColorAnimation { duration: 200 } }
                                Behavior on opacity { NumberAnimation { duration: 200 } }

                               Text {
                                    anchors.centerIn: rect
                                    text: workspaceMonitorMap[(index + 1)]
                                    color: Matugen.colors.background
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.family: "MesloLGM Nerd Font Propo"
                               }                             
                            }
                        }
                    }
                }
            }
        }
    }
}