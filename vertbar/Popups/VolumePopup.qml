import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import qs

Scope {
	id: root

	// Volume range properties
	property real minVolume: 0
	property real maxVolume: 1.5

	// Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}

	Connections {
		target: Pipewire.defaultAudioSink?.audio

		function onVolumeChanged() {
			if (Pipewire.defaultAudioSink.audio.volume > root.maxVolume) {
            	Pipewire.defaultAudioSink.volume = root.maxVolume;
			} else if (Pipewire.defaultAudioSink.audio.volume < root.minVolume) {
				Pipewire.defaultAudioSink.volume = root.minVolume;
			}
			root.shouldShowOsd = true;
			hideTimer.restart();
		}
	}

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

			anchors.top: true
			margins.top: screen.height / 5
			exclusiveZone: 0

			implicitWidth: 400
			implicitHeight: 50

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

				RowLayout {
					anchors {
						fill: parent
						leftMargin: 10
						rightMargin: 15
					}

					Item {
						width: 30
						height: 30

						Image {
							id: volumeIcon
							source: `root:icons/${Pipewire.defaultAudioSink.audio.muted ? "volume_muted.svg" : "volume_high.svg"}`
							sourceSize: Qt.size(parent.width, parent.height)
							smooth: true
							visible: false
						}

						ColorOverlay {
							anchors.fill: volumeIcon
							source: volumeIcon
							color: Matugen.colors.on_primary_container
						}
					}

					Rectangle {
						// Stretches to fill all left-over space
						Layout.fillWidth: true

						implicitHeight: 10
						radius: 20
						color: Matugen.colors.on_primary_container

						Rectangle {
							anchors {
								left: parent.left
								top: parent.top
								bottom: parent.bottom
							}

							implicitWidth: parent.width * Math.min(1, Math.max(0, (Pipewire.defaultAudioSink?.audio.volume ?? 0) - root.minVolume) / (root.maxVolume - root.minVolume))
							radius: parent.radius
						}
					}
				}
			}
		}
	}
}
