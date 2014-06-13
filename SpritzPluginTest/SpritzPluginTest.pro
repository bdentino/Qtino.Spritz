TEMPLATE = app

QT += qml quick

SOURCES += main.cpp

RESOURCES += qml.qrc

OTHER_FILES += main.qml \
    SpritzKeys.js

ios {
    QMAKE_LFLAGS += -F/Users/bdentino/SpritzSDK-1.0 \
                    -F/System/Library/Frameworks

    LIBS += -framework SpritzSDK -framework AudioToolbox -framework CoreData -framework UIKit

    spritzBundle.files += /Users/bdentino/SpritzSDK-1.0/SpritzSDK.bundle
    QMAKE_BUNDLE_DATA += spritzBundle
}


# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

