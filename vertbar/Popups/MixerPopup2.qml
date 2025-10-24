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

  PanelWindow {
    id: panelWindow
    visible: false
    color: "Transparent"
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusiveZone: 0

    // Set layer name for Hyprland blur effects
    //WlrLayershell.namespace: "quickshell:volpopup:blur"
    //WlrLayershell.layer: WlrLayer.Top
    //WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Full-screen scrim behind the panel
    Rectangle {
      id: scrim
      anchors.fill: parent
      color: "Transparent"
      opacity: 0.0
      z: 0

      MouseArea {
        anchors.fill: parent
        onClicked: root.close()
      }
    }

    Rectangle {
      id: blur
      anchors.right: parent.right
      anchors.bottom: parent.bottom

      // The Mixer Panel in the lower-right corner
      Rectangle {
        id: panel
        z: 1
        color: Matugen.colors.background
        opacity: 0.75
        radius: 10
        border.color: Matugen.colors.inverse_primary
        border.width: 2

        anchors.right: parent.right
        anchors.bottom: parent.bottom
        //anchors.bottomMargin: Math.min(0, 200 - column.implicitHeight)
        anchors.bottomMargin: 120
        anchors.rightMargin: 10

        width: 590
        implicitHeight: Math.min(600, column.implicitHeight + 20)

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
}