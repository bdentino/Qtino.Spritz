TEMPLATE = app

QT += qml quick

SOURCES += main.cpp

RESOURCES += qml.qrc

OTHER_FILES += main.qml \
    SpritzKeys.js

spritz_sdk_version = 1.2

ios {
    QMAKE_LFLAGS += -F/Users/bdentino/SpritzSDK/iOS/$$spritz_sdk_version \
                    -F/System/Library/Frameworks

    LIBS += -framework SpritzSDK -framework AudioToolbox -framework CoreData -framework UIKit

    spritzBundle.files += /Users/bdentino/SpritzSDK/iOS/$$spritz_sdk_version/SpritzSDK.bundle
    QMAKE_BUNDLE_DATA += spritzBundle
}
