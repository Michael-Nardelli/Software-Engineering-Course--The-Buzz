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
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

String link = "None";

// third page: allows user to view comments and add/edit his own
class showPic extends StatefulWidget {
  showPic(String link2, {Key? key}) : super(key: key) {
    link = link2;
    // final decodedBytes = base64Decode(bytes);
  }
  @override
  _showPicState createState() => _showPicState();
}

class _showPicState extends State<showPic> {
  // GlobalKey gives unique identifier to our Form widget so that we can do text validation later
  final _formKey = GlobalKey<FormState>();
  //? for nullable instead of late
  //late Future<Comments> loadComments;
  //late Future<Pics> loadPics;
  // String sessionID = '';
  // String user = '';
  //late Future<Messages> loadWithContent;

  @override
  void initState() {
    //final decodedBytes = base64Decode(bytes);
    // loadComments = GetComments.getComment.fetchComments(msgID);
    // sessionID = GoogleSignInApi.sessionID;
    // user = GoogleSignInApi.user_id.toString();
    super.initState();
  }

  // Widget _buildMsgRow(CommentData data) {
  //   // print(data.mPostId);
  //   print('no');
  //   print(data.mUserId);
  //   // makes a row for each message followed by a like button icon
  //   return ListTile(
  //       title: Text(data.mComment, style: TextStyle(fontFamily: 'Roboto')),
  //       //subtitle: Text(data.mContent),
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) =>
  //                   editCommentRoute(data.mId!, user, data.mPostId)),
  //         );
  //       },
  //       trailing: Wrap(spacing: 1, children: <Widget>[
  //         IconButton(
  //           icon: const Icon(Icons.account_circle_rounded),
  //           // data.mLikes != 0 ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
  //           onPressed: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                   builder: (context) => profileRoute(data.mUserId)),
  //             );
  //           },
  //         ),
  //       ]));
  // }

  // Widget _buildMsgList(List messages) {
  //   return ListView.builder(
  //       padding: const EdgeInsets.all(16.0),
  //       itemCount: messages.length,
  //       itemBuilder: (context, i) {
  //         return _buildMsgRow(messages[i]);
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    // print("build run");
    return Scaffold(
      appBar: AppBar(
        title: const Text("File"),
      ),
      body: Center(
          child: Column(children: <Widget>[
        Image.network(link),
      ])),
    );
  }
}
