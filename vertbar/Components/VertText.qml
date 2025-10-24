import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

Item {

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        propagateComposedEvents: true

        onClicked: function(event) {
            if (event.button === Qt.LeftButton) {
                calendarRequested()
            }
        }

        onPressed:  datecolumn.scale = 0.90
        onReleased: datecolumn.scale = 1.0
        
        onEntered: {
            dayyText.color = Matugen.colors.on_tertiary_container
        }

        onExited: {
            dayyText.color = Matugen.colors.on_background
        }

    }

    Text {
        color: Matugen.colors.on_background
        font.pixelSize: 12
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