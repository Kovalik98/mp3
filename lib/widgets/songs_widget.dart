import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
import 'package:auto_size_text/auto_size_text.dart';

class SongsWidget extends StatefulWidget {
  SongsWidget({Key key}) : super(key: key);

  @override
  _SongsWidgetState createState() => _SongsWidgetState();
}

class _SongsWidgetState extends State<SongsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {}

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongsBloc, SongsState>(
      builder: (BuildContext context, SongsState state) {
        if (state is SongsLoaded) {
          print(state.isDialogVisible);

          if (state.isDialogVisible) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              showDialog(
                  context: context,
                  builder: (context) {
                    Future.delayed(Duration(seconds: 4), () {
                      Navigator.of(context).pop(true);
                    });
                    return SimpleDialog(
                      titlePadding: EdgeInsets.all(5),
                      children: <Widget>[
                        Container(
                          child: Center(
                            child: AutoSizeText(
                              state.dialogContent,
                              textAlign: TextAlign.center,
                              minFontSize: 20,
                            ),
                          ),
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.width * 0.3,
                        )
                      ],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    );
                  });
            });
          }

          if (state.isReorderable) {
            return ReorderableListView(
              children: List.generate(state.songs.length, (index) {
                return songCard(state, index);
              }),
              onReorder: (int oldIndex, int newIndex) {
                BlocProvider.of<SongsBloc>(context).add(
                    UpdateSongsOrder(oldIndex: oldIndex, newIndex: newIndex));
              },
            );
          } else {
            return ListView(
              children: List.generate(state.songs.length, (index) {
                return songCard(state, index);
              }),
            );
          }
        } else
          return Container();
      },
    );
  }

  Widget songCard(SongsLoaded state, int index) {
    return Card(
      color: (state.isPlaying == true && state.lastPlayedSongIndex == index)
          ? Colors.orange
          : Colors.orangeAccent,
      key: ValueKey("value$index"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          songDescription(state, index),
          songOptions(state, index),
        ],
      ),
    );
  }

  Widget songDescription(SongsLoaded state, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        FlatButton(
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/icon.jpg'),
                    fit: BoxFit.fill,
                    alignment: Alignment.center
                )
            ),
            child: Container(
              height: 60,
              width: 60,
              child: (state.lastPlayedSongIndex == index && state.isPlaying)
                  ? Icon(Icons.stop, color: Colors.white,)
                  : Icon(Icons.play_circle_filled, color: Colors.white,),
            ),
          ),
          onPressed: () async {
            if (state.lastPlayedSongIndex == index) {
              BlocProvider.of<SongsBloc>(context).add(Stop());
            } else {
              print(index);
              BlocProvider.of<SongsBloc>(context)
                  .add(PlaySong(songIndex: index));
            }
          },
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                state.isReorderable
                    ? '${state.songs[index].title}'
                    : '${index + 1}. ${state.songs[index].title}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                '${state.songs[index].artist}',
                style: TextStyle(fontSize: 14),
              ),

            ],

          ),
        ),
        optionsMenu(state, index),
        FlatButton(
    child: Icon( Icons.favorite),
        ),
      ],

    );
  }

  Widget optionsMenu(SongsLoaded state, int index) {
    if (Platform.isAndroid) {
      return FlatButton(
        child: Icon(Icons.settings),
        onPressed: () {
          BlocProvider.of<SongsBloc>(context).add(ExpandSongOptions(songIndex: index));
        },
      );
    } else
      return Container();
  }

  Widget songOptions(SongsLoaded state, int index) {
    if (state.songs[index].isMenuExpanded) {
      return Container(
        decoration: new BoxDecoration(
            color: Colors.white70,
            borderRadius: new BorderRadius.only(
                bottomLeft: const Radius.circular(15.0),
                bottomRight: const Radius.circular(15.0))),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              padding: EdgeInsets.all(5.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.settings),
                  FittedBox(fit: BoxFit.fill, child: Text('Set as ringtone')),
                ],
              ),
              onPressed: () {
                BlocProvider.of<SongsBloc>(context)
                    .add(SetSongAsRingtone(songIndex: index));
              },
            ),
            FlatButton(
              padding: EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  Icon(Icons.settings),
                  FittedBox(fit: BoxFit.fill, child: Text('Set as alarm')),
                ],
              ),
              onPressed: () {
                BlocProvider.of<SongsBloc>(context)
                    .add(SetSongAsAlarmSound(songIndex: index));
              },
            ),
            FlatButton(
              padding: EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  Icon(Icons.settings),
                  FittedBox(
                      fit: BoxFit.fill, child: Text('Set as notification')),
                ],
              ),
              onPressed: () {
                BlocProvider.of<SongsBloc>(context)
                    .add(SetSongAsNotificationSound(songIndex: index));
              },
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
