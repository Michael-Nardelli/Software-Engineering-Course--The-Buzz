import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_route.dart';
import 'Messages.dart';
import 'package:google_sign_in/google_sign_in.dart';

// class outlines (GET)route to fetch messages
class GetMessages {
  static GetMessages getMsg = GetMessages();
  static List messages = [];

  // tell our fetchMessages function to run asynchronously while we wait
  // for data to be fetched from server
  Future<Messages> fetchMessages() async {
    //works now
    // String sessionID = GoogleSignInApi.sessionID;
    final response = await http.get(
      Uri.parse('https://thebuzzaws.herokuapp.com/messages'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    // print(response.body);
    if (response.statusCode == 200) {
      // If server returned a 200 OK response, then parse the JSON
      return Messages.fromJson(jsonDecode(response.body));
    } else {
      // else if server didn't return a successful response, then throw an exception
      throw Exception('Failed to load messages');
    }
  }
}

// class outlines (POST)route to add/create a new message
class AddMessage {
  final String? mTitle;
  final String? mMessage;
  final String? mLikeCount;
  final String? mDislikeCount;
  final String? fileType;
  final String? uploadFileName;
  final String? uploadData;

  AddMessage(
      {required this.mTitle,
      required this.mMessage,
      required this.mLikeCount,
      required this.mDislikeCount,
      required this.fileType,
      required this.uploadFileName,
      required this.uploadData});

  factory AddMessage.fromJson(Map json) {
    return AddMessage(
        mTitle: json['mTitle'],
        mMessage: json['mMessage'],
        mLikeCount: json['mLikeCount'],
        mDislikeCount: json['mDislikeCount'],
        fileType: json['fileType'],
        uploadFileName: json['uploadFileName'],
        uploadData: json['uploadData']);
  }
}

Future<AddMessage> addMsg(String title, String UserId, String message,
    int fileType, String fileName, String bytes) async {
  print(bytes);
  final user = await GoogleSignInApi.login();
  final gg = await user?.authentication;
  final response = await http.post(
    Uri.parse('https://thebuzzaws.herokuapp.com/messages/' +
        GoogleSignInApi.user_id.toString() +
        "/" +
        gg!.idToken.toString()),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'mTitle': title,
      'mMessage': message,
      'mLikeCount': 0,
      'mDislikeCount': 0,
      'fileType': fileType,
      'uploadFileName': fileName,
      'uploadData': bytes
    }),
  );

  if (response.statusCode == 200) {
    // If server returned a 200 CREATED response, then parse the JSON
    return AddMessage.fromJson(jsonDecode(response.body));
  } else {
    // else if server didn't return a successful response, then throw an exception
    throw Exception('Failed to post message');
  }
}

// class to outline (PUT)route to add a like aka increment likes counter
class UpdateLikes {
  final int mLikes;

  UpdateLikes({
    required this.mLikes,
  });

  factory UpdateLikes.fromJson(Map json) {
    // print(json.keys);
    return UpdateLikes(mLikes: json['mLikeCount']); //instead of .mMessage
  }

  factory UpdateLikes.fromInt(int x) {
    // print(json.keys);
    return UpdateLikes(mLikes: x);
  }
}

// Future<UpdateLikes> fetchLikes(int mId) async {
//   final response = await http.get(
//     //+ mId.toString()
//     Uri.parse('https://thebuzzaws.herokuapp.com/messages'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     // headers: {
//     //   'mSession': GoogleSignInApi.sessionID,
//     //   'mUserId': GoogleSignInApi.userID
//     // },
//   );

//   if (response.statusCode == 200) {
//     // If server returned a 200 OK response, then parse the JSON
//     return UpdateLikes.fromJson(jsonDecode(response.body));
//   } else {
//     // else if server didn't return a successful response, then throw an exception
//     throw Exception('Failed to load likes');
//   }
// }

Future<UpdateLikes> updateLikes(int mId, int mUserId, int mLikes) async {
  // UpdateLikes getLikes = await fetchLikes(mId);
  // int mLikes = getLikes.mLikes;

  mLikes += 1;

  final response = await http.put(
    Uri.parse('https://thebuzzaws.herokuapp.com/messages/' +
        mId.toString() +
        "/" +
        GoogleSignInApi.user_id.toString() +
        "/0"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      // 'mLikes': mLikes.toString(),
      // 'mSession': GoogleSignInApi.sessionID,
      // 'mUserId': GoogleSignInApi.userID
    }),
  );

  // print("result for likes update: " + response.body);
  // print(response.statusCode);

  if (response.statusCode == 200 || response.statusCode == 201) {
    // If server returned a 200 CREATED response, then parse the JSON
    return UpdateLikes.fromInt(mLikes);
  } else {
    // else if server didn't return a successful response, then throw an exception
    throw Exception('Failed to like message');
  }
}

/////////////////////////////// DISLIKES /////////////////////////////////////////////////////

// class to outline (PUT)route to add a like aka increment likes counter
class UpdateDislikes {
  final int mDislikes;

  UpdateDislikes({
    required this.mDislikes,
  });

  factory UpdateDislikes.fromJson(Map json) {
    // print(json.keys);
    return UpdateDislikes(mDislikes: json['mDislikeCount']);
  }

  factory UpdateDislikes.fromInt(int x) {
    // print(json.keys);
    return UpdateDislikes(mDislikes: x);
  }
}

// Future<UpdateDislikes> fetchDislikes(int mId) async {
//   final response = await http.get(
//     Uri.parse('https://thebuzzaws.herokuapp.com/messages/' + mId.toString()),
//     headers: {
//       'mSession': GoogleSignInApi.sessionID,
//       'mUserId': GoogleSignInApi.userID
//     },
//   );

//   if (response.statusCode == 200) {
//     // If server returned a 200 OK response, then parse the JSON
//     return UpdateDislikes.fromJson(jsonDecode(response.body));
//   } else {
//     // else if server didn't return a successful response, then throw an exception
//     throw Exception('Failed to load Dislikes');
//   }
// }

Future<UpdateDislikes> updateDislikes(
    int mId, int mUserId, int mDislikes) async {
  // UpdateDislikes getDislikes = await fetchDislikes(mId);
  // int mDislikes = getDislikes.mDislikes;
  mDislikes += 1;
  // var req_body = new Map();
  // req_body['mData']['mLikes'] = mLikes;

  final response = await http.put(
    Uri.parse('https://thebuzzaws.herokuapp.com/messages/' +
        mId.toString() +
        "/" +
        GoogleSignInApi.user_id.toString() +
        "/1"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      // 'mLikes': mLikes.toString(),
      // 'mSession': GoogleSignInApi.sessionID,
      // 'mUserId': GoogleSignInApi.userID
    }),
  );
  print("dislikes: " + response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    // If server returned a 200 CREATED response, then parse the JSON

    return UpdateDislikes.fromInt(mDislikes);
  } else {
    // else if server didn't return a successful response, then throw an exception
    throw Exception('Failed to dislike message');
  }
}
