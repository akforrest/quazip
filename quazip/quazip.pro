TEMPLATE = lib
CONFIG += qt warn_on
QT -= gui
!win32:VERSION = 1.0.0

DEFINES += QUAZIP_BUILD
CONFIG(staticlib): DEFINES += QUAZIP_STATIC

include(qtcompilercheck.pri)

# Input
include(quazip.pri)

ZLIB_ROOT = $$_PRO_FILE_PWD_/zlib
INCLUDEPATH += $${ZLIB_ROOT}/include

message(ZLIB ROOT $${ZLIB_ROOT})

win32-msvc* {
    message("Linking local zlib")

    DEFINES += ZLIB_WINAPI

    MSVC_VER = $$(VisualStudioVersion)

    equals(MSVC_VER, 14.0) {
        LIBS += -llegacy_stdio_definitions
    }

    CONFIG(release, debug|release) {

        contains(QMAKE_TARGET.arch, x86_64) {
            LIBS += -L$${ZLIB_ROOT}/lib64/release
        }
        else {
            LIBS += -L$${ZLIB_ROOT}/lib32/release
            QMAKE_LFLAGS += /NODEFAULTLIB:libcmt.lib
        }

        #QMAKE_LFLAGS += /NODEFAULTLIB:libcmt.lib /NODEFAULTLIB:libmsvcrt.lib
    }
    CONFIG(debug, debug|release) {

        contains(QMAKE_TARGET.arch, x86_64) {
            LIBS += -L$${ZLIB_ROOT}/lib64/debug
        }
        else {
            LIBS += -L$${ZLIB_ROOT}/lib32/debug
        }

        QMAKE_LFLAGS += /VERBOSE:LIB
        #QMAKE_LFLAGS += /NODEFAULTLIB:libcmtd.lib /NODEFAULTLIB:libmsvcrtd.lib
    }

    LIBS += -lzlibwapi
}
else {
    LIBS += -lz
}

android {
    message("Building QuaZIP for Android")

    CONFIG += staticlib
}
else {
    unix:!symbian {
        message("Building QuaZIP for Unix")
    }
}

win32 {
    message("Building QuaZIP for Win32")

    # workaround for qdatetime.h macro bug
    DEFINES += NOMINMAX
}

macx {
    message("Building QuaZIP for MacX")
}

ios {
    message("Building QuaZIP for iOS")
    #CONFIG += staticlib
}

symbian {
    message("Building QuaZIP for Symbian")

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

message(Destination: $${DESTDIR})

headers.path=$$_PRO_FILE_PWD_/include
headers.files=$$HEADERS
INSTALLS += headers
