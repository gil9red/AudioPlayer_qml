import QtQuick 2.1
import QtQuick.Window 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.0
import QtMultimedia 5.0
import QtWinExtras 1.0 as Win


Window {
    id: window
    title: mediaPlayer.title ? mediaPlayer.title : applicationTitle
    width: 400
    height: 220

//    // Цвет окна: в данном случае окно прозрачно
//    //! [color]
//    color: dwm.compositionEnabled ? "transparent" : dwm.realColorizationColor
//    //! [color]

//    // Полупрозрачность окнаr
//    //! [dwm]
//    Win.DwmFeatures {
//        id: dwm
//        topGlassMargin: -1
//        leftGlassMargin: -1
//        rightGlassMargin: -1
//        bottomGlassMargin: -1
//    }
//    //! [dwm]

//    // Кнопка и прогресс-бар на иконке программы на панели задач
//    //! [taskbar]
//    Win.TaskbarButton {
//        id: taskbar

//        progress.value: mediaPlayer.position
//        progress.maximum: mediaPlayer.duration
//        progress.visible: mediaPlayer.hasAudio
//        progress.paused: mediaPlayer.playbackState === MediaPlayer.PausedState

//        overlay.iconSource: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "play-32.png" :
//                                                                                     mediaPlayer.playbackState === MediaPlayer.PausedState ? "pause-32.png" : "stop-32.png"
//    }
//    //! [taskbar]

//    // Кнопки управления воспроизведением на всплывающей панели кнопки панели задач
//    //! [thumbbar]
//    Win.ThumbnailToolBar {
//        id: thumbbar

//        Win.ThumbnailToolButton {
//            tooltip: qsTr("Rewind")
//            iconSource: "backward-32.png"

//            enabled: mediaPlayer.position > 0
//            onClicked: mediaPlayer.seek(mediaPlayer.position - mediaPlayer.duration / 10)
//        }

//        Win.ThumbnailToolButton {
//            tooltip: mediaPlayer.playbackState === MediaPlayer.PlayingState ? qsTr("Pause") : qsTr("Play")
//            iconSource: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "pause-32.png" : "play-32.png"

//            enabled: mediaPlayer.hasAudio
//            onClicked: mediaPlayer.playbackState === MediaPlayer.PlayingState ? mediaPlayer.pause() : mediaPlayer.play()
//        }

//        Win.ThumbnailToolButton {
//            tooltip: qsTr("Fast forward")
//            iconSource: "forward-32.png"

//            enabled: mediaPlayer.position < mediaPlayer.duration
//            onClicked: mediaPlayer.seek(mediaPlayer.position + mediaPlayer.duration / 10)
//        }

//        Win.ThumbnailToolButton {
//            tooltip: qsTr("Stop")
//            iconSource: "stop-32.png"

//            enabled: mediaPlayer.playbackState === MediaPlayer.PlayingState
//            onClicked: mediaPlayer.stop()
//        }
//    }
//    //! [thumbbar]

    MediaPlayer {
        id: mediaPlayer
        autoPlay: true
        source : url
        readonly property string title: !!metaData.author && !!metaData.title
                                        ? qsTr("%1 - %2").arg(metaData.author).arg(metaData.title)
                                        : metaData.author || metaData.title || source

        function iconFromVolume() {
            var muteIcon = "mute-16.png"
            if (mediaPlayer.muted === true)
                return muteIcon
            else {
                if (mediaPlayer.volume === 0.0)
                    return muteIcon

                var volume = mediaPlayer.volume
                if (volume > 0.0 & volume < 0.33)
                    return "volume-1-16.png"

                else if (volume >= 0.33 && volume < 0.66)
                    return "volume-2-16.png"

                else if (volume >= 0.66)
                    return "volume-3-16.png"
            }

            return muteIcon
        }
    }

    ColumnLayout {
        id: column

        anchors.margins: 9
        anchors.fill: parent

        Label {
            id: infoLabel

            elide: Qt.ElideLeft
            verticalAlignment: Qt.AlignVCenter
            text: mediaPlayer.errorString || mediaPlayer.title
            Layout.minimumHeight: infoLabel.implicitHeight
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        RowLayout {
            id: row

            ToolButton {
                id: playPauseButton
                enabled: mediaPlayer.hasAudio || playlistView.currentItem
                Layout.preferredWidth: playPauseButton.implicitHeight
                iconSource: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "pause-16.png" : "play-16.png"
                onClicked: {
                    if (mediaPlayer.playbackState === MediaPlayer.PlayingState)
                        mediaPlayer.pause()
                    else if (mediaPlayer.playbackState === MediaPlayer.StoppedState) {
                        var index = playlistView.currentIndex
                        var path = playlistModel.get(index)["path"]
                        mediaPlayer.source = path
                    } else
                        mediaPlayer.play()
                }
            }
            ToolButton {
                id: stopButton
                enabled: mediaPlayer.hasAudio
                Layout.preferredWidth: stopButton.implicitHeight
                iconSource: "stop-16.png"
                onClicked: mediaPlayer.stop()
            }
            ToolButton {
                tooltip: qsTr("Rewind")
                iconSource: "backward-16.png"
                enabled: mediaPlayer.position > 0
                onClicked: mediaPlayer.seek(mediaPlayer.position - mediaPlayer.duration / 10)
            }
            ToolButton {
                tooltip: qsTr("Fast forward")
                iconSource: "forward-16.png"
                enabled: mediaPlayer.position < mediaPlayer.duration
                onClicked: mediaPlayer.seek(mediaPlayer.position + mediaPlayer.duration / 10)
            }
            ToolButton {
                tooltip: qsTr("Previous")
                iconSource: "previous-16.png"
                enabled: playlistView.currentIndex > 0
                onClicked: {
                    playlistView.currentIndex--
                    var index = playlistView.currentIndex
                    var path = playlistModel.get(index)["path"]
                    mediaPlayer.source = path
                }
            }
            ToolButton {
                tooltip: qsTr("Next")
                iconSource: "next-16.png"
                enabled: playlistView.currentIndex < playlistView.count - 1
                onClicked: {
                    playlistView.currentIndex++
                    var index = playlistView.currentIndex
                    var path = playlistModel.get(index)["path"]
                    mediaPlayer.source = path
                }
            }
            Slider {
                id: positionSlider
                enabled: mediaPlayer.hasAudio
                Layout.minimumWidth: 75
                Layout.fillWidth: true                
                maximumValue: mediaPlayer.duration

                property bool sync: false

                onValueChanged: {
                    if (!sync)
                        mediaPlayer.seek(value)
                }

                Connections {
                    target: mediaPlayer
                    onPositionChanged: {
                        positionSlider.sync = true
                        positionSlider.value = mediaPlayer.position
                        positionSlider.sync = false
                    }
                }
            }

            Label {
                id: positionLabel

                // Текущее
                readonly property int minutes: Math.floor(mediaPlayer.position / 60000)
                readonly property int seconds: Math.round((mediaPlayer.position % 60000) / 1000)

                // Длительность в минута и секундах
                readonly property int durationMinutes: Math.floor(mediaPlayer.duration / 60000)
                readonly property int durationSeconds: Math.round((mediaPlayer.duration % 60000) / 1000)



                text: {
                    var formatTime = function(date) {
                        return Qt.formatTime(date, qsTr("mm:ss"))
                    }
                    var currentTime = formatTime(new Date(0, 0, 0, 0, minutes, seconds))
                    var durationTime = formatTime(new Date(0, 0, 0, 0, durationMinutes, durationSeconds))
                    return currentTime + "/" + durationTime
                }
            }

            Slider {
                id: volumeSlider
                minimumValue: 0.0
                maximumValue: 1.0
                value: 1.0
                stepSize: 0.01
                implicitWidth: 50

                property bool sync: false

                onValueChanged: {
                    if (!sync) {
                        mediaPlayer.volume = value
                        muteButton.iconSource = mediaPlayer.iconFromVolume()
                    }
                }

                Connections {
                    target: mediaPlayer
                    onPositionChanged: {
                        positionSlider.sync = true
                        positionSlider.value = mediaPlayer.volume
                        positionSlider.sync = false
                    }
                }
            }

            ToolButton {
                id : muteButton
                Layout.preferredWidth: muteButton.implicitHeight
                checkable: true
                checked: mediaPlayer.muted
                iconSource: mediaPlayer.iconFromVolume()
                onCheckedChanged: {
                    mediaPlayer.muted = checked
                    iconSource = mediaPlayer.iconFromVolume()
                }
            }
        }

        ColumnLayout {
            id : playlist

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                flickableItem.interactive: true

                ListView {
                    id: playlistView
                    anchors.fill: parent
                    model: playlistModel
                    delegate: playlistDelegate
//                    delegate: PlaylistDelegate {  }
                    highlight: playlistHighlight
                }
            }

            RowLayout {
                ToolButton {
                    text: qsTr("Add music files")
                    iconSource: "plus-16.png"
                    onClicked: addingMusicDialog.open()

                    FileDialog {
                        id: addingMusicDialog
                        folder : musicUrl
                        title: qsTr("Open audio files")
                        nameFilters: [qsTr("MP3 files (*.mp3)"), qsTr("All files (*.*)")]
                        selectMultiple: true
                        onAccepted: {
                            var file_protocol = "file:///"
                            for (var i = 0; i < fileUrls.length; i++) {
                                var path = fileUrls[i].toString()
                                path = path.substring(file_protocol.length, path.length)
                                playlistModel.append( { "path" : path, } )
                            }
                        }
                    }
                }
                ToolButton {
                    text: "Remove file from playlist"
                    iconSource: "minus-16.png"
                    onClicked: playlistModel.remove(playlistView.currentIndex)
                }
                ToolButton {
                    text: "Clear playlist"
                    iconSource: "cross-16.png"
                    onClicked: playlistModel.clear()
                }
            }

            Component {
                id: playlistDelegate

                Item {
                    width: parent.width
                    height: 30

                    Rectangle {
                        id : rectItem
                        anchors.fill: parent
                        color: "#33000000"
                        radius: 5
                        visible: mouse.pressed
                    }

                    Text {
                        x: 10
                        y: 10
                        text: path
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        onClicked: playlistView.currentIndex = index
                        onDoubleClicked: mediaPlayer.source = path
                    }
                }
            }
            Component {
                id: playlistHighlight
                Rectangle {
                    color: "gray"
                    radius: 5
                    y: playlistView.currentItem.y
                    Behavior on y {
                        SpringAnimation {
                            spring: 3
                            damping: 0.2
                        }
                    }
                }
            }
            ListModel {
                id: playlistModel
            }
        }
    }
}
