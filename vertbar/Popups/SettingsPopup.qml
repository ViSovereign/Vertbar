import QtQuick
import QtQuick.Layouts
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

	property bool shouldShowOsd: false

	Timer {
		id: hideTimer
		interval: 1000
		onTriggered: root.shouldShowOsd = false
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
            anchors.bottom: true
            exclusiveZone: 0

            margins.bottom: 10
            margins.right: 10

			implicitWidth: 800
			implicitHeight: 800

            // Set layer name for Hyprland blur effects
            WlrLayershell.namespace: "quickshell:volpopup:blur"
			WlrLayershell.layer: WlrLayer.Top
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

			color: "transparent"

			// An empty click mask prevents the window from blocking mouse events.
			mask: Region {}

			Rectangle {
				anchors.fill: parent
                color: Matugen.colors.background
                opacity: 0.5
                radius: 10
                border.color: Matugen.colors.inverse_primary
                border.width: 2

        // Day with letters
        Text {
            id: dayyText
            text: "Bitch"
            color: Matugen.colors.on_background
            font.pixelSize: 14
            font.family: "MesloLGM Nerd Font Propo"
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            opacity: 1

            Behavior on color {
                ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }

        }

			}
		}
	}
}
