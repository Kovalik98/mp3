import 'package:equatable/equatable.dart';

abstract class SongsEvent extends Equatable {
  const SongsEvent();
}

class InitializeSongs extends SongsEvent {
  @override
  List<Object> get props => null;
}

class ChangeSongsPlaybackMode extends SongsEvent {
  @override
  List<Object> get props => null;
}

class PlaySong extends SongsEvent {
  int songIndex;

  PlaySong({this.songIndex});

  @override
  List<Object> get props => null;
}

class Stop extends SongsEvent {
  @override
  List<Object> get props => null;
}

class ExpandSongOptions extends SongsEvent {
  int songIndex;

  ExpandSongOptions({this.songIndex});

  @override
  List<Object> get props => [songIndex];
}

class SetSongAsRingtone extends SongsEvent {
  int songIndex;

  SetSongAsRingtone({this.songIndex});

  @override
  List<Object> get props => null;
}

class SetSongAsAlarmSound extends SongsEvent {
  int songIndex;

  SetSongAsAlarmSound({this.songIndex});

  @override
  List<Object> get props => null;
}

class SetSongAsNotificationSound extends SongsEvent {
  int songIndex;

  SetSongAsNotificationSound({this.songIndex});

  @override
  List<Object> get props => null;
}

class UpdateSongsOrder extends SongsEvent {
  int oldIndex;
  int newIndex;

  UpdateSongsOrder({this.oldIndex, this.newIndex});

  @override
  List<Object> get props => [oldIndex, newIndex];
}

class UpdateSongs extends SongsEvent {
  @override
  List<Object> get props => null;
}
