import 'package:buzz_app/comments.dart';
import 'package:buzz_app/fourth_route.dart';
import 'package:buzz_app/main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'get_messages.dart';
import 'Messages.dart';

int msgID = 0;
String user = '';
int? commentID = 0;

// second page: allows user to interact to add/create a message
class editCommentRoute extends StatefulWidget {
  editCommentRoute(int msgId, String inuser, int? incommentID, {Key? key})
      : super(key: key) {
    msgID = msgId;
    user = inuser;
    commentID = incommentID;
  }

  @override
  _editCommentRouteState createState() => _editCommentRouteState();
}

class _editCommentRouteState extends State<editCommentRoute> {
  // GlobalKey gives unique identifier to our Form widget so that we can do text validation later
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // using text controllers to check user input for message title and content
    final TextEditingController _ctrl1 = TextEditingController();
    Future<bool> sameUser;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Edit Comment', style: TextStyle(fontFamily: 'Roboto')),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Comment'),
              style: TextStyle(fontFamily: 'Roboto'),
              controller: _ctrl1,
              // use controller to pass user input to validator function
              // if user doesn't input a title, prompt them for text
              // else if no errors, return null
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a comment';
                }
                return null;
              },
            ),
            // button that user can tap to submit their info & validates form
            ElevatedButton(
              onPressed: () {
                // validate returns true if entire form is valid, else returns false
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                  setState(() {
                    // print("comment editing");
                    // print(user + " " + msgID.toString());
                    sameUser = editComment(msgID, commentID, _ctrl1.text);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SUCCESS')),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FourthRoute(msgID)),
                  );
                }
              },
              child:
                  const Text('Submit', style: TextStyle(fontFamily: 'Roboto')),
            ),
          ],
        ),
      ),
    );
  }
}
