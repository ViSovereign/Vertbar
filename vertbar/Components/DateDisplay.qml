import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

ColumnLayout {
    id: root
    spacing: 0

    // One time string to parse them all
    property date now: new Date()

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

    // I wonder what th-is does?
    function getOrdinalSuffix(day) {
        if (day >= 11 && day <= 13) return "th"
        switch (day % 10) {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
        }
    }

    // Expose the signal on the component itself so VertBar can connect to it
    signal calendarRequested()

    ColumnLayout {
        id: datecolumn
        spacing: 0

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
                monthText.color = Matugen.colors.on_tertiary_container
                dayText.color = Matugen.colors.on_tertiary_container
                suffixText.color = Matugen.colors.on_tertiary_container
                hoverAnimation.target = datecolumn
                hoverAnimation.start();
            }

            onExited: {
                dayyText.color = Matugen.colors.on_background
                monthText.color = Matugen.colors.on_background
                dayText.color = Matugen.colors.on_background
                suffixText.color = Matugen.colors.on_background
                exitAnimation.target = datecolumn
                exitAnimation.start();
            }

            // Change the cursor
            cursorShape: Qt.PointingHandCursor

        }

        // Day with letters
        Text {
            id: dayyText
            text: Qt.formatDate(root.now, "ddd").toUpperCase()
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

        // Month three letters
        Text {
            id: monthText
            text: Qt.formatDate(root.now, "MMM").toUpperCase()
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

        RowLayout {
            spacing: 0

            // Day in Month
            Text {
                id: dayText
                text: Qt.formatDate(root.now, "dd")
                color: Matugen.colors.on_background
                font.pixelSize: 12
                font.family: "MesloLGM Nerd Font Propo"
                font.bold: true
                opacity: 1.0

                Behavior on color {
                    ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }
            }

            // Suffix
            Text {
                id: suffixText
                text: {
                    const d = root.now.getDate()
                    return getOrdinalSuffix(d)
                }
                color: Matugen.colors.on_background
                font.pixelSize: 8
                font.family: "MesloLGM Nerd Font Propo"
                font.bold: true
                Layout.alignment: Qt.AlignTop
                opacity: 1.0

                Behavior on color {
                    ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }
            }
        }
    }

    // Update time every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.now = new Date()
        }
    }

    // Initialize time immediately
    Component.onCompleted: {
        root.now = new Date()
    }
}
