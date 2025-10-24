import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtCore
import qs
import qs.vertbar.Components
import qs.vertbar.Popups


// The blurry rectangle
PanelWindow {
    id: blurpanel

    Settings {
        id: settings
        property string useThisDisplay: "DP-2"
    }

    // Set the screen (DP-1 or DP-2)
    screen: Quickshell.screens.find(screen => screen.name === "DP-2")

    // Set layer name for Hyprland blur effects
    WlrLayershell.namespace: "quickshell:bar:blur"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Make the panel window itself transparent
    color: "transparent"

    // Panel configuration - span full side
    anchors {
        top: true
        right: true
        bottom: true
    }

    implicitWidth: 0

    SequentialAnimation {
        id: loadingA
        running: true

        // animates drawing the bar itself
        NumberAnimation { target: blurpanel; property: "implicitWidth"; to: 50; duration: 1000; easing.type: Easing.InOutQuad }
        PauseAnimation { duration: 250 }
        NumberAnimation { target: vertbar; property: "border.width"; to: 2; duration: 500; easing.type: Easing.InOutQuad }
        PauseAnimation { duration: 250 }

        NumberAnimation { targets: [dateDisplay, weatherDisplay]; property: "opacity"; to: 1; duration: 350; easing.type: Easing.InOutQuad }
        PauseAnimation { duration: 250 }

        NumberAnimation { targets: [gpuDisplay, micDisplay]; property: "opacity"; to: 1; duration: 500; easing.type: Easing.InOutQuad }
        NumberAnimation { targets: [cpuDisplay, workspaceDisplay]; property: "opacity"; to: 1; duration: 500; easing.type: Easing.InOutQuad }
    }

    SequentialAnimation {
        id: loadingB
        running: true

        // pauses to let the bar animate
        PauseAnimation { duration: 1750 }

        NumberAnimation { targets: [timeDisplay]; property: "opacity"; to: 1; duration: 350; easing.type: Easing.InOutQuad }
        PauseAnimation { duration: 250 }

        NumberAnimation { targets: [diskDisplay, volumeDisplay]; property: "opacity"; to: 1; duration: 500; easing.type: Easing.InOutQuad }
        NumberAnimation { targets: [memDisplay, updatesDisplay]; property: "opacity"; to: 1; duration: 500; easing.type: Easing.InOutQuad }
    }

    // Push bar away from edges, matches what Hyprland does bewteen windows
    margins {
        top: 10
        left: 0
        right: 10
        bottom: 10
    }

    // Volume popup when volume change occurs
    VolumePopup {
        id: volumePopup
    }

    // Workspace popup when user changes workspaces
    WorkspacesPopup {
        id: workspacePopup
    }

    // The actual colored bar
    Rectangle {
        id: vertbar
        anchors.fill: parent
        color: Matugen.colors.background
        opacity: 0.75
        radius: 10
        border.color: Matugen.colors.surface_dim
        border.width: 0

        Component.onCompleted: {
            //loading.start()
        }

        //// Top of VertBar
        ColumnLayout {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }

            Layout.alignment: Qt.AlignHCenter

            CPUDisplay {
                id: cpuDisplay
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 10
                opacity: 0.0
            }

            //CPUMEMDisplay {
            //    id: cpumemDisplay
            //    Layout.alignment: Qt.AlignHCenter
            //}

            MEMDisplay {
                id: memDisplay
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 5
                opacity: 0.0
            }

            GPUDisplay {
                id: gpuDisplay
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 5
                opacity: 0.0
            }

             DisksDisplayAnimate {
                id: diskDisplay
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 5
                onDirectoryRequested: directoryPopup.toggle()
                opacity: 0.0
            }

            DirectoryPopup { id: directoryPopup }

        }// END OF TOP


        //// Middle of VertBar
        ColumnLayout {
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }

            DateDisplay {
                id: dateDisplay
                Layout.alignment: Qt.AlignHCenter
                onCalendarRequested: calendarPopup.toggle()
                opacity: 0.0
                Layout.bottomMargin: 5
            }

            TimeDisplay {
                id: timeDisplay
                Layout.alignment: Qt.AlignVCenter
                opacity: 0.0
            }

            WeatherDisplay {
                id: weatherDisplay
                Layout.alignment: Qt.AlignHCenter
                opacity: 0.0
            }

            CalendarPopup { id: calendarPopup }

        }// END OF MIDDLE

        //// Bottom of VertBar
        ColumnLayout {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            Layout.alignment: Qt.AlignHCenter

            VolumeDisplay {
                id: volumeDisplay
                onOpenMixerRequested: mixerPopup.toggle()
                barWidth: vertbar.width
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 5
                opacity: 0.0
            }

            MicDisplay {
                id: micDisplay
                barWidth: vertbar.width
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 5
                opacity: 0.0
            }

            UpdatesDisplay {
                id: updatesDisplay
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 5
                opacity: 0.0
            }

            WorkspaceDisplay {
                id: workspaceDisplay
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 10
                opacity: 0.0
            }

            MixerPopup { id: mixerPopup }

        }// END OF BOTTOM
    }
}
