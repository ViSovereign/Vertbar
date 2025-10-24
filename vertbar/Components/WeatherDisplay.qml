import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.Services
import qs.Common
import qs

ColumnLayout {
    id: weatherDisplay
    spacing: 2

    property bool showExtra: false

    Ref {
        service: WeatherService
    }

    PropertyAnimation {
        id: hoverAnimation
        property: "scale"
        to: 1.2
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

    Text {
        id: weatherConditionIcon
        text: WeatherService.getWeatherIcon(WeatherService.weather.wCode)
        font.pixelSize: 30
        font.family: "Material Symbols Rounded"
        color: Matugen.colors.on_background
        horizontalAlignment: Text.AlignHCenter
        Layout.alignment: Qt.AlignHCenter
        opacity: 1.0

        Behavior on color {
            ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
        }
    }

    RowLayout {
        id: weatherTempRow
        spacing: 0
        opacity: 1.0

        Text {
            id: weatherTempIcon
            text: "device_thermostat"
            font.pixelSize: 12
            font.family: "Material Symbols Rounded"
            color: Matugen.colors.on_background
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            opacity: 1.0

            Behavior on color {
                ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }
        }

        Text {
            id: weatherTemp
            text: {
                var temp = WeatherService.weather.tempF
                if (temp === undefined || temp === null || temp === 0) {
                    return "--°"
                }
                    return temp + "°"
            }
            color: Matugen.colors.on_background
            font.pixelSize: 12
            font.family: "MesloLGM Nerd Font Propo"
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            opacity: 1.0

            Behavior on color {
                ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }

        }
    }

    RowLayout {
        id: weatherHumidityRow
        spacing: 0
        visible: weatherDisplay.showExtra
        Layout.preferredHeight: weatherDisplay.showExtra ? implicitHeight : 0

        Text {
            id: weatherHumidityIcon
            text: "humidity_percentage"
            font.pixelSize: 12
            font.family: "Material Symbols Rounded"
            color: Matugen.colors.on_background
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            opacity: 1.0

            Behavior on color {
                ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }
        }

        Text {
            id: weatherHumidity
            text: {
                var humidity = WeatherService.weather.humidity
                if (humidity === undefined || humidity === null || humidity === 0) {
                    return "--%"
                }
                    return humidity + "%"
            }
            color: Matugen.colors.on_background
            font.pixelSize: 12
            font.family: "MesloLGM Nerd Font Propo"
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            opacity: 1.0

            Behavior on color {
                ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }

        }

    }

    RowLayout {
        id: weatheruvRow
        spacing: 0
        visible: weatherDisplay.showExtra
        Layout.preferredHeight: weatherDisplay.showExtra ? implicitHeight : 0

        Text {
            id: weatheruvIcon
            text: "eyeglasses_2"
            font.pixelSize: 12
            font.family: "Material Symbols Rounded"
            color: Matugen.colors.on_background
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            opacity: 1.0

            Behavior on color {
                ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }
        }

        Text {
            id: weatheruv
            text: {
                var uv = WeatherService.weather.uv
                if (uv === undefined || uv === null || uv === 0) {
                    return "--%"
                }
                    return uv + "%"
            }
            color: Matugen.colors.on_background
            font.pixelSize: 12
            font.family: "MesloLGM Nerd Font Propo"
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            opacity: 1.0

            Behavior on color {
                ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }

        }

    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        propagateComposedEvents: true

        onClicked: function(event) {
            if (event.button === Qt.LeftButton) {
                //weatherDisplay.showExtra = !weatherDisplay.showExtra
                deepLinkWeather.running = true
            }
        }

        onPressed:  weatherDisplay.scale = 0.90
        onReleased: weatherDisplay.scale = 1.0

        onEntered: {
            weatherTemp.color = Matugen.colors.on_tertiary_container
            weatherHumidityIcon.color = Matugen.colors.on_tertiary_container
            weatheruv.color = Matugen.colors.on_tertiary_container

            weatherConditionIcon.color = Matugen.colors.on_tertiary_container
            weatherTempIcon.color = Matugen.colors.on_tertiary_container
            weatherHumidity.color = Matugen.colors.on_tertiary_container
            weatheruvIcon.color = Matugen.colors.on_tertiary_container

            hoverAnimation.target = weatherDisplay
            hoverAnimation.start();

        }

        onExited: {
            weatherTemp.color = Matugen.colors.on_background
            weatherHumidityIcon.color = Matugen.colors.on_background
            weatheruv.color = Matugen.colors.on_background

            weatherConditionIcon.color = Matugen.colors.on_background
            weatherTempIcon.color = Matugen.colors.on_background
            weatherHumidity.color = Matugen.colors.on_background
            weatheruvIcon.color = Matugen.colors.on_background

            exitAnimation.target = weatherDisplay
            exitAnimation.start();
        }

        // Change the cursor
        cursorShape: Qt.PointingHandCursor

    }

    // Deep Link to Weather Extension in vicinae
    Process {
        id: deepLinkWeather
        command: ["sh", "-c", "vicinae vicinae://extensions/tonka3000@raycast/weather/index"]
    }
}
