import 'package:equatable/equatable.dart';
import 'package:mp3/models/song.dart';

abstract class SongsState extends Equatable {
  const SongsState();
}

class InitialSongsState extends SongsState {
  @override
  List<Object> get props => [];
}

class SongsLoading extends SongsState {
  @override
  // TODO: implement props
  List<Object> get props => null;
}

class SongsLoaded extends SongsState {
  bool isPlaying;
  bool isReorderable;
  int lastPlayedSongIndex;
  List<Song> songs;
  bool isDialogVisible;
  String dialogContent;

  SongsLoaded(
      {this.songs,
      this.isPlaying,
      this.lastPlayedSongIndex,
      this.isReorderable,
      this.isDialogVisible,
      this.dialogContent});

  @override
  List<Object> get props => [
        songs,
        isPlaying,
        lastPlayedSongIndex,
        isReorderable,
        isDialogVisible,
        dialogContent
      ];
}
