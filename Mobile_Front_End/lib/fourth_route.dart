import 'package:buzz_app/main.dart';
import 'package:buzz_app/profile_route.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'addComment_route.dart';
import 'editComment.dart';
import 'get_messages.dart';
import 'comments.dart';
import 'login_route.dart';
import 'package:buzz_app/showPic.dart';
import 'package:url_launcher/url_launcher.dart';

int msgID = 0;

// third page: allows user to view comments and add/edit his own
class FourthRoute extends StatefulWidget {
  FourthRoute(int msID, {Key? key}) : super(key: key) {
    msgID = msID;
  }
  @override
  _FourthRouteState createState() => _FourthRouteState();
}

class _FourthRouteState extends State<FourthRoute> {
  // GlobalKey gives unique identifier to our Form widget so that we can do text validation later
  final _formKey = GlobalKey<FormState>();
  //? for nullable instead of late
  late Future<Comments> loadComments;
  //late Future<Pics> loadPics;
  String sessionID = '';
  String user = '';
  //late Future<Messages> loadWithContent;

  @override
  void initState() {
    loadComments = GetComments.getComment.fetchComments(msgID);
    sessionID = GoogleSignInApi.sessionID;
    user = GoogleSignInApi.user_id.toString();
    super.initState();
  }

  Widget _buildMsgRow(CommentData data) {
    // print(data.mPostId);
    print('no');
    print(data.mUserId);
    // makes a row for each message followed by a like button icon
    if (data.filelink != null) {
      return ListTile(
          title: Text(data.mComment, style: TextStyle(fontFamily: 'Roboto')),
          //subtitle: Text(data.mContent),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      editCommentRoute(data.mId!, user, data.mPostId)),
            );
          },
          trailing: Wrap(spacing: 1, children: <Widget>[
            IconButton(
                icon: const Icon(Icons.insert_photo),
                // data.mLikes != 0 ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                color: data.filelink != "" ? Colors.blue : Colors.grey,
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
              icon: const Icon(Icons.account_circle_rounded),
              // data.mLikes != 0 ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => profileRoute(data.mUserId)),
                );
              },
            ),
          ]));
    } else {
      return ListTile(
          title: Text(data.mComment, style: TextStyle(fontFamily: 'Roboto')),
          //subtitle: Text(data.mContent),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      editCommentRoute(data.mId!, user, data.mPostId)),
            );
          },
          trailing: Wrap(spacing: 1, children: <Widget>[
            IconButton(
                icon: const Icon(Icons.insert_photo),
                // data.mLikes != 0 ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                color: Colors.grey,
                onPressed: () async {
                  // Uri url = Uri.parse((data.filelink as String));
                  // //final url =
                  // //  Uri.parse(('https://pub.dev/packages/url_launcher'));
                  // //final url = 'https:\\pub.dev/packages/url_launcher';

                  // if (await canLaunchUrl(url)) {
                  //   await launchUrl(url);
                  // } else {
                  //   throw 'Could not launch $url';
                  // }
                }),
            IconButton(
              icon: const Icon(Icons.account_circle_rounded),
              // data.mLikes != 0 ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => profileRoute(data.mUserId)),
                );
              },
            ),
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
        title: const Text("All Comments"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                loadComments = GetComments.getComment.fetchComments(msgID);
              });
            },
            icon: Icon(Icons.refresh),
          )
        ],
      ),
      body: Center(
        child: FutureBuilder<Comments>(
          // need to access data returned by our future async functions
          // with future builder and snapshot
          future: loadComments,
          builder: (context, snapshot) {
            // if our function retrieved data successfully, return the message content
            if (snapshot.hasData) {
              return _buildMsgList(snapshot.data!
                  .mData); //If there are comments on the post it will show them

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
          //add a comment
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => addCommentRoute(msgID, user)),
          );
        },
        tooltip: 'Add a new comment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
