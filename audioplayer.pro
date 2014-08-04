QT += quick

TEMPLATE = app
TARGET = audioplayer
DESTDIR = ../bin

SOURCES = \
    main.cpp

OTHER_FILES += \
    qml/main.qml

RESOURCES += \
    audioplayer.qrc

RC_ICONS = images/audioplayer.ico