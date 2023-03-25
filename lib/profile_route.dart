import 'package:buzz_app/editBio.dart';
import 'package:buzz_app/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'get_messages.dart';
import 'get_profile.dart';
import 'login_route.dart';

int user = 0;
String profEmail = Profile.profEmail.toString();

// third page: allows user to view his/her profile and edit bio
class profileRoute extends StatefulWidget {
  profileRoute(int mUserId, {Key? key}) : super(key: key) {
    user = mUserId;
  }

  @override
  _profileRouteState createState() => _profileRouteState();
}

class _profileRouteState extends State<profileRoute> {
  // GlobalKey gives unique identifier to our Form widget so that we can do text validation later
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // getProfile data = getProfile();
    late Future<Profile> test = getProfile.fetchProfile(user.toString());
    String data = '';
    // profEmail=Profile.profEmail.toString();
    // using text controllers to check user input for message title and content
    // final TextEditingController _ctrl1 = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontFamily: 'Roboto')),
      ),
      body: Center(
          // padding: const EdgeInsets.all(50),
          child: Column(children: [
        //<Widget>

        const Icon(Icons.account_circle_outlined, size: 100),
        const Padding(padding: const EdgeInsets.all(20)),

        FutureBuilder<Profile>(
          // need to access data returned by our future async functions
          // with future builder and snapshot
          future: test,
          builder: (context, snapshot) {
            // if our function retrieved data successfully, return the message content
            // print(snapshot.data);
            if (snapshot.hasData) {
              // profEmail='';
              // profEmail=snapshot.data!.mMessage;
              // print(profEmail);
              return Text(snapshot.data!.mEmail,
                  style: TextStyle(fontFamily: 'Roboto'));
              // return _buildMsgList(snapshot.data);

              // else if there was an error, return error message
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // show a loading spinner as default value while waiting
            return const CircularProgressIndicator();
          },
        ),
        const Padding(padding: const EdgeInsets.all(20)),

        // FutureBuilder<Profile>(
        //   // need to access data returned by our future async functions
        //   // with future builder and snapshot
        //   future: test,
        //   builder: (context, snapshot) {
        //     // if our function retrieved data successfully, return the message content
        //     if (snapshot.hasData) {
        //       // print(snapshot.data);
        //       if (snapshot.data!.mData) {
        //         return Text("This is the admin account");
        //       }
        //       return Text("This is not the admin account");
        //       // return _buildMsgList(snapshot.data);

        //       // else if there was an error, return error message
        //     } else if (snapshot.hasError) {
        //       return Text('${snapshot.error}');
        //     }
        //     // show a loading spinner as default value while waiting
        //     return const CircularProgressIndicator();
        //   },
        // ),

        const Padding(padding: const EdgeInsets.all(20)),
        Builder(builder: (BuildContext context) {
          // print("y " + GoogleSignInApi.email + " gg " + profEmail);
          if (GoogleSignInApi.email == profEmail.toString()) {
            // print("x " + GoogleSignInApi.name);
            return Text(
              GoogleSignInApi.name,
              style: TextStyle(fontFamily: 'Roboto'),
            );
          }
          return Text("");
        }),
        FutureBuilder<Profile>(
          // need to access data returned by our future async functions
          // with future builder and snapshot
          future: test,
          builder: (context, snapshot) {
            // if our function retrieved data successfully, return the message content
            if (snapshot.hasData) {
              // print(snapshot.data);
              // test = getProfile.fetchProfile(user.toString());
              return Text(snapshot.data!.name.toString(),
                  style: TextStyle(fontFamily: 'Roboto'));
              // else if there was an error, return error message
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // show a loading spinner as default value while waiting
            return const CircularProgressIndicator();
          },
        ),
      ])),
      // floatingActionButton: FloatingActionButton(
      //     onPressed: () {
      //       if (GoogleSignInApi.user_id == user) {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => editBioRoute()),
      //         );
      //       } else {
      //         Fluttertoast.showToast(
      //             msg: "NO PERMISSION",
      //             toastLength: Toast.LENGTH_SHORT,
      //             gravity: ToastGravity.BOTTOM,
      //             timeInSecForIosWeb: 1,
      //             backgroundColor: Colors.red,
      //             textColor: Colors.white,
      //             fontSize: 16.0);
      //       }
      //     },
      //     tooltip: 'Update your bio',
      //     child: const Icon(Icons.edit)),
    );
  }
}
