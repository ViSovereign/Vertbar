import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import qs

Scope {
	id: root

    function toggle() { !shouldShowOsd ? open() : close() }
    function open() {
        shouldShowOsd = true;
    }
    function close() { shouldShowOsd = false;}

    property bool buttonHover: false
    property string openPath: "/"
	property bool shouldShowOsd: false

    ListModel {
        id: directoryModel
        ListElement { name: "root"; path: "/" }
        ListElement { name: "home"; path: "/home/b" }
        ListElement { name: ".config"; path: "/home/b/.config" }
        ListElement { name: "downloads"; path: "/home/b/Downloads" }
        ListElement { name: "xyz"; path: "/mnt/xyz" }
        ListElement { name: "wallpapers"; path: "/mnt/xyz/Pictures/Wallpapers" }
        ListElement { name: "dotfiles"; path: "/mnt/xyz/dotfiles" }
    }

    Timer {
        id: closeTimer
        interval: 250
        onTriggered: {
            if (!buttonHover) {
                root.close()
            }
        }   
    }

    Process {
        id: onClick
        command: ["nemo", root.openPath]
    }

	// The OSD window will be created and destroyed based on shouldShowOsd.
	// PanelWindow.visible could be set instead of using a loader, but using
	// a loader will reduce the memory overhead when the window isn't open.
	LazyLoader {
		active: root.shouldShowOsd

		PanelWindow {
			// Since the panel's screen is unset, it will be picked by the compositor
			// when the window is created. Most compositors pick the current active monitor.
            id: panelWindow
            anchors.right: true
            anchors.top: true
            exclusiveZone: 0

            margins.top: 200
            margins.right: 10

			implicitWidth: 120
			//implicitHeight: (directoryModel.count * 30)
            implicitHeight: columnButtons.implicitHeight + 20

            // Set layer name for Hyprland blur effects
            WlrLayershell.namespace: "quickshell:volpopup:blur"
			WlrLayershell.layer: WlrLayer.Top
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

			color: "transparent"

			Rectangle {
				anchors.fill: parent
                color: Matugen.colors.background
                opacity: 0.5
                radius: 10
                border.color: Matugen.colors.inverse_primary
                border.width: 2

                MouseArea {
                    id: mouseArea
                    acceptedButtons: Qt.NoButton
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true

                    onContainsMouseChanged: {
                        if (!containsMouse) {
                            closeTimer.start()
                        } else {
                            closeTimer.stop()
                        }
                    }
                }

                Column {
                    id: columnButtons
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    Repeater {
                        id: repeater
                        model: directoryModel

                        Button {
                            id: button
                            text: name
                            hoverEnabled: true
                            
                            onClicked: {
                                closeTimer.stop()
                                root.openPath = path
                                //console.log("Selected:", name, "Path:", root.openPath)
                                onClick.running = true
                                root.close()
                            }
                            
                            onHoveredChanged: {
                                if (hovered) {
                                    root.buttonHover = true
                                    //console.log("hovered:", name)
                                } else {
                                    root.buttonHover = false
                                    //console.log("unhovered:", name)
                                }
                            }

                            contentItem: Text {
                                text: name
                                font.pixelSize: 12
                                font.bold: true
                                font.family: "MesloLGM Nerd Font Propo"
                                color: button.down ? Matugen.colors.on_primary_container : Matugen.colors.on_secondary_container
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }
                            
                            // Background with color, border, radius, states
                            background: Rectangle {
                                radius: 10
                                color: button.down ? Matugen.colors.on_primary_container : (button.hovered ? Matugen.colors.on_tertiary_container : Matugen.colors.on_secondary)

                                // smooth hover transitions
                                Behavior on color { ColorAnimation { duration: 120 } }
                                Behavior on border.color { ColorAnimation { duration: 120 } }

                            }
                            scale: button.down ? 0.98 : (button.hovered ? 1.02 : 1.0)
                            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

                            // Optional size
                            implicitWidth: 100
                            implicitHeight: 20                            
                        }
                    }
                }
			}
		}
	}
}
