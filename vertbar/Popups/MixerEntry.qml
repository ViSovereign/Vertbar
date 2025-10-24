import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Pipewire
import qs

ColumnLayout {
	required property PwNode node;

	// bind the node so we can read its properties
	PwObjectTracker { objects: [ node ] }

	RowLayout {

		//Image {
		//	visible: source != ""
		//	source: {
		//		const icon = node.properties["application.icon-name"] ?? "volume_high.svg";
		//		return `image://icon/${icon}`;
		//	}
		//
		//	sourceSize.width: 20
		//	sourceSize.height: 20
		//}

		Label {
			text: {
				// application.name -> description -> name
				const app = node.properties["application.name"] ?? (node.description != "" ? node.description : node.name);
				const media = node.properties["media.name"];
				return media != undefined ? `${app} - ${media}` : app;
			}
			color: Matugen.colors.on_primary_container
			font.pixelSize: 12
			font.bold: true
            font.family: "MesloLGM Nerd Font Propo"
		}
	}

	RowLayout {

		Button {
			id: muteButton
			text: node.audio.muted ? "unmute" : `${Math.floor(node.audio.volume * 100)}%`
			hoverEnabled: true
			
			onClicked: {
				node.audio.muted = !node.audio.muted
			}

			contentItem: Text {
				text: muteButton.text
				font.pixelSize: 12
				font.bold: true
				font.family: "MesloLGM Nerd Font Propo"
				color: muteButton.down ? Matugen.colors.on_primary_container : Matugen.colors.on_secondary_container
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				elide: Text.ElideRight
			}

			// Background with color, border, radius, states
			background: Rectangle {
				radius: 10
				color: muteButton.down ? Matugen.colors.on_primary_container : (muteButton.hovered ? Matugen.colors.on_background : Matugen.colors.on_secondary)

				// smooth hover transitions
				Behavior on color { ColorAnimation { duration: 120 } }
				Behavior on border.color { ColorAnimation { duration: 120 } }

			}
			scale: muteButton.down ? 0.98 : (muteButton.hovered ? 1.02 : 1.0)
			Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

			// Optional size
			implicitWidth: 60
			implicitHeight: 20

		}

		// This is replacing the slider property because i dont like it
		Item {
			id: volumeSlider
			Layout.preferredWidth: 495
			Layout.preferredHeight: 25

			// range and warning
			property real from: 0.0
			property real to: 1.5
			property real warning: 1.0

			// helper to clamp 0..1
			function clamp01(n) { return Math.max(0, Math.min(1, n)) }

			MouseArea {
				id: mouseArea
				anchors.fill: parent
				hoverEnabled: true

				// Change the cursor
				cursorShape: Qt.PointingHandCursor

				// Track
				Rectangle {
					id: groove
					anchors {
						left: parent.left
						right: parent.right
						verticalCenter: parent.verticalCenter
					}
					implicitHeight: 15
					color: node.audio.muted ? Matugen.colors.on_tertiary : Matugen.colors.surface_variant
					radius: height * 0.5
				}

				// Fill up to current value
				Rectangle {
					id: grooveFill
					anchors {
						left: groove.left
						top: groove.top
						bottom: groove.bottom
					}
					width: volumeSlider.clamp01((node.audio.volume - volumeSlider.from) / (volumeSlider.to - volumeSlider.from)) * groove.width
					radius: groove.radius
					color: node.audio.muted ? Matugen.colors.on_tertiary_container : Matugen.colors.primary
				}

				// Handle
				Rectangle {
					id: handle
					width: 22
					height: 22
					radius: height * 0.5
					x: groove.x + volumeSlider.clamp01((node.audio.volume - volumeSlider.from) / (volumeSlider.to - volumeSlider.from)) * groove.width - width * 0.5
					anchors.verticalCenter: groove.verticalCenter
					color: mouseArea.pressed ? Matugen.colors.primary
        				: (mouseArea.containsMouse ? Matugen.colors.primary
						: Matugen.colors.primary_container)
					border.color: Matugen.colors.primary
					border.width: 2
					opacity: node.audio.muted ? 0.0 : 1

					transform: Scale {
						id: handleScale
						origin.x: handle.width / 2
						origin.y: handle.height / 2
						xScale: mouseArea.pressed ? 1.5 : (mouseArea.containsMouse ? 1.08 : 1.0)
						yScale: xScale
					}
				}

				// Click/drag to set
				onPressed: (event) => {
					const pos = volumeSlider.clamp01((mouseX - groove.x) / groove.width)
					const next = pos * (volumeSlider.to - volumeSlider.from) + volumeSlider.from
					node.audio.volume = next
				}
				onPositionChanged: (event) => {
					if (!pressed) return
					const pos = volumeSlider.clamp01((mouseX - groove.x) / groove.width)
					const next = pos * (volumeSlider.to - volumeSlider.from) + volumeSlider.from
					node.audio.volume = next
				}

				// Wheel to adjust (5% per notch)
				onWheel: (event) => {
				event.accepted = true
					const step = 0.05
					const deltaNotches = ((event.angleDelta.x || 0) !== 0 ? event.angleDelta.x : event.angleDelta.y) / 120
					const next = node.audio.volume + deltaNotches * step
					node.audio.volume = Math.max(volumeSlider.from, Math.min(volumeSlider.to, next))
				}
			}
		}
	}
}
