TEMPLATE = lib
CONFIG += qt warn_on
QT -= gui
!win32:VERSION = 1.0.0

DEFINES += QUAZIP_BUILD
CONFIG(staticlib): DEFINES += QUAZIP_STATIC

INCLUDEPATH += $$[QT_INSTALL_HEADERS]/QtZlib

# Input
include(quazip.pri)

BUILD_PLATFORM = all

LIBS += -lz

android {
    message("Building QuaZIP for Android")
    BUILD_PLATFORM = android

    CONFIG += staticlib
}
else {
unix:!symbian {
    message("Building QuaZIP for Unix")
    BUILD_PLATFORM = unix
}
}

win32 {
    message("Building QuaZIP for Win32")
    BUILD_PLATFORM = win

    # workaround for qdatetime.h macro bug
    DEFINES += NOMINMAX
}

macx {
    message("Building QuaZIP for MacX")
    BUILD_PLATFORM = macx
}

symbian {
    message("Building QuaZIP for Symbian")
    BUILD_PLATFORM = symbian

    # Note, on Symbian you may run into troubles with LGPL.
    # The point is, if your application uses some version of QuaZip,
    # and a newer binary compatible version of QuaZip is released, then
    # the users of your application must be able to relink it with the
    # new QuaZip version. For example, to take advantage of some QuaZip
    # bug fixes.

    # This is probably best achieved by building QuaZip as a static
    # library and providing linkable object files of your application,
    # so users can relink it.

    CONFIG += debug_and_release

    LIBS += -lezip

    #Export headers to SDK Epoc32/include directory
    exportheaders.sources = $$HEADERS
    exportheaders.path = quazip
    for(header, exportheaders.sources) {
        BLD_INF_RULES.prj_exports += "$$header $$exportheaders.path/$$basename(header)"
    }
}

CONFIG(release, debug|release) {
    DRMODE = _release
}
CONFIG(debug, debug|release) {
    DRMODE = _debug
}

BUILD_DIR = $$_PRO_FILE_PWD_

MOC_DIR = $$BUILD_DIR/_$${BUILD_PLATFORM}$${DRMODE}_moc/$${QT_VERSION}/$$TARGET
OBJECTS_DIR = $$BUILD_DIR/_$${BUILD_PLATFORM}$${DRMODE}_obj/$${QT_VERSION}/$$TARGET

DESTDIR = $$OUT_PWD/$${BUILD_PLATFORM}

headers.path=$$_PRO_FILE_PWD_/include
headers.files=$$HEADERS
INSTALLS += headers
