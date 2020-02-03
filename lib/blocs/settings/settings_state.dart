import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
}

class InitialSettingsState extends SettingsState {
  @override
  List<Object> get props => null;
}

class SettingsLoaded extends SettingsState {
  bool isWakelockEnabled;
  String appName;
  String packageName;
  String version;
  String buildNumber;

  SettingsLoaded(
      {this.isWakelockEnabled,
      this.appName,
      this.buildNumber,
      this.packageName,
      this.version});

  @override
  List<Object> get props =>
      [isWakelockEnabled, appName, packageName, version, buildNumber];
}

class SettingsLoading extends SettingsState {
  @override
  // TODO: implement props
  List<Object> get props => null;

}
