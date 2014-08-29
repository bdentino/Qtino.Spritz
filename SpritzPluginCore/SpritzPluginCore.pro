# Include Environment-Specific Definitions File.
# Must include the following variables:
#   SPRITZ_HOME = xxx
#
# This file is not included in git. You need
# to create it locally in $$PWD before you can build.
PRE_TARGETDEPS += $$PWD/SpritzPluginBuildEnv.pri
include($$PWD/SpritzPluginBuildEnv.pri)

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

unix: { libprefix = lib }
win32: { libprefix = }

CONFIG(static, static|shared) {
    macx|ios|unix: { libsuffix = a }
    win32: { libsuffix = lib }
}
else {
    macx: { libsuffix = dylib }
    unix:!macx: { libsuffix = so }
    win32: { libsuffix = lib }
}

cleanTarget.files +=
cleanTarget.path += $$installPath
macx|ios|unix: cleanTarget.extra = rm -rf $$installPath/*.qml $$installPath/qmldir $$installPath/plugins.qmltypes $$installPath/$$libprefix$$TARGET$${qtPlatformTargetSuffix}.$$libsuffix

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

    QMAKE_LFLAGS += -F$${SPRITZ_HOME} \
                    -F/System/Library/Frameworks

    LIBS += -framework SpritzSDK -framework AudioToolbox -framework CoreData -framework UIKit
    INCLUDEPATH += $${SPRITZ_HOME}/SpritzSDK.framework/Headers/

    qmls.files += $$PWD/SpritzWidget.qml
    spritzBundle.files += $${SPRITZ_HOME}/SpritzSDK.bundle
    QMAKE_BUNDLE_DATA += spritzBundle

    spritzImages.files += $$PWD/iOS/poweredbyspritz.png

    installPath = $$[QT_INSTALL_QML]/$$replace(uri, \\., /)
    qmldir.path = $$installPath
    target.path = $$installPath
    qmls.path += $$installPath
    spritzImages.path = $$installPath

    INSTALLS += cleanTarget target qmldir spritzImages qmls
}

macx {
    qmls.files = $$PWD/OSX/SpritzView.qml $$PWD/OSX/Spritz.qrc

    installPath = $$[QT_INSTALL_QML]/$$replace(uri, \\., /)
    qmldir.path = $$installPath
    target.path = $$installPath
    qmls.path = $$installPath

    INSTALLS += cleanTarget qmldir qmls

    RESOURCES += \
        $$PWD/OSX/*.qrc

    OTHER_FILES += \
        $$PWD/OSX/qmldir \
        $$PWD/OSX/*.qml
}

QMAKE_POST_LINK = make install
