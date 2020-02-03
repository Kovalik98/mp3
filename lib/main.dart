import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dart_tags/dart_tags.dart';
import 'dart:typed_data';

import 'package:mp3/widgets/player_widget.dart';
import 'package:mp3/models/song.dart';
import 'package:mp3/blocs/player/bloc.dart';
import 'package:mp3/blocs/songs/bloc.dart';
import 'package:mp3/blocs/settings/bloc.dart';
import 'package:mp3/widgets/songs_widget.dart';

import 'package:mp3/screens/menu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiBlocProvider(
        providers: [
          BlocProvider<PlayerBloc>(
            builder: (context) =>
            PlayerBloc(audioPlayer)..add(PlayerInitialize()),
          ),
          BlocProvider<SongsBloc>(
            builder: (context) =>
            SongsBloc(audioPlayer)..add(InitializeSongs()),
          ),
          BlocProvider<SettingsBloc>(
            builder: (context) => SettingsBloc()..add(InitializeSettings()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'o.torvald',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MainMenu(),
        ));
  }
}
