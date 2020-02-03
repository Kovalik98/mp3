import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
}

class InitializeSettings extends SettingsEvent {
  @override
  List<Object> get props => [];

}

class WakelockToggled extends SettingsEvent {
  @override
  List<Object> get props => [];
}

class GetSettings extends SettingsEvent {
  @override
  List<Object> get props => null;

}

class LaunchStoreForRating extends SettingsEvent {
  @override
  List<Object> get props => null;

}
