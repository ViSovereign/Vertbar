import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Notifications

Rectangle {
    id: root
    
    required property Notification notif
    required property NotificationServer backer
    
    color: "transparent"
    radius: 10
    implicitWidth: 375
    implicitHeight: c.implicitHeight

    // Auto-dismiss after 5 seconds
    Timer {
        interval: 5000
        running: true
        onTriggered: backer.closeNotification(notif)
    }
    
    HoverHandler {
        onHoveredChanged: {
            // Pause auto-dismiss on hover
        }
    }
    
    Rectangle {
        id: border
        anchors.fill: parent
        color: "#2d2d2d"
        border.width: 2
        border.color: "#4a90e2"
        radius: root.radius
    }
    
    ColumnLayout {
        id: c
        anchors.fill: parent
        spacing: 0
        
        ColumnLayout {
            Layout.margins: 10
            
            RowLayout {
                Image {
                    visible: source != ""
                    source: notif.appIcon ? Quickshell.iconPath(notif.appIcon) : ""
                    fillMode: Image.PreserveAspectFit
                    antialiasing: true
                    sourceSize.width: 30
                    sourceSize.height: 30
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                }
                
                Label {
                    visible: text != ""
                    text: notif.summary || ""
                    font.pointSize: 14
                    font.bold: true
                    color: "#ffffff"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                MouseArea {
                    id: closeArea
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    
                    hoverEnabled: true
                    onClicked: backer.closeNotification(notif)
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 5
                        radius: width * 0.5
                        antialiasing: true
                        color: "#60ffffff"
                        opacity: closeArea.containsMouse ? 1 : 0
                        
                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: "#000000"
                            font.pixelSize: 16
                        }
                        
                        Behavior on opacity { SmoothedAnimation { velocity: 8 } }
                    }
                }
            }
            
            Label {
                visible: text != ""
                text: notif.body || ""
                wrapMode: Text.Wrap
                color: "#cccccc"
                Layout.fillWidth: true
                Layout.topMargin: 5
            }
        }
    }
}