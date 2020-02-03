import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:audioplayers/audioplayers.dart';

import 'package:mp3/blocs/player/bloc.dart';

class PlayerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PlayerWidgetState();
  }
}

class PlayerWidgetState extends State<PlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (BuildContext context, PlayerState state) {
        if (state is InitialPlayerState)
          return Container();
        else
          return player(state);
      },
    );
  }

  Widget player(PlayerState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        color: Colors.amber,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Stack(
                    children: [
                      Slider(
                        onChanged: (v) {
                          BlocProvider.of<PlayerBloc>(context)
                              .add(PlayerSeekPosition(sliderPosition: v));
                        },
                        activeColor: Colors.white,
                        value: (state is PlayerPlaying &&
                            state.sliderPosition > 0 &&
                            state.sliderPosition < 1)
                            ? state.sliderPosition
                            : 0.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                state is PlayerPlaying
                    ? '${state.positionText ?? ''} / ${state.durationText ?? ''}'
                    : '0:00:00 / 0:00:00',
              ),
            ),
            IconButton(
              icon: Icon(Icons.repeat),
              color: state is PlayerPlaying
                  ? state.releaseMode == ReleaseMode.LOOP
                  ? Colors.white
                  : Colors.black
                  : Colors.black,
              onPressed: () {
                state is PlayerPlaying
                    ? BlocProvider.of<PlayerBloc>(context)
                    .add(PlayerChangeReleaseMode())
                    : null;
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    BlocProvider.of<PlayerBloc>(context).add(PlayerInitialize());
  }

  @override
  void dispose() {
    super.dispose();
  }
}
