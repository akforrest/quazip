TEMPLATE = lib
CONFIG += qt warn_on
QT -= gui
!win32:VERSION = 1.0.0

DEFINES += QUAZIP_BUILD
CONFIG(staticlib): DEFINES += QUAZIP_STATIC

include(qtcompilercheck.pri)

# Input
include(quazip.pri)

BUILD_PLATFORM = all
BUILD_DIR = $$_PRO_FILE_PWD_

CONFIG(release, debug|release) {
    DRMODE = release
}
CONFIG(debug, debug|release) {
    DRMODE = debug
}

ZLIB_ROOT = $${BUILD_DIR}/zlib
INCLUDEPATH += $${ZLIB_ROOT}/include

win32-msvc* {
    message("Linking local zlib")

    MSVC_VER = $$(VisualStudioVersion)

    equals(MSVC_VER, 14.0){
        #msvc2015
        contains(QMAKE_TARGET.arch, x86_64){
            #64bit
            LIBS += $${ZLIB_ROOT}/msvc2015_64/$${DRMODE}/zlibwapi.lib
        }
        else {
            #32bit
            LIBS += $${ZLIB_ROOT}/msvc2015_32/$${DRMODE}/zlibwapi.lib
        }
    }
    equals(MSVC_VER, 12.0){
        #msvc2013
        contains(QMAKE_TARGET.arch, x86_64){
            #64bit
            LIBS += $${ZLIB_ROOT}/msvc2013_64/$${DRMODE}/zlibwapi.lib
        }
        else {
            #32bit
            LIBS += $${ZLIB_ROOT}/msvc2015_32/$${DRMODE}/zlibwapi.lib
            warning(unsupported compiler version MSVC 2013 32Bit)
        }
    }

    CONFIG(release, debug|release) {
        #QMAKE_CXXFLAGS += /MD
        #QMAKE_LFLAGS += /VERBOSE:LIB
        #QMAKE_LFLAGS += /NODEFAULTLIB:libcmt.lib
    }
    CONFIG(debug, debug|release) {
        #QMAKE_CXXFLAGS += /MDd
        QMAKE_LFLAGS += /VERBOSE:LIB
        #QMAKE_LFLAGS += /NODEFAULTLIB:libcmtd.lib
    }
}
else {
    LIBS += -lz
}

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

ios {
    message("Building QuaZIP for iOS")
    BUILD_PLATFORM = ios
    #CONFIG += staticlib
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

MOC_DIR = $$BUILD_DIR/_generated/_$${BUILD_PLATFORM}_$${DRMODE}_moc/$${QT_VERSION}/$${COMPILER_VERSION}/$$TARGET
OBJECTS_DIR = $$BUILD_DIR/_generated/_$${BUILD_PLATFORM}_$${DRMODE}_obj/$${QT_VERSION}/$${COMPILER_VERSION}/$$TARGET

DESTDIR = $$OUT_PWD/$${QT_VERSION}/$${COMPILER_VERSION}/$${BUILD_PLATFORM}

message(Destination: $${DESTDIR})

headers.path=$$_PRO_FILE_PWD_/include
headers.files=$$HEADERS
INSTALLS += headers
