import QtQuick 2.0

Rectangle {
    id: spritzContainer

    property string content: "blah blah blah"
    property int wordsPerMinute: 250
    property alias running: sequencer.running
    property bool collapsible: true

    function reset() {
        sequencer.currentIndex = 0;
    }

    state: 'opened'
    color: 'transparent'

    implicitWidth: 300
    implicitHeight: width / 3

    Rectangle {
        id: topBorderLeft
        anchors {
            left: parent.left; leftMargin: 5
            right: crosshair.left; rightMargin: 0
            verticalCenter: crosshair.verticalCenter
        }
        height: crosshair.border.width
        radius: height
        color: crosshair.border.color
    }

    Rectangle {
        id: topBorderRight
        anchors {
            left: crosshair.right; leftMargin: 0
            right: parent.right; rightMargin: 5
            verticalCenter: crosshair.verticalCenter
        }
        height: crosshair.border.width
        radius: height
        color: crosshair.border.color
    }

    Rectangle {
        id: crosshair

        property int collapsedHeight

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: parent.width * -0.15
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -parent.height / 2 + crosshair.height
        height: parent.width * 0.05
        width: height
        radius: height / 2
        border.color: 'grey'
        border.width: 2
        color: crosshairButton.pressed ? 'lightgrey' : 'transparent'

        MouseArea {
            id: crosshairButton
            anchors.fill: parent
            anchors.margins: -parent.height / 3
            enabled: spritzContainer.collapsible
            onClicked: spritzContainer.state === 'opened'
                       ? spritzContainer.state = 'closed'
                       : spritzContainer.state = 'opened'
        }

        Rectangle {
            id: centerLine
            anchors.centerIn: parent
            height: parent.height * 1.3
            width: parent.border.width
            color: parent.border.color
            radius: width
        }

        onHeightChanged: {
            if (stateTransition.running) return;
            collapsedHeight = height
        }
    }

    states: [
        State {
            name: 'closed'
            PropertyChanges { target: centerLine; rotation: -90 }
            PropertyChanges { target: crosshair; anchors.horizontalCenterOffset: 0; height: collapsedHeight; width: collapsedHeight; }
            PropertyChanges { target: spritzContainer; height: 2 * crosshair.collapsedHeight; width: 2 * crosshair.collapsedHeight; }
            PropertyChanges { target: bottomBorder; opacity: 0; }
            PropertyChanges { target: currentWordIndexText; opacity: 0; }
            PropertyChanges { target: leftText; opacity: 0; }
            PropertyChanges { target: centerCharacter; opacity: 0; }
            PropertyChanges { target: rightText; opacity: 0; }
            AnchorChanges { target: bottomBorder; anchors.verticalCenter: crosshair.verticalCenter; anchors.bottom: undefined; }
        }
    ]

    transitions: [
        Transition {
            id: stateTransition
            AnchorAnimation { duration: 400 }
            NumberAnimation { properties: 'opacity, height, width'; duration: 400; }
            NumberAnimation { property: 'anchors.horizontalCenterOffset'; duration: 400; }
            NumberAnimation { property: 'rotation'; duration: 400; }
        }
    ]

    Text {
        id: leftText
        color: '#333'
        anchors.verticalCenter: centerCharacter.verticalCenter
        anchors.right: centerCharacter.left
        anchors.rightMargin: 3
        text: typeof(sequencer.currentWord) === 'undefined' ? '' : sequencer.currentWord.start

        font.pixelSize: centerCharacter.font.pixelSize
        font.family: centerCharacter.font.family
    }

    Text {
        id: centerCharacter
        color: 'red'
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: crosshair.horizontalCenter
        text: typeof(sequencer.currentWord) === 'undefined' ? '' : sequencer.currentWord.middle
        width: Text.paintedWidth
        height: Text.paintedHeight

        font.pixelSize: parent.height * 0.25
        font.family: "Courier"
    }

    Text {
        id: rightText
        color: leftText.color
        anchors.verticalCenter: centerCharacter.verticalCenter
        anchors.left: centerCharacter.right
        anchors.leftMargin: leftText.anchors.rightMargin
        text: typeof(sequencer.currentWord) === 'undefined' ? '' : sequencer.currentWord.end

        font.pixelSize: centerCharacter.font.pixelSize
        font.family: centerCharacter.font.family
    }

    Text {
        id: currentWordIndexText
        color: 'black'
        anchors.right: bottomBorder.right
        anchors.bottom: bottomBorder.top
        font.family: "GE Inspira"
        font.pointSize: 12
        opacity: 0.5
        text: sequencer.currentIndex
    }

    Rectangle {
        id: bottomBorder
        anchors {
            left: parent.left; leftMargin: 5
            right: parent.right; rightMargin: 5
            bottom: parent.bottom; bottomMargin: crosshair.height
            verticalCenter: undefined
        }
        height: crosshair.border.width
        radius: height
        color: crosshair.border.color
    }

    Timer {
        id: sequencer

        property int currentIndex: 0
        readonly property var spritzedWords: spritzer.spritzify(spritzContainer.content)
        readonly property var currentWord: typeof(spritzedWords) === 'undefined'
                                           ? { "start": "", "middle": "\u2022", "end": "" }
        : spritzedWords[currentIndex]

        interval: 60000 / spritzContainer.wordsPerMinute
        onTriggered: {
            if (currentIndex === spritzedWords.length - 1) { running = false; return; }
            currentIndex = (currentIndex + 1) % spritzedWords.length;
        }
        repeat: true
        running: false

        onSpritzedWordsChanged: {
            if (typeof(spritzedWords) === 'undefined') return;

            currentIndex = 0
            if (typeof(spritzedWords[currentIndex]) === 'undefined') return;

            while(spritzedWords[currentIndex].middle.trim() === '')
                currentIndex++
        }
    }

    Item {
        id: spritzer

        function spritzify(input) {
            input = input.trim();
            input = input.replace(/\s+/g, ' ');

            // Make sure punctuation is apprpriately spaced.
            input = input.replace(/\./g, '. ');
            input = input.replace(/\?/g, '? ');
            input = input.replace(/\!/g, '! ');

            // Split on any spaces.
            var all_words = input.split(/\s+/);

            // The reader won't stop if the selection starts or ends with spaces
            if (all_words[0] === "")
            {
                all_words = all_words.slice(1, all_words.length);
            }

            if (all_words[all_words.length - 1] === "")
            {
                all_words = all_words.slice(0, all_words.length - 1);
            }

            var word = '';
            var result = '';

            // Preprocess words
            var temp_words = all_words.slice(0); // copy Array
            var t = 0;

            for (var i = 0; i < all_words.length; i++) {

                if (all_words[i].indexOf('.') !== -1) {
                    temp_words[t] = all_words[i].replace('.', '\u2022');
                }

                // Double up on long words and words with commas.
                if ((all_words[i].indexOf(',') !== -1 ||
                     all_words[i].indexOf(':') !== -1 ||
                     all_words[i].indexOf('-') !== -1 ||
                     all_words[i].indexOf('(') !== -1 ||
                     all_words[i].length > 8)
                        &&
                        all_words[i].indexOf('.') === -1)
                {
                    temp_words.splice(t+1, 0, all_words[i]);
                    temp_words.splice(t+1, 0, all_words[i]);
                    t++;
                    t++;
                }

                // Add an additional space after punctuation.
                if (all_words[i].indexOf('.') !== -1 ||
                        all_words[i].indexOf('!') !== -1 ||
                        all_words[i].indexOf('?') !== -1 ||
                        all_words[i].indexOf(':') !== -1 ||
                        all_words[i].indexOf(';') !== -1 ||
                        all_words[i].indexOf(')') !== -1 )
                {
                    temp_words.splice(t+1, 0, " ");
                    temp_words.splice(t+1, 0, " ");
                    temp_words.splice(t+1, 0, " ");
                    t++;
                    t++;
                    t++;
                }

                t++;
            }

            all_words = temp_words.slice(0);

            var split_words = []
            for (var i = 0; i < all_words.length; i++) {
                var splitWord = pivot(all_words[i]);
                split_words.push(splitWord);
            }
            return split_words
        }

        function pivot(word){
            var length = word.length;

            var bestLetter = 1;
            switch (length) {
            case 1:
                bestLetter = 1; // first
                break;
            case 2:
            case 3:
            case 4:
            case 5:
                bestLetter = 2; // second
                break;
            case 6:
            case 7:
            case 8:
            case 9:
                bestLetter = 3; // third
                break;
            case 10:
            case 11:
            case 12:
            case 13:
                bestLetter = 4; // fourth
                break;
            default:
                bestLetter = 5; // fifth
            };

            var splitWord = {};

            var startSpace = ' ';
            for (var i = 0; i < (11 - bestLetter); i++) { startSpace += ' '; }
            splitWord.start = word.slice(0, bestLetter-1).replace('.', '\u2022');
            splitWord.middle = word.slice(bestLetter-1,bestLetter).replace('.', '\u2022');

            var endSpace = ' ';
            for (var j = 0; j < (11 - (length - bestLetter)); j++) { endSpace += ' '; }
            splitWord.end = word.slice(bestLetter, length).replace('.', '\u2022');

            return splitWord;
        }
    }
}
