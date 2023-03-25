import 'package:buzz_app/fourth_route.dart';
import 'package:buzz_app/login_route.dart';
import 'package:buzz_app/profile_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'Messages.dart';
import 'get_messages.dart';
import 'package:buzz_app/second_route.dart';
import 'package:buzz_app/showPic.dart';
import 'package:cache_manager/cache_manager.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of our application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const LoginRoute(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  // This widget is the home page of our app, it has a State object that has fields
  // that describe what our app will look like

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //? for nullable instead of late
  late Future<Messages> loadMessages;
  String sessionID = '';
  int user = 0;
  //late Future<Messages> loadWithContent;

  @override
  void initState() {
    loadMessages = GetMessages.getMsg.fetchMessages();
    sessionID = GoogleSignInApi.sessionID;
    user = GoogleSignInApi.user_id;
    super.initState();
  }

  Widget _buildMsgRow(MessageData data) {
    // sessionID = GoogleSignInApi.sessionID;
    // makes a row for each message followed by a like button icon
    //String message = data.mContent;
    if (data.filelink != null) {
      String IDStr = data.mId.toString();
      String link = data.filelink as String;
      WriteCache.setString(key: IDStr, value: link);
    }

    if (data.mContent != null) {
      if (data.filelink != null) {
        return ListTile(
            //title: Text("Must Fix", style: TextStyle(fontFamily: 'Roboto')),
            title: Text(data.mContent as String,
                style: TextStyle(fontFamily: 'Roboto')),
            //subtitle: Text(data.mContent),
            onTap: () {
              // should increment likes count for the message row which calls PUT update
              // function defined in get_messages.dart to change value via backend-->database
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FourthRoute(data.mId!)),
              );
            },
            trailing: Wrap(
                // spacing: 1,
                children: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.insert_photo),
                      // data.mLikes != 0 ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                      color: data.filelink != "" ? Colors.blue : Colors.grey,
                      // onPressed: () {
                      //   print(data.filelink);
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => showPic(data.filelink!)),
                      //   );
                      // },
                      onPressed: () async {
                        Uri url = Uri.parse((data.filelink as String));
                        //final url =
                        //  Uri.parse(('https://pub.dev/packages/url_launcher'));
                        //final url = 'https:\\pub.dev/packages/url_launcher';

                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      }),
                  IconButton(
                    icon: const Icon(Icons.thumb_up_alt),
                    // data.mLikes != 0 ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                    color: data.mLikes != 0 ? Colors.blue : Colors.grey,
                    onPressed: () {
                      setState(() {
                        updateLikes(data.mId!.toInt(), GoogleSignInApi.user_id,
                            data.mLikes);
                        // loadMessages = GetMessages.getMsg.fetchMessages();
                      });
                    },
                  ),
                  Text(data.mLikes.toString()),
                  IconButton(
                    icon: const Icon(Icons.thumb_down_alt),
                    // data.mLikes != 0 ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                    color: data.mDislikes != 0 ? Colors.blue : Colors.grey,
                    onPressed: () {
                      setState(() {
                        updateDislikes(
                            data.mId!.toInt(), data.mUserId, data.mDislikes);
                        // loadMessages = GetMessages.getMsg.fetchMessages();
                      });
                    },
                  ),
                  Text(data.mDislikes.toString())
                ]));
      } else {
        return ListTile(
            //title: Text("Must Fix", style: TextStyle(fontFamily: 'Roboto')),
            title: Text(data.mContent as String,
                style: TextStyle(fontFamily: 'Roboto')),
            //subtitle: Text(data.mContent),
            onTap: () {
              // should increment likes count for the message row which calls PUT update
              // function defined in get_messages.dart to change value via backend-->database
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FourthRoute(data.mId!)),
              );
            },
            trailing: Wrap(
                // spacing: 1,
                children: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.insert_photo),
                      // data.mLikes != 0 ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                      color: Colors.grey,
                      // onPressed: () {
                      //   print(data.filelink);
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => showPic(data.filelink!)),
                      //   );
                      // },
                      onPressed: () async {
                        //none
                      }),
                  IconButton(
                    icon: const Icon(Icons.thumb_up_alt),
                    // data.mLikes != 0 ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                    color: data.mLikes != 0 ? Colors.blue : Colors.grey,
                    onPressed: () {
                      setState(() {
                        updateLikes(data.mId!.toInt(), GoogleSignInApi.user_id,
                            data.mLikes);
                        // loadMessages = GetMessages.getMsg.fetchMessages();
                      });
                    },
                  ),
                  Text(data.mLikes.toString()),
                  IconButton(
                    icon: const Icon(Icons.thumb_down_alt),
                    // data.mLikes != 0 ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                    color: data.mDislikes != 0 ? Colors.blue : Colors.grey,
                    onPressed: () {
                      setState(() {
                        updateDislikes(
                            data.mId!.toInt(), data.mUserId, data.mDislikes);
                        // loadMessages = GetMessages.getMsg.fetchMessages();
                      });
                    },
                  ),
                  Text(data.mDislikes.toString())
                ]));
      }
    } else {
      return ListTile(
          //title: Text("Must Fix", style: TextStyle(fontFamily: 'Roboto')),
          title: Text("NULL", style: TextStyle(fontFamily: 'Roboto')),
          //subtitle: Text(data.mContent),
          onTap: () {
            // should increment likes count for the message row which calls PUT update
            // function defined in get_messages.dart to change value via backend-->database
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FourthRoute(data.mId!)),
            );
          },
          trailing: Wrap(
              // spacing: 1,
              children: <Widget>[
                IconButton(
                    icon: const Icon(Icons.insert_photo),
                    // data.mLikes != 0 ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                    color: data.filelink != "" ? Colors.blue : Colors.grey,
                    //onPressed: () {

                    onPressed: () async {
                      Uri url = data.filelink as Uri;
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    }

                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => showPic(data.filelink!)),
                    //     );
                    //  },
                    ),
                IconButton(
                  icon: const Icon(Icons.thumb_up_alt),
                  // data.mLikes != 0 ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                  color: data.mLikes != 0 ? Colors.blue : Colors.grey,
                  onPressed: () {
                    setState(() {
                      updateLikes(data.mId!.toInt(), GoogleSignInApi.user_id,
                          data.mLikes);
                      // loadMessages = GetMessages.getMsg.fetchMessages();
                    });
                  },
                ),
                Text(data.mLikes.toString()),
                IconButton(
                  icon: const Icon(Icons.thumb_down_alt),
                  // data.mLikes != 0 ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                  color: data.mDislikes != 0 ? Colors.blue : Colors.grey,
                  onPressed: () {
                    setState(() {
                      updateDislikes(
                          data.mId!.toInt(), data.mUserId, data.mDislikes);
                      // loadMessages = GetMessages.getMsg.fetchMessages();
                    });
                  },
                ),
                Text(data.mDislikes.toString())
              ]));
    }
  }

  Widget _buildMsgList(List messages) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: messages.length,
        itemBuilder: (context, i) {
          return _buildMsgRow(messages[i]);
        });
  }

  @override
  Widget build(BuildContext context) {
    // print("build run");
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("All Messages", style: TextStyle(fontFamily: 'Roboto')),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => profileRoute(user)),
              );
            },
            icon: Icon(Icons.account_circle_rounded),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                loadMessages = GetMessages.getMsg.fetchMessages();
              });
            },
            icon: Icon(Icons.refresh),
          )
        ],
      ),
      body: Center(
        child: FutureBuilder<Messages>(
          // need to access data returned by our future async functions
          // with future builder and snapshot
          future: loadMessages,
          builder: (context, snapshot) {
            // if our function retrieved data successfully, return the message content
            if (snapshot.hasData) {
              return _buildMsgList(snapshot.data!.mData);
              // else if there was an error, return error message
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // show a loading spinner as default value while waiting
            return const CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SecondRoute()),
          );
        },
        tooltip: 'Add a new message',
        child: const Icon(Icons.add),
      ),
    );
  }
}
