import 'package:equatable/equatable.dart';
import 'package:audioplayers/audioplayers.dart';

abstract class PlayerState extends Equatable {
  const PlayerState();
}

class InitialPlayerState extends PlayerState {
  @override
  List<Object> get props => [];
}

class PlayerStopped extends PlayerState {
  @override
  // TODO: implement props
  List<Object> get props => null;
}

class PlayerPlaying extends PlayerState {
  int duration;
  int position;
  double sliderPosition;
  String durationText;
  String positionText;
  String differenceText;
  ReleaseMode releaseMode;

  PlayerPlaying({this.duration, this.position, this.sliderPosition, this.durationText,
      this.positionText, this.differenceText, this.releaseMode});

  @override
  List<Object> get props => [
        duration,
        position,
        durationText,
        positionText,
        differenceText,
        releaseMode
      ];
}
