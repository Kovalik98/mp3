import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mp3/blocs/settings/bloc.dart' as prefix1;
import 'package:mp3/blocs/settings/settings_bloc.dart' as prefix0;
import 'package:mp3/blocs/songs/bloc.dart';
import 'package:mp3/blocs/settings/bloc.dart';
import 'package:mp3/blocs/player/bloc.dart';
import 'package:mp3/widgets/player_widget.dart';
import 'package:mp3/widgets/songs_widget.dart';
import 'package:rate_my_app/rate_my_app.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongsBloc, SongsState>(
        builder: (BuildContext context, SongsState state) {
          return WillPopScope(
            onWillPop: () => willPop(context),
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Color.fromRGBO(246, 170, 7, 1),
                title: (state is SongsLoaded && state.isPlaying == true) ? Text(state.songs[state.lastPlayedSongIndex].title) : Text(widget.title),
                actions: <Widget>[
//               Padding(
//                 padding: EdgeInsets.fromLTRB(0, 0, 60, 0),
//                  child: IconButton(
//                    icon: Icon(Icons.queue_music),
//                    onPressed: () {
//                      BlocProvider.of<SongsBloc>(context)
//                          .add(ChangeSongsPlaybackMode());
//                    },
//                  ),
//                 ),
                ],
              ),

              endDrawer: Drawer(
          child: Container(
            color: Colors.black54,
            width: 5,



                child: ListView(

                  // Important: Remove any padding from the ListView.

                  children: <Widget>[

                    ListTile(
                      title: Text('Item 1', style: TextStyle(color: Colors.white),),
                      onTap: () {
                        // Update the state of the app
                        // ...
                        // Then close the drawer
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text('Item 1', style: TextStyle(color: Colors.white),),
                      onTap: () {
                        // Update the state of the app
                        // ...
                        // Then close the drawer
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
               ),
              ),

              body: Column(
                children: <Widget>[
                  PlayerWidget(),
                  Expanded(child: SongsWidget()),
                ],
              ),
              backgroundColor: Colors.white,
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext _context) {
                        return AlertDialog(
                          title: Text('Rate this app'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Maybe later'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            FlatButton(
                              child: Text('Let\'s go'),
                              onPressed: () {
                                BlocProvider.of<SettingsBloc>(context)
                                    .add(LaunchStoreForRating());
                              },
                            )

                          ],
                        );
                      });
                },
                tooltip: 'Rate app',
                child: Icon(Icons.star),
              ),
            ),
          );
        });
  }

  Future<bool> willPop(BuildContext context) async {
    BlocProvider.of<SongsBloc>(context).add(Stop());

    return true;
  }
}
