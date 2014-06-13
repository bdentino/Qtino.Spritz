TEMPLATE = lib
TARGET = SpritzPlugin
QT += qml quick
CONFIG += qt plugin

#TODO: See if i can get rid of the private header depedencies...
QT += core-private gui-private

TARGET = $$qtLibraryTarget($$TARGET)
uri = Qtino.Spritz

ios { OS = iOS }
macx { OS = OSX }
qmldir.files = $$PWD/$${OS}/qmldir

ios {
    CONFIG += static

    SOURCES += \
        $$PWD/iOS/*.cpp

    HEADERS += \
        $$PWD/iOS/*.h

    OBJECTIVE_SOURCES += \
        $$PWD/iOS/*.mm
    OBJECTIVE_SOURCES -= $$PWD/iOS/SpritzViewPrivate.mm

    RESOURCES += \
        $$PWD/iOS/Spritz.qrc

    OTHER_FILES += \
        $$PWD/iOS/qmldir

    CONFIG += create_prl

    QMAKE_MOC_OPTIONS += -Muri=$$uri

    QMAKE_LFLAGS += -F/Users/bdentino/SpritzSDK-1.0 \
                    -F/System/Library/Frameworks

    LIBS += -framework SpritzSDK -framework AudioToolbox -framework CoreData -framework UIKit
    INCLUDEPATH += /Users/bdentino/SpritzSDK-1.0/SpritzSDK.framework/Headers/

    qmls.files += $$PWD/SpritzWidget.qml
    spritzBundle.files += /Users/bdentino/SpritzSDK-1.0/SpritzSDK.bundle
    QMAKE_BUNDLE_DATA += spritzBundle

    spritzImages.files += $$PWD/iOS/poweredbyspritz.png

    installPath = $$[QT_INSTALL_QML]/$$replace(uri, \\., /)
    qmldir.path = $$installPath
    target.path = $$installPath
    qmls.path += $$installPath
    spritzImages.path = $$installPath

    INSTALLS += target qmldir spritzImages qmls
}

macx {
    qmls.files = $$PWD/OSX/SpritzView.qml $$PWD/OSX/Spritz.qrc

    installPath = $$[QT_INSTALL_QML]/$$replace(uri, \\., /)
    qmldir.path = $$installPath
    target.path = $$installPath
    qmls.path = $$installPath

    INSTALLS += qmldir qmls

    RESOURCES += \
        $$PWD/OSX/*.qrc

    OTHER_FILES += \
        $$PWD/OSX/qmldir \
        $$PWD/OSX/*.qml
}
