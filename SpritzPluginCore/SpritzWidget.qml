import QtQuick 2.2
import QtQuick.Layouts 1.1
import TinoUI 1.0

Rectangle {
    id: spritzWidget

    property alias content: reader.content
    property alias wordsPerMinute: reader.wordsPerMinute

    property alias running: reader.running
    state: reader.state

    implicitWidth: 600
    height: width * 0.6

    color: 'transparent'

    SpritzReader {
        id: reader

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            margins: 10
        }
        width: parent.width - 20
    }

    RowLayout {
        id: buttonRow
        anchors{
            top: reader.bottom
            left: reader.left; leftMargin: 10
            right: reader.right; rightMargin: 10
        }

        height: reader.height * 0.5

        layoutDirection: Qt.LeftToRight
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        Repeater {
            model: buttonInfo
            delegate: Item {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 10
                Layout.fillWidth: true

                IconButton {
                    height: parent.height
                    width: height
                    anchors.centerIn: parent
                    defaultIconSource: Qt.resolvedUrl(defaultSource)
                    pressedIconSource: Qt.resolvedUrl(pressedSource)
                    text: label
                    textColor: pressed ? '#6d88a6' : '#555'
                    onClicked: modelData.onClicked()
                }
            }

            property list<QtObject> buttonInfo:  [
                QtObject {
                    property string defaultSource: reader.running ? "icons/pause.svg" : "icons/play.svg"
                    property string pressedSource: reader.running ? "icons/pause_pressed.svg" : "icons/play_pressed.svg"
                    property string label: reader.running ? "pause" : "play"
                    function onClicked() { reader.running = !(reader.running) }
                },
                QtObject {
                    property string defaultSource: "icons/reset.svg"
                    property string pressedSource: "icons/reset_pressed.svg"
                    property string label: "reset"
                    function onClicked() { reader.reset() }
                },
                QtObject {
                    property string defaultSource: "icons/hide.svg"
                    property string pressedSource: "icons/hide_pressed.svg"
                    property string label: "hide"
                    function onClicked() { reader.state = 'closed' }
                }
            ]
        }
    }
}
