import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import 'package:wakelock/wakelock.dart';
import 'package:package_info/package_info.dart';
import 'package:rate_my_app/rate_my_app.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {

  //Обеспечивает управление настройками
  //Из реализованных настроек: включение/отключение автоблокировки экрана

  //Также поставляет информацию о версии приложения на главный экран

  @override
  SettingsState get initialState => InitialSettingsState();

  RateMyApp rateMyApp = RateMyApp(
    googlePlayIdentifier: 'mobi.devsteam.mp3'
  );

  bool _isWakelockEnabled;

  String _appName;
  String _packageName;
  String _version;
  String _buildNumber;

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    print(event.toString());
    if (event is WakelockToggled) {
      yield* _mapWakelockToggledToState();
    } else if (event is InitializeSettings) {
      yield* _mapInitializeSettingsToState();
    } else if (event is GetSettings) {
      yield SettingsLoading();
      yield SettingsLoaded(
          isWakelockEnabled: _isWakelockEnabled,
          version: _version,
          appName: _appName,
          packageName: _packageName,
          buildNumber: _buildNumber);
    } else if (event is LaunchStoreForRating) {
      rateMyApp.launchStore();
    }
  }

  Stream<SettingsState> _mapWakelockToggledToState() async* {
    _isWakelockEnabled = await Wakelock.isEnabled;

    if (_isWakelockEnabled) {
      Wakelock.disable();
    } else
      Wakelock.enable();

    _isWakelockEnabled = await Wakelock.isEnabled;

    add(GetSettings());
  }

  Stream<SettingsState> _mapInitializeSettingsToState() async* {
    _isWakelockEnabled = await Wakelock.isEnabled;
    // yield SettingsNotVisible();

    await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      _appName = packageInfo.appName;
      _packageName = packageInfo.packageName;
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
      add(GetSettings());
    });
  }
}
