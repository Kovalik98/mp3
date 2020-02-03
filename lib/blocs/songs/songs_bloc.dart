import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dart_tags/dart_tags.dart';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';

import 'package:mp3/models/song.dart';

enum Actions { setAsRingtone, setAsAlarm, setAsNotification }
enum PageState { Reorderable, Playlist }

class SongsBloc extends Bloc<SongsEvent, SongsState> {

  //Обеспечивет работу виджета со списком песен и управляет воспроизведением:
  //перестановка песен, включение/отключение режима плейлиста, начало и остановка воспроизведения

  //Также управляет установкой выбранной мелодии в качестве рингтона/звонка будильника/оповещения

  SongsBloc(AudioPlayer audioPlayer) : _audioPlayer = audioPlayer;

  AudioPlayer _audioPlayer;
  AudioCache _audioCache;
  String _lastPlayedSong;
  StreamSubscription _playerCompleteSubscription;
  PageState _pageState = PageState.Reorderable;
  String _dialogContent;
  bool _isDialogVisible;

  static const platform = const MethodChannel('mp3.devsteam.mobi/ringtone');

  List<Song> songs = [
    Song('10.mp3', 'О.Torvald', ' Без тебе '),
    Song('11.mp3', 'О.Torvald', 'Вирвана'),
    Song('12.mp3', 'О.Torvald', 'Все це знов'),
    Song('13.mp3', 'О.Torvald', 'Вск Шоколад'),
    Song('14.mp3', 'О.Torvald', 'Два нуль один вісім'),
    Song('15.mp3', 'О.Torvald', 'Десь Не Тут'),
    Song('16.mp3', 'О.Torvaldй', 'Киев днем и ночью'),
    Song('17.mp3', 'О.Torvald', 'Лише у мох снах'),
    Song('18.mp3', 'О.Torvald', 'Ліхтарі'),
    Song('19.mp3', 'О.Torvald', 'Назовні'),
    Song('20.mp3', 'О.Torvald', 'Забери меня'),
  ];

  List<String> songsFilenames = [
    '10.mp3',
    '11.mp3',
    '12.mp3',
    '13.mp3',
    '14.mp3',
    '15.mp3',
    '16.mp3',
    '17.mp3',
    '18.mp3',
    '19.mp3',
    '20.mp3',
  ];

  List<File> files;

  @override
  SongsState get initialState => InitialSongsState();

  @override
  Stream<SongsState> mapEventToState(
    SongsEvent event,
  ) async* {
    print(event.toString());
    if (event is InitializeSongs) {
      yield* _mapInitializeSongsToState();
    } else if (event is UpdateSongs) {
      yield SongsLoading();
      yield* _mapUpdateSongsToState();
      _isDialogVisible = false;
    } else if (event is UpdateSongsOrder) {
      yield* _mapUpdateSongsOrderToState(event.oldIndex, event.newIndex);
    } else if (event is ChangeSongsPlaybackMode) {
      yield* _mapChangeSongsPlaybackModeToState();
    } else if (event is PlaySong) {
      yield* _mapPlaySongToState(event.songIndex);
    } else if (event is Stop) {
      yield* _mapStopToState();
    } else if (event is ExpandSongOptions) {
      yield* _mapExpandSongOptionsToState(event.songIndex);
    } else if (event is SetSongAsRingtone) {
      yield* _setMP3toSystemSound(event.songIndex, Actions.setAsRingtone);
    } else if (event is SetSongAsAlarmSound) {
      yield* _setMP3toSystemSound(event.songIndex, Actions.setAsAlarm);
    } else if (event is SetSongAsNotificationSound) {
      yield* _setMP3toSystemSound(event.songIndex, Actions.setAsNotification);
    }
  }

  Stream<SongsState> _mapUpdateSongsToState() async* {
    bool isPlaying = _audioCache.fixedPlayer.state == AudioPlayerState.PLAYING;
    bool isReorderable = _pageState == PageState.Reorderable;
    int lastPlayedSongIndex;
    for (int i = 0; i < songs.length; i++) {
      if (_lastPlayedSong == songs[i].path) lastPlayedSongIndex = i;
    }

    yield SongsLoaded(
        songs: songs,
        isPlaying: isPlaying,
        isReorderable: isReorderable,
        lastPlayedSongIndex: lastPlayedSongIndex,
        isDialogVisible: _isDialogVisible,
        dialogContent: _dialogContent);
  }

  Stream<SongsState> _mapPlaySongToState(int index) async* {
    await _audioCache.play(songs[index].path).then((v) {
      _lastPlayedSong = songs[index].path;
      add(UpdateSongs());
    });
  }

  Stream<SongsState> _mapStopToState() async* {
    await _audioPlayer.stop().then((v) {
      _lastPlayedSong = 'none';
      add(UpdateSongs());
    });
  }

  Stream<SongsState> _mapChangeSongsPlaybackModeToState() async* {
    if (_pageState == PageState.Reorderable) {
      _pageState = PageState.Playlist;
      _dialogContent = "You can't reorder songs in playlist mode";
    } else {
      _pageState = PageState.Reorderable;
      _dialogContent = "Playlist mode turned off";
    }
    _isDialogVisible = true;
    add(UpdateSongs());
  }

  Stream<SongsState> _mapExpandSongOptionsToState(int index) async* {
    _isDialogVisible = false;
    if (songs[index].isMenuExpanded == true) {
      songs[index].isMenuExpanded = false;
    } else
      songs[index].isMenuExpanded = true;

    add(UpdateSongs());
  }

  Stream<SongsState> _mapUpdateSongsOrderToState(
      int oldIndex, int newIndex) async* {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    print('Updating order: old $oldIndex, new $newIndex');

    Song song = songs.removeAt(oldIndex);
    songs.insert(newIndex, song);

    add(UpdateSongs());
  }

  Stream<SongsState> _mapInitializeSongsToState() async* {
    _audioCache = AudioCache(fixedPlayer: _audioPlayer);

    _isDialogVisible = false;

    files = await _audioCache.loadAll(songsFilenames);

    _playerCompleteSubscription =
        await _audioPlayer.onPlayerCompletion.listen((event) {
      if (_pageState == PageState.Reorderable) {
        print('Playback is reorderable completed');
        add(Stop());
      } else {
        print('Playing next song');
        for (int i = 0; i < songs.length; i++) {
          if (songs[i].path == _lastPlayedSong && i != songs.length - 1) {
            add(PlaySong(songIndex: i + 1));
            break;
          } else if (songs[i].path == _lastPlayedSong &&
              i == songs.length - 1) {
            add(PlaySong(songIndex: 0));
            break;
          }
        }
      }
    });

    add(UpdateSongs());
  }

  Stream<SongsState> _setMP3toSystemSound(index, Actions action) async* {
    print('checking');

    //check for settings write permission
    try {
      await platform
          .invokeMethod("checkPermissionWriteSettings")
          .then((result) {
        if (result == 0) {
          print('Permission for writing setting granted');
        }
      });
    } on PlatformException catch (e) {
      print('Writing settings denied');
      _isDialogVisible = true;
      _dialogContent =
          "You must grant access to settings in order to set this song";
      add(UpdateSongs());
      return;
    }

    //check for storage write permission
    try {
      await platform.invokeMethod("checkPermissionStorage").then((result) {
        if (result == 0) {
          print('Permission for writing storage granted');
        }
      });
    } on PlatformException catch (e) {
      print('Writing storage denied');
      _isDialogVisible = true;
      _dialogContent =
          "You must grant access to storage in order to set this song";
      add(UpdateSongs());
      return;
    }

    Directory downloadsDirectory;

    downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
    print('ringtones: ${downloadsDirectory.path}');

    final filename = songs[index].path;
    var bytes = await rootBundle.load("assets/${songs[index].path}");

    String dir = (await getApplicationDocumentsDirectory()).path;
    print('dir $dir');
    String newPath = ('${downloadsDirectory.path}/$filename');
    print(newPath);

    print('Checking if file exists');
    await File(newPath).exists().then((exists) async {
      print('Check result: $exists');
      if (!exists) {
        print('Trying to write file');
        try {
          final buffer = bytes.buffer;
          File file = await new File(newPath).writeAsBytes(
              buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));

          file.length().then((length) {
            print('Song length: $length');
          });
        } on PlatformException catch (e) {
          print('File write exce: $e');
        }
      }
    });

    if (action == Actions.setAsRingtone) {
      try {
        print('Trying to set ringtone');
        await platform.invokeMethod('setRingtone',
            {"path": newPath, "title": songs[index].title}).then((result) {
          print('Result: $result');
          _dialogContent = 'Song "${songs[index].title}" was set as ringtone';
        });
      } on PlatformException catch (e) {
        print('Ringtone set failed with error: ${e.message}');
        _dialogContent = "Unexpected error";
      }
    } else if (action == Actions.setAsAlarm) {
      try {
        print('Trying to set alarm');
        await platform.invokeMethod('setAlarm',
            {"path": newPath, "title": songs[index].title}).then((result) {
          print('Result: $result');
          _dialogContent =
              'Song "${songs[index].title}" was set as alarm sound';
        });
      } on PlatformException catch (e) {
        print('Alarm set failed with error: ${e.message}');
        _dialogContent = "Unexpected error";
      }
    } else if (action == Actions.setAsNotification) {
      try {
        print('Trying to set notification');
        await platform.invokeMethod('setNotification',
            {"path": newPath, "title": songs[index].title}).then((result) {
          print('Result: $result');
          _dialogContent =
              'Song "${songs[index].title}" was set as notification sound';
        });
      } on PlatformException catch (e) {
        print('Notification set failed with error: ${e.message}');
        _dialogContent = "Unexpected error";
      }
    }

    _isDialogVisible = true;
    add(UpdateSongs());
  }

  @override
  Future<void> close() {
    _playerCompleteSubscription.cancel();
    return super.close();
  }
}
