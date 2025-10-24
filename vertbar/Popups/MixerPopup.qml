import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Hyprland
import Quickshell.Wayland
import qs

Scope {
  id: root

  function toggle() { panelWindow.visible ? close() : open() }
  function open() {
    panelWindow.visible = true
    if (panelWindow.requestActivate) panelWindow.requestActivate()
  }
  function close() { panelWindow.visible = false }

  property bool buttonHover: false

  Timer {
      id: closeTimer
      interval: 250
      onTriggered: {
          if (!buttonHover) {
              root.close()
          }
      }   
  }

  PanelWindow {
    id: panelWindow
    anchors.bottom: true
    anchors.right: true
    exclusiveZone: 0
    visible: false

    margins.bottom: 100
    margins.right: 10

    implicitWidth: 590
    implicitHeight: Math.min(600, column.implicitHeight + 20)

    // Set layer name for Hyprland blur effects
    WlrLayershell.namespace: "quickshell:volpopup:blur"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    color: "transparent"

    // The Mixer Panel in the lower-right corner
    Rectangle {
      id: panel
      color: Matugen.colors.background
      opacity: 0.75
      radius: 10
      border.color: Matugen.colors.inverse_primary
      border.width: 2

      anchors.fill: parent

      MouseArea {
          id: mouseArea
          acceptedButtons: Qt.NoButton
          anchors.fill: parent
          hoverEnabled: true
          propagateComposedEvents: true

          onContainsMouseChanged: {
              if (!containsMouse) {
                  console.log("unhovered:")
                  closeTimer.start()
              } else {
                console.log("hovered:")
                  closeTimer.stop()
              }
          }
      }

      ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
          id: column
          anchors.fill: parent
          anchors.margins: 10

          PwNodeLinkTracker { id: linkTracker; node: Pipewire.defaultAudioSink }
          MixerEntry { node: Pipewire.defaultAudioSink }

          Rectangle { Layout.fillWidth: true; color: palette.active.text; implicitHeight: 0 }

          Repeater {
            model: linkTracker.linkGroups
            MixerEntry {
              required property PwLinkGroup modelData
              node: modelData.source
            }
          }
        }
      }
    }
  }
}