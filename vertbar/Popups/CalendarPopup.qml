import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs

Scope {
    id: root
    
    function toggle() { calendarPanel.visible ? close() : open() }
    function open() {
        calendarPanel.visible = true
        if (calendarPanel.requestActivate) calendarPanel.requestActivate()
    }
    function close() { calendarPanel.visible = false }

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

    Process {
        id: clipProcess
        command: ["wl-copy", clicked.toDateString()]
    }

    PanelWindow {
        id: calendarPanel
        visible: false
        anchors.right: true
        margins.top: screen.height / 2
        margins.right: 10
        exclusiveZone: 0
        implicitWidth: 300
        implicitHeight: 305
        color: "transparent"

        // Set layer name for Hyprland blur effects
        WlrLayershell.namespace: "quickshell:volpopup:blur"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        // Calendar state and helpers
        property date currentDate: new Date()
        property int viewMonth: currentDate.getMonth()
        property int viewYear: currentDate.getFullYear()

        function firstWeekdayOfMonth(year, month) {
            // 0=Sun and 6=Sat
            return new Date(year, month, 1).getDay();
        }
        function daysInMonth(year, month) {
            return new Date(year, month + 1, 0).getDate();
        }
        function prevMonth() {
            if (viewMonth === 0) { viewMonth = 11; viewYear--; }
            else viewMonth--;
        }
        function nextMonth() {
            if (viewMonth === 11) { viewMonth = 0; viewYear++; }
            else viewMonth++;
        }

        Rectangle {
            id: rect
            anchors.fill: parent
            color: Matugen.colors.background
            radius: 10
            opacity: 0.75
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

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                // Header with navigation
                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        id: backButton
                        text: Qt.formatDate(new Date(calendarPanel.viewYear, calendarPanel.viewMonth-1, 1), "MMM yyyy")
                        hoverEnabled: true

                        onClicked: {
                            closeTimer.stop()
                            calendarPanel.prevMonth()
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
                            text: backButton.text
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "MesloLGM Nerd Font Propo"
                            color: backButton.down ? Matugen.colors.on_tertiary_container : Matugen.colors.on_secondary_container
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        // Background with color, border, radius, states
                        background: Rectangle {
                            radius: 10
                            color: backButton.down ? Matugen.colors.on_tertiary : (backButton.hovered ? Matugen.colors.on_background : Matugen.colors.on_secondary)

                            // smooth hover transitions
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Behavior on border.color { ColorAnimation { duration: 120 } }

                        }
                        scale: backButton.down ? 0.90 : (backButton.hovered ? 1.02 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

                        // Optional size
                        implicitWidth: 70
                        implicitHeight: 20

                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: Qt.formatDate(new Date(calendarPanel.viewYear, calendarPanel.viewMonth, 1), "MMM yyyy")
                        color: Matugen.colors.on_primary_container
                        font.pixelSize: 18
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        id: nextButton
                        text: Qt.formatDate(new Date(calendarPanel.viewYear, calendarPanel.viewMonth+1, 1), "MMM yyyy")
                        hoverEnabled: true

                        onClicked: {
                            closeTimer.stop()
                            calendarPanel.nextMonth()
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
                            text: nextButton.text
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "MesloLGM Nerd Font Propo"
                            color: nextButton.down ? Matugen.colors.on_primary_container : Matugen.colors.on_secondary_container
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        // Background with color, border, radius, states
                        background: Rectangle {
                            radius: 10
                            color: nextButton.down ? Matugen.colors.on_primary_container : (nextButton.hovered ? Matugen.colors.on_background : Matugen.colors.on_secondary)

                            // smooth hover transitions
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Behavior on border.color { ColorAnimation { duration: 120 } }

                        }
                        scale: nextButton.down ? 0.90 : (nextButton.hovered ? 1.02 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

                        // Optional size
                        implicitWidth: 70
                        implicitHeight: 20

                    }

                }

                // Day-of-week header
                GridLayout {
                    columns: 7
                    Layout.fillWidth: true

                    Repeater {
                        model: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                            color: "transparent"

                            Text {
                                anchors.centerIn: parent
                                color: Matugen.colors.on_tertiary_container
                                font.pixelSize: 10
                                text: modelData
                                font.bold: true
                            }
                        }
                    }
                }

                // Month grid (6 weeks x 7 days)
                GridLayout {
                    id: grid
                    columns: 7
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    readonly property int firstDay: calendarPanel.firstWeekdayOfMonth(calendarPanel.viewYear, calendarPanel.viewMonth)
                    readonly property int countDays: calendarPanel.daysInMonth(calendarPanel.viewYear, calendarPanel.viewMonth)

                    Repeater {
                        model: 42
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            radius: 10
                            color: "transparent"

                            // Map index to date
                            readonly property int dayNumber: index - grid.firstDay + 1
                            readonly property bool inCurrentMonth: dayNumber >= 1 && dayNumber <= grid.countDays
                            readonly property bool isToday: inCurrentMonth &&
                                (calendarPanel.viewYear === calendarPanel.currentDate.getFullYear()) &&
                                (calendarPanel.viewMonth === calendarPanel.currentDate.getMonth()) &&
                                (dayNumber === calendarPanel.currentDate.getDate())

                            border.width: isToday ? 2 : 0
                            border.color: isToday ? Matugen.colors.on_tertiary_container : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: inCurrentMonth ? dayNumber : ""
                                color: inCurrentMonth ? Matugen.colors.primary_fixed_dim : "transparent"
                                font.pixelSize: 12
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: inCurrentMonth
                                hoverEnabled: true

                                onContainsMouseChanged: {
                                    if (!containsMouse) {
                                        root.buttonHover = true
                                    } else {
                                        root.buttonHover = false
                                    }
                                }

                                onClicked: {
                                    const clicked = new Date(calendarPanel.viewYear, calendarPanel.viewMonth, parent.dayNumber)
                                    console.log("Clicked date:", clicked.toDateString())
                                    clipProcess.running = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}