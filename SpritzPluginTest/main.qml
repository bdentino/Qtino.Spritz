import QtQuick 2.2
import QtQuick.Window 2.1
import Qtino.Spritz 1.0
import "SpritzKeys.js" as SpritzKeys

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

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 30

        width: parent.width * 0.9
        height: width * 0.35

        SpritzSDK.clientId: SpritzKeys.clientId
        SpritzSDK.clientSecret: SpritzKeys.clientSecret

        onInitialized: { spritzText(window.spritzText); }

        Rectangle {
            id: overlayRect;
            anchors.centerIn: parent;
            height: parent.height;
            width: parent.width;
            color: 'blue';
            opacity: 0.3
        }
    }
    Rectangle {
        id: greenRect
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 150
        width: parent.width / 3
        color: 'green'
        opacity: 1
        Component.onCompleted: shrinker.start();
    }

    SequentialAnimation {
        id: shrinker
        PropertyAnimation { target: spritzView; property: 'scale'; from: 1; to: 0; duration: 5000 }
        PropertyAnimation { target: spritzView; property: 'scale'; from: 0; to: 1; duration: 5000 }
        loops: Animation.Infinite
    }
}
