import QtQuick 2.2
import QtQuick.Window 2.1
import Qtino.Spritz 1.2
import "SpritzKeys.js" as SpritzKeys

Window {
    id: window
    visible: true
    width: 360
    height: 360
    opacity: 0.3

    property string spritzText: "Money causes teenagers to feel stress. It makes them feel bad about themselves and envy other people. My friend, for instance, lives with her family and has to share a room with her sister, who is very cute and intelligent. This girl wishes she could have her own room and have a lot of stuff, but she can’t have these things because her family doesn’t have much money. Her family’s income is pretty low because her father is old and doesn’t go to work. Her sister is the only one who works. Because her family can’t buy her the things she wants, she feels a lot of stress and gets angry sometimes. Once, she wanted a beautiful dress to wear to a sweetheart dance. She asked her sister for some money to buy the dress. She was disappointed because her sister didn’t have money to give her. She sat in silence for a little while and then started yelling out loud. She said her friends got anything they wanted but she didn’t. Then she felt sorry for herself and asked why she was born into a poor family. Not having money has caused this girl to think negatively about herself and her family. It has caused a lot of stress in her life."
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
        onProgressChanged: { console.log("progress", progress); }

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
    }

    SequentialAnimation {
        id: fader
        PropertyAnimation { target: spritzView; property: 'opacity'; from: 1; to: 0; duration: 5000 }
        PropertyAnimation { target: spritzView; property: 'opacity'; from: 0; to: 1; duration: 5000 }
        loops: Animation.Infinite
    }
    Component.onCompleted: fader.start();
}
