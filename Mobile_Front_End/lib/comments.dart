import 'dart:convert';
import 'package:buzz_app/addComment_route.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'login_route.dart';
import 'package:http/http.dart' as http;

class CommentData {
  final int? mId;
  final int? mPostId;
  final int mUserId;
  final String mComment;
  final int? mLikes;
  final int? mDislikes;
  final String? filename;
  final String? filelink;

  CommentData(
      {required this.mId,
      required this.mPostId,
      required this.mUserId,
      required this.mComment,
      required this.mLikes,
      required this.mDislikes,
      required this.filename,
      required this.filelink});

  factory CommentData.fromJson(Map<String, dynamic> json) {
    return CommentData(
        mId: json['mId'],
        mPostId: json['mcomId'],
        mUserId: json['mUserId'],
        mComment: json['mComment'],
        mLikes: json['mLikeCount'],
        mDislikes: json['mDislikeCount'],
        filelink: json['mFileLink'],
        filename: json['mFileName']);
  }
}

// list of all messages' data
class Comments {
  final String mStatus;
  final List<CommentData> mData;

  Comments({
    required this.mStatus,
    required this.mData,
  });

  factory Comments.fromJson(Map<String, dynamic> json) {
    var list = json['mData'] as List;
    List<CommentData> messageList =
        list.map((i) => CommentData.fromJson(i)).toList();

    return Comments(
      mStatus: json['mStatus'],
      mData: messageList,
    );
  }
}

// class outlines (GET)route to fetch messages
class GetComments {
  static GetComments getComment = GetComments();
  // static List comments = [];

  // tell our fetchMessages function to run asynchronously while we wait
  // for data to be fetched from server
  Future<Comments> fetchComments(int msgID) async {
    final response = await http.get(
      Uri.parse('https://thebuzzaws.herokuapp.com/messages/' +
          msgID.toString() +
          '/comments'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print(response.statusCode);
    print('hello');
    print(response.body);

    if (response.statusCode == 200) {
      // If server returned a 200 OK response, then parse the JSON
      return Comments.fromJson(jsonDecode(response.body));
    } else {
      // else if server didn't return a successful response, then throw an exception
      throw Exception('Failed to load comments');
    }
  }
}

// class outlines (POST)route to add/create a new message
class AddComment {
  final String? mUserId;
  final String mMessage;

  AddComment({
    required this.mUserId,
    required this.mMessage,
  });

  factory AddComment.fromJson(Map json) {
    return AddComment(
      mUserId: json['mTitle'],
      mMessage: json['mMessage'],
    );
  }
}

class EditComment {
  final String? mUserId;

  EditComment({
    required this.mUserId,
  });

  factory EditComment.fromJson(Map json) {
    return EditComment(
      mUserId: json['mData']['mUser_id'],
    );
  }
}

Future<AddComment> addComment(String comment, String userID, int msgID,
    int fileType, String uploadFileName, String uploadData) async {
  final response = await http.post(
    Uri.parse('https://thebuzzaws.herokuapp.com/messages/' +
        msgID.toString() +
        '/' +
        GoogleSignInApi.user_id.toString() +
        '/post_comment'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'mComment': comment,
      'fileType': fileType,
      'uploadFileName': uploadFileName,
      'uploadData': uploadData,
      'mKey': 'ok'
    }),
  );
  print(response.body);

  if (response.statusCode == 200) {
    // If server returned a 200 CREATED response, then parse the JSON
    return AddComment.fromJson(jsonDecode(response.body));
  } else {
    // else if server didn't return a successful response, then throw an exception
    throw Exception('Failed to post comment');
  }
}

Future<bool> editComment(int msgID, int? commentID, String comment) async {
  // String mSession = GoogleSignInApi.sessionID;
  // String otherID = GoogleSignInApi.user_id.toString();
  // final response1 = await http.get(
  //   Uri.parse('https://thebuzzaws.herokuapp.com/messages/' +
  //       msgID.toString() +
  //       '/' +
  //       GoogleSignInApi.user_id.toString() +
  //       '/' +
  //       commentID.toString() +
  //       '/edit_comment/'),
  //   headers: {
  //     'Content-Type': 'application/json; charset=UTF-8'
  //     // 'mSession': GoogleSignInApi.sessionID,
  //     // 'mUserId': GoogleSignInApi.userID
  //   },
  //   body: jsonEncode(<String, String>{
  //       'mComment': comment,
  //       // 'mUserId': userID,
  //       // 'mSession': mSession
  //     }),

  // );
  // print('hello');
  // print(response1.body);
  // if (response1.statusCode == 200) {
  //   // If server returned a 200 CREATED response, then parse the JSON

  //   otherID = EditComment.fromJson(jsonDecode(response1.body)).mUserId!;
  //   // test.mUserId
  // } else {
  //   // else if server didn't return a successful response, then throw an exception
  //   throw Exception('Failed to post comment');
  // }

  // if (GoogleSignInApi.user_id.toString() == otherID) {
  final response = await http.put(
    Uri.parse('https://thebuzzaws.herokuapp.com/messages/' +
        msgID.toString() +
        '/' +
        GoogleSignInApi.user_id.toString() +
        '/' +
        commentID.toString() +
        '/edit_comment'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'mComment': comment,
      // 'mUserId': userID,
      // 'mSession': mSession
    }),
  );
  print(commentID.toString());
  print('hello');
  print(response.statusCode);
  // print("message: " +
  //     message +
  //     " userID: " +
  //     userID +
  //     " mSession: " +
  //     mSession);
  // print(response.body);

  if (response.statusCode == 200) {
    // If server returned a 200 CREATED response, then parse the JSON
    return true;
  } else if (response.statusCode == 202) {
    Fluttertoast.showToast(
        msg: "Not permissible",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    return false;
  } else {
    // else if server didn't return a successful response, then throw an exception
    throw Exception('Failed to post comment');
  }
}
