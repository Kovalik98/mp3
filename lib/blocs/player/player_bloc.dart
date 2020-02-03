import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

import 'package:audioplayers/audioplayers.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {

  //Обеспечивает работу плеера: отображение текущего времени воспроизведения, возможность навигации по треку, включения повтора

  PlayerBloc(AudioPlayer audioPlayer) : _audioPlayer = audioPlayer;

  final AudioPlayer _audioPlayer;
  Duration _duration = Duration(seconds: 0);
  Duration _position = Duration(seconds: 0);

  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  ReleaseMode _releaseMode;

  get _durationText => _duration?.toString()?.split('.')?.first ?? '';

  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  get _differenceText =>
      (_duration - _position).toString()?.split('.')?.first ?? '';


  @override
  PlayerState get initialState => InitialPlayerState();

  @override
  Stream<PlayerState> mapEventToState(
    PlayerEvent event,
  ) async* {
    if (event is PlayerInitialize) {
      yield* _mapPlayerInitializeToState();
    } else if (event is UpdatePlayer) {
      yield PlayerPlaying(
          duration: _duration.inMilliseconds,
          position: _position.inMilliseconds,
          sliderPosition: _position.inMilliseconds/_duration.inMilliseconds,
          durationText: _durationText,
          positionText: _positionText,
          differenceText: _differenceText,
          releaseMode: _releaseMode);
    } else if (event is PlayerSeekPosition) {
      yield* _mapPlayerSeekPositionToState(event.sliderPosition);
    } else if (event is PlayerChangeReleaseMode) {
      yield* _mapPlayerChangeReleaseModeToState();
    } else if (event is StopPlayer) {
      yield* _mapStopPlayerToState();
    }
  }

  Stream<PlayerState> _mapPlayerChangeReleaseModeToState() async* {
    if (_releaseMode == ReleaseMode.RELEASE) {
      _releaseMode = ReleaseMode.LOOP;
      _audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    } else {
      _releaseMode = ReleaseMode.RELEASE;
      _audioPlayer.setReleaseMode(ReleaseMode.RELEASE);
    }
  }

  Stream<PlayerState> _mapPlayerSeekPositionToState(double sliderPosition) async* {
    double position = sliderPosition * _duration.inMilliseconds;
    _audioPlayer.seek(Duration(milliseconds: position.round()));
  }

  Stream<PlayerState> _mapStopPlayerToState() async* {
    _releaseMode = ReleaseMode.RELEASE;
    _audioPlayer.setReleaseMode(ReleaseMode.RELEASE);
    yield PlayerStopped();
  }

  Stream<PlayerState> _mapPlayerInitializeToState() async* {
    _releaseMode = ReleaseMode.RELEASE;

    _audioPlayer.onDurationChanged.listen((duration) {
      //print('duration: $_duration');
      _duration = duration;
      add(UpdatePlayer());
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((position) {
      _position = position;
      add(UpdatePlayer());
    });

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _position = _duration;
      _audioPlayer.stop();
      add(StopPlayer());
     // add(ChangePlayer());
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      _duration = Duration(seconds: 0);
      _position = Duration(seconds: 0);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      //print('Player state changed');
      if (state.index == 0) {
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
        add(StopPlayer());
      } else if (state.index == 1) {
        add(UpdatePlayer());
      }
    });

    yield PlayerStopped();
  }


  @override
  Future<void> close() {
    _audioPlayer.stop();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    return super.close();
  }
}
