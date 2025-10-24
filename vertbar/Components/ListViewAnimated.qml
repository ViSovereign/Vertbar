import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 200  // Default width for vertical bar, can be overridden
    height: 400 // Default height, adjust as needed

    // Expose properties for customization
    property alias model: listView.model
    property Component delegate: defaultDelegate

    ListView {
        id: listView
        anchors.fill: parent
        orientation: ListView.Vertical
        spacing: 5
        clip: true

        // Default delegate with animations
        Component {
            id: defaultDelegate
            Rectangle {
                width: listView.width
                height: 50
                color: mouseArea.containsMouse ? "#d3d3d3" : "#f0f0f0"  // Hover color change
                radius: 5

                Text {
                    anchors.centerIn: parent
                    text: model.text || "Item " + index  // Assuming model has 'text' or fallback
                    font.pixelSize: 16
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        // Hover enter animation
                        hoverAnimation.start();
                    }

                    onExited: {
                        // Exit animation
                        exitAnimation.start();
                    }

                    onPressed: {
                        // Click press animation
                        pressAnimation.start();
                    }

                    onClicked: {
                        // Handle click (can be customized)
                        console.log("Item clicked: " + index);
                    }
                }

                // Hover enter: scale up slightly
                PropertyAnimation {
                    id: hoverAnimation
                    target: parent
                    property: "scale"
                    to: 1.05
                    duration: 200
                    easing.type: Easing.InOutQuad
                }

                // Exit: scale back
                PropertyAnimation {
                    id: exitAnimation
                    target: parent
                    property: "scale"
                    to: 1.0
                    duration: 200
                    easing.type: Easing.InOutQuad
                }

                // Press: brief color change or scale down
                SequentialAnimation {
                    id: pressAnimation
                    PropertyAnimation {
                        target: parent
                        property: "scale"
                        to: 0.95
                        duration: 100
                    }
                    PropertyAnimation {
                        target: parent
                        property: "scale"
                        to: 1.0
                        duration: 100
                    }
                }

                // Smooth transitions for color changes
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
        }
    }
}