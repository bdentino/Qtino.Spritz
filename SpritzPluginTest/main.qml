import QtQuick 2.2
import QtQuick.Window 2.1
import Spritz 1.0

Window {
    id: window
    visible: true
    width: 360
    height: 360
    opacity: 0.3

    property string spritzText: "Hello this is a test of Qt Spritz Rendering. Hopefully it works!! That would be really exciting!"

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (spritzView.started && spritzView.paused) spritzView.resume();
            else if (spritzView.started && !spritzView.paused) spritzView.pause();
            else if (!spritzView.started) spritzView.spritzText(window.spritzText)
        }
    }
    Rectangle {
        anchors.left: parent.left;
        anchors.verticalCenter: parent.verticalCenter;
        height: 300
        width: parent.width / 2
        color: 'red'
        opacity: 0.5
    }
    SpritzView {
        id: spritzView
        x: 15
        y: 10
        height: 100
        width: parent.width - 30

        SpritzSDK.clientId: "b5de14640f2092af4"
        SpritzSDK.clientSecret: "9feb2738-46bd-4689-af40-330d827eb556"

        Component.onCompleted: { spritzText(window.spritzText); mover.start() }

        MouseArea {
            property int lastX
            property int lastY
            anchors.fill: parent
            onPressed: { console.log("Pressed!"); lastX = mouse.x; lastY = mouse.y }
            onPositionChanged: {
                console.log("Moved!");
                spritzView.x += (mouse.x - lastX);
                spritzView.y += (mouse.y - lastY);
                lastX = mouse.x;
                lastY = mouse.y;
            }
        }

        NumberAnimation { id: mover; target: spritzView; properties: 'y'; from: 15; to: 500; duration: 2000 }
    }
    Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 150
        width: parent.width / 3
        color: 'green'
        opacity: 1
    }
}
