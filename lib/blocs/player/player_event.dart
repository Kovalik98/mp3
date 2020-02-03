import 'package:equatable/equatable.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();
}

class PlayerInitialize extends PlayerEvent {
  @override
  List<Object> get props => null;
}

class PlayerChangeReleaseMode extends PlayerEvent {
  @override
  List<Object> get props => null;
}

class PlayerSeekPosition extends PlayerEvent {
  double sliderPosition;

  PlayerSeekPosition({this.sliderPosition});

  @override
  List<Object> get props => [sliderPosition];
}

class UpdatePlayer extends PlayerEvent {
  @override
  List<Object> get props => null;
}

class StopPlayer extends PlayerEvent {
  @override
  List<Object> get props => null;
  
}