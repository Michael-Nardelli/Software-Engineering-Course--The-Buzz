import 'dart:convert';
import 'package:buzz_app/addComment_route.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'login_route.dart';
import 'package:http/http.dart' as http;

//Update this so that it works
class PicData {
  final int? mId;
  final int? mPostId;
  final int mUserId;
  final String mComment;
  final int? mLikes;
  final int? mDislikes;

  PicData({
    required this.mId,
    required this.mPostId,
    required this.mUserId,
    required this.mComment,
    required this.mLikes,
    required this.mDislikes,
  });

  factory PicData.fromJson(Map<String, dynamic> json) {
    return PicData(
      mId: json['mId'],
      mPostId: json['mcomId'],
      mUserId: json['mUserId'],
      mComment: json['mComment'],
      mLikes: json['mLikeCount'],
      mDislikes: json['mDislikeCount'],
    );
  }
}

// list of all messages' data
class Pics {
  final String mStatus;
  final List<PicData> mData;

  Pics({
    required this.mStatus,
    required this.mData,
  });

  factory Pics.fromJson(Map<String, dynamic> json) {
    var list = json['mData'] as List;
    List<PicData> messageList = list.map((i) => PicData.fromJson(i)).toList();

    return Pics(
      mStatus: json['mStatus'],
      mData: messageList,
    );
  }
}

// class outlines (GET)route to fetch messages
class GetPics {
  static GetPics getPics = GetPics();
  // static List comments = [];

  // tell our fetchMessages function to run asynchronously while we wait
  // for data to be fetched from server
  Future<Pics> fetchPics(int msgID) async {
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
      return Pics.fromJson(jsonDecode(response.body));
    } else {
      // else if server didn't return a successful response, then throw an exception
      throw Exception('Failed to load picture');
    }
  }
}

// class outlines (POST)route to add/create a new message
class AddPic {
  final String? mUserId;
  final String mMessage;

  AddPic({
    required this.mUserId,
    required this.mMessage,
  });

  factory AddPic.fromJson(Map json) {
    return AddPic(
      mUserId: json['mTitle'],
      mMessage: json['mMessage'],
    );
  }
}

Future<AddPic> addPic(String comment, String userID, int msgID) async {
  final response = await http.post(
    Uri.parse('https://thebuzzaws.herokuapp.com/messages/' +
        msgID.toString() +
        '/' +
        GoogleSignInApi.user_id.toString() +
        '/post_comment'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'mComment': comment,
    }),
  );
  print(response.body);

  if (response.statusCode == 200) {
    // If server returned a 200 CREATED response, then parse the JSON
    return AddPic.fromJson(jsonDecode(response.body));
  } else {
    // else if server didn't return a successful response, then throw an exception
    throw Exception('Failed to post Pic');
  }
}
