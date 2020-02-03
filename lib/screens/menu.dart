import 'package:flutter/material.dart';
import 'package:mp3/screens/homepage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mp3/blocs/player/bloc.dart';
import 'package:mp3/blocs/songs/bloc.dart';
import 'package:mp3/blocs/settings/bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter/scheduler.dart';
import 'package:share/share.dart';


class MainMenu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainMenuState();
  }
}

class MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuety = MediaQuery.of(context);

    return Scaffold(
        backgroundColor: Color.fromRGBO(246, 170, 7, 1),
        body: Container(
          child: Center(

            child: Column(

              mainAxisAlignment: MainAxisAlignment.start,

              children: <Widget>[
                FittedBox(
                  fit: BoxFit.fill,
            child: Padding(

                padding: EdgeInsets.symmetric(vertical: 60.0),

                child: Image.asset("assets/icon.jpg")),
            ),
                FittedBox(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HomePage(
                                      title: 'O.Torvald',
                                    )));
                      },

                      child: Text('START', style: TextStyle(fontSize: 60.0,
                       decoration: TextDecoration.none,
                          fontFamily: 'Trajan Pro',
                        fontWeight: FontWeight.w700
                      ),
                       )
                  ),
                ),
                FittedBox(
                  child: FlatButton(
                      onPressed: () {
                        BlocProvider.of<SettingsBloc>(context)
                            .add(GetSettings());
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return BlocBuilder<SettingsBloc, SettingsState>(
                                builder: (BuildContext context,
                                    SettingsState state) {
                                  if (state is SettingsLoaded) {
                                    return SimpleDialog(
                                      title: Text(
                                        'Settings',
                                        textAlign: TextAlign.center,

                                      ),
                                      titlePadding: EdgeInsets.all(5),
                                      children: <Widget>[
                                        Container(
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Text('Keep screen on'),
                                                Switch(
                                                    value:
                                                    state.isWakelockEnabled,
                                                    onChanged: (bool value) {
                                                      BlocProvider.of<
                                                          SettingsBloc>(
                                                          context)
                                                          .add(
                                                          WakelockToggled());
                                                    })
                                              ],
                                            ),

                                          ),


                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width *
                                              0.9,
                                          height: MediaQuery
                                              .of(context)
                                              .size
                                              .width *
                                              0.3,
                                        ),
                                        SimpleDialogOption(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Close'),
                                        ),
                                      ],
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0)),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              );
                            });
                      },


                      child: Text('SETTINGS', style: TextStyle(fontSize: 60.0,
                          decoration: TextDecoration.none,
                          fontFamily: 'Trajan Pro',
                          fontWeight: FontWeight.w700
                      ),)

                  ),
                ),

                FittedBox(
                  child: FlatButton(

                    onPressed: ()async {

                      BlocProvider.of<SettingsBloc>(context)
                          .add(GetSettings());
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return BlocBuilder<SettingsBloc, SettingsState>(
                              builder: (BuildContext context,
                                  SettingsState state) {
                                if (state is SettingsLoaded) {
                                  return SimpleDialog(
                                    title: Text(
                                      'Settings',
                                      textAlign: TextAlign.center,
                                    ),
                                    titlePadding: EdgeInsets.all(5),
                                    children: <Widget>[

                                  Container(
                                  child: Center(
                                    child: Row(

                                    children: <Widget>[
                                       Image.asset(
                                          'assets/icon.jpg',
                                          width: 332,
                                          height: 150,
                                      ),

                                    ],

                                  ),

                                ),
                                  ),


                                      FittedBox(
                                        child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10.0),
                                       child: Text("Click OK send this \n application to your friends", textAlign: TextAlign.center,),
                                      ),
                                      ),
                                      Row(
                                  children: <Widget>[

                                       SimpleDialogOption(

                                        onPressed: () {
                                          Navigator.pop(context);
                                        },

                                    child: Container(

                                      color: Colors.black,
                                      height: 50.0,
                                      width: 110.0,

                                child: Align(
                                alignment: Alignment.center,
                                        child: Text('NO, Thanks', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Trajan Pro' ),),
                                ),
                                ),

                                      ),

                                      SimpleDialogOption(

                                        onPressed: () {
                                         Share.share('check out my website https://example.com');
                                        },

                                        child: Container(
                                          color: Colors.black,
                                height: 50.0,
                                width: 110.0,
                                child: Align(
                                alignment: Alignment.center,
                                          child: Text('YES', style: TextStyle(fontSize: 20, color: Colors.white),),
                                ),
                                        ),
                                      ),

                                        ],
                                       ),

                                    ],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10.0)),
                                  );

                                } else {
                                  return Container();
                                }
                              },
                            );
                          });
                    },




                      child: Text('SEND', style: TextStyle(fontSize: 60.0,
                          decoration: TextDecoration.none,
                          fontFamily: 'Trajan Pro',
                          fontWeight: FontWeight.w700,
                          color: Colors.black
                      ),
                      )
                  ),


                ),
              FlatButton(
                onPressed: () {
                  Share.share('check out my website https://example.com');
                },
                child: Text('SEND'),
              ),


                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BlocBuilder<SettingsBloc, SettingsState>(
                          builder: (BuildContext context, SettingsState state) {
                            return Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                color: Colors.white,
                                child: state is SettingsLoaded
                                    ? Text(
                                  '${state.appName} ${state.version}',
                                  textAlign: TextAlign.center,
                                )
                                    : Text('Loading'));
                          },
                        )
                      ],
                    ),
                  ),
                )

              ],
            ),
          ),
        ));
  }
}
