import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_route.dart';
import 'messages.dart';

// class outlines (GET)route to fetch messages
class getProfile {
  // static String sessionID = GoogleSignInApi.sessionID;
  static String profEmail = '';

  static Future<Profile> fetchProfile(String user) async {
    // String sessionID = GoogleSignInApi.sessionID;
    // print("sessionid: " + sessionID);
    final response = await http.get(
      Uri.parse(
          'https://thebuzzaws.herokuapp.com/' + user.toString() + '/profile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print("fetchprof: " + response.body);

    if (response.statusCode == 200) {
      // If server returned a 200 OK response, then parse the JSON
      return Profile.fromJson(jsonDecode(response.body));
    } else {
      // else if server didn't return a successful response, then throw an exception
      throw Exception('Failed to load messages');
    }
  }

  // static void updateBio(String newBio) async {
  //   // String sessionID = GoogleSignInApi.sessionID;
  //   // String user = GoogleSignInApi.userID;
  //   // print("sessionid: " + sessionID);
  //   final response = await http.post(
  //     Uri.parse('https://thebuzzaws.herokuapp.com/bio'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       // 'mSession': sessionID,
  //       // 'mUserId': user,
  //       'mMessage': newBio
  //     }),
  //   );
  //   print(response.body);
  // }
}

// class outlines (POST)route to add/create a new message
class Profile {
  String mEmail = '';
  // bool mData = false;
  static String profEmail = '';
  String name = '';

  Profile(
      {
      // required this.mData,
      required this.mEmail,
      required this.name
      // required this.profEmail,
      });

  factory Profile.fromJson(Map json) {
    print("prof json: " + json.toString());
    profEmail = json['mData']['email'];
    return Profile(
        // mData: json['mData'],
        mEmail: json['mData']['email'],
        name: json['mData']['username']
        // profEmail: json['mMessage'],
        );
  }
}
