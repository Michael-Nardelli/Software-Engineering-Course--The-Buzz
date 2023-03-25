import 'package:buzz_app/comments.dart';
import 'package:buzz_app/fourth_route.dart';
import 'package:buzz_app/main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'get_messages.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

int msgID = 0;
String user = '';

// second page: allows user to interact to add/create a message
class addCommentRoute extends StatefulWidget {
  addCommentRoute(int msgId, String inuser, {Key? key}) : super(key: key) {
    msgID = msgId;
    user = inuser;
  }

  @override
  _addCommentRouteState createState() => _addCommentRouteState();
}

class _addCommentRouteState extends State<addCommentRoute> {
  // GlobalKey gives unique identifier to our Form widget so that we can do text validation later
  final _formKey = GlobalKey<FormState>();
  File? image;
  int fileType = 0;
  String base64Image = "";
  String name = "Picture";

  Future pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final imageTemp = File(image.path);

    setState(() => this.image = imageTemp);
    print(image);
  }

  Future pickImageC() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);

    if (image == null) return;

    final imageTemp = File(image.path);

    setState(() => this.image = imageTemp);
    print(image);
  }

  @override
  Widget build(BuildContext context) {
    // using text controllers to check user input for message title and content
    final TextEditingController _ctrl1 = TextEditingController();
    Future<AddComment>? _addComments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Comment',
            style: TextStyle(fontFamily: 'Roboto')),
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

            //This is where I will do the same stuff to demonstrate pics that I did for the new message
            ElevatedButton(
              onPressed: () {
                // validate returns true if entire form is valid, else returns false
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Processing Data'),
                    ),
                  );
                  if (image != null) {
                    List<int> imageBytes = image!.readAsBytesSync();
                    print(imageBytes);
                    base64Image = base64Encode(imageBytes);
                  }

                  print(base64Image);

                  setState(() {
                    _addComments = addComment(
                        _ctrl1.text, user, msgID, fileType, name, base64Image);
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
            ElevatedButton(
              //This will use the photo gallery API
              onPressed: () {
                pickImage();
              },
              child: const Text('Insert From Gallery'),
            ),

            ElevatedButton(
              //This will use the photo gallery API
              onPressed: () {
                pickImageC();
              },
              child: const Text('Take Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
