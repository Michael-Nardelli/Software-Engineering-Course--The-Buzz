import 'package:buzz_app/main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'get_messages.dart';
import 'login_route.dart';
import 'main.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:cache_manager/cache_manager.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// second page: allows user to interact to add/create a message
class SecondRoute extends StatefulWidget {
  const SecondRoute({Key? key}) : super(key: key);

  @override
  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
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
    final TextEditingController _ctrl2 = TextEditingController();
    Future<AddMessage>? _addedMessages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Message',
            style: TextStyle(fontFamily: 'Roboto')),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
              style: TextStyle(fontFamily: 'Roboto'),
              controller: _ctrl1,
              // use controller to pass user input to validator function
              // if user doesn't input a title, prompt them for text
              // else if no errors, return null
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Message'),
              style: TextStyle(fontFamily: 'Roboto'),
              controller: _ctrl2,
              // validator receives the text that the user entered
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a message';
                }
                return null;
              },
            ),
            // button that user can tap to submit their info & validates form
            /// Returns a suitable camera icon for [direction].
            ///
            ///

            ElevatedButton(
              onPressed: () {
                // validate returns true if sentire form is valid, else returns false
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                  if (image != null) {
                    List<int> imageBytes = image!.readAsBytesSync();
                    print(imageBytes);
                    base64Image = base64Encode(imageBytes);
                  }
                  print(base64Image);

                  setState(() {
                    _addedMessages = addMsg(_ctrl1.text, GoogleSignInApi.userID,
                        _ctrl2.text, fileType, name, base64Image);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SUCCESS')),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                }
              },
              child: const Text('Submit'),
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

            // ElevatedButton(
            //   //This will use the camera API
            //   onPressed: () async {
            //     await availableCameras().then(
            //       (value) => Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => CameraPage(
            //             cameras: value,
            //           ),
            //         ),
            //       ),
            //     );
            //   },
            //   child: const Text('Take Photo'),
            // ),

            // ElevatedButton(
            //   //This will use the camera API
            //   onPressed: () => pickImage(),
            //   child: const Text('Take Photo'),
            // ),
          ],
        ),
      ),
    );
  }
}
