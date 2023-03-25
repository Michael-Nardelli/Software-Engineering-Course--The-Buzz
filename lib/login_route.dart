import 'package:buzz_app/main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'get_messages.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class GoogleSignInApi {
  static String sessionID = '';
  static String userID = '';
  static String name = '';
  static String email = '';
  static int user_id = 0;
  final String clientID =
      '373597156492-u5e6nqr8alh2ucf4c5pe9f01tqjg0kce.apps.googleusercontent.com';
  static final _googleSignIn = GoogleSignIn(
      clientId:
          '373597156492-u5e6nqr8alh2ucf4c5pe9f01tqjg0kce.apps.googleusercontent.com');

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();

  static Future<GoogleSignInAccount?> logout() => _googleSignIn.disconnect();

  static Login() async {
    final user = await GoogleSignInApi.login();
    name = user!.displayName!;
    email = user.email;
    final gg = await user.authentication;
    userID = gg.idToken.toString();

    final response = await http.post(
      Uri.parse('https://thebuzzaws.herokuapp.com/oauth'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        // 'id_token': gg.idToken.toString(),
        'id_token': userID
      }),
    );

    if (response.body ==
        "<html><body><h2>500 Internal Server Error</h2></body></html>") {
      await GoogleSignInApi.logout();
      return false;
    }
    Map jsonObj = jsonDecode(response.body);

    user_id = jsonObj['mData'];
    // print(user_id);

    return true;
  }
}

class LoginRoute extends StatefulWidget {
  const LoginRoute({Key? key}) : super(key: key);

  @override
  _LoginRouteState createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  // GlobalKey gives unique identifier to our Form widget so that we can do text validation later

  @override
  Widget build(BuildContext context) {
    // using text controllers to check user input for message title and content
    final TextEditingController _ctrl1 = TextEditingController();
    final TextEditingController _ctrl2 = TextEditingController();
    Future<AddMessage>? _addedMessages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('THE BUZZ Login Page',
            style: TextStyle(fontFamily: 'Roboto')),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await GoogleSignInApi.logout();
              } catch (e) {}
              ;
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: FloatingActionButton.extended(
          onPressed: () async {
            // bool test = await GoogleSignInApi.Login();
            bool test = await GoogleSignInApi.Login();
            if (test) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            } else {
              Fluttertoast.showToast(
                  msg: "INVALID EMAIL OR PASSWORD",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          },
          icon: Icon(Icons.login),
          label:
              Text('Login with Google', style: TextStyle(fontFamily: 'Roboto')),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }
}
