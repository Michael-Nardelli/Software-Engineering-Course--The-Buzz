// import 'package:buzz_app/comments.dart';
// import 'package:buzz_app/fourth_route.dart';
// import 'package:buzz_app/login_route.dart';
// import 'package:buzz_app/main.dart';
// import 'package:buzz_app/get_profile.dart';
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'get_messages.dart';

// // second page: allows user to interact to add/create a message
// class editBioRoute extends StatefulWidget {
//   editBioRoute({Key? key}) : super(key: key) {}

//   @override
//   _editBioState createState() => _editBioState();
// }

// class _editBioState extends State<editBioRoute> {
//   // GlobalKey gives unique identifier to our Form widget so that we can do text validation later
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     // using text controllers to check user input for message title and content
//     final TextEditingController _ctrl1 = TextEditingController();
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add a new Bio'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Column(
//           children: <Widget>[
//             TextFormField(
//               decoration: const InputDecoration(labelText: 'Bio'),
//               controller: _ctrl1,
//               // use controller to pass user input to validator function
//               // if user doesn't input a title, prompt them for text
//               // else if no errors, return null
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your new bio';
//                 }
//                 return null;
//               },
//             ),
//             // button that user can tap to submit their info & validates form
//             ElevatedButton(
//               onPressed: () {
//                 // validate returns true if entire form is valid, else returns false
//                 if (_formKey.currentState!.validate()) {
//                   // If the form is valid, display a snackbar. In the real world,
//                   // you'd often call a server or save the information in a database.
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Processing Data')),
//                   );
//                   setState(() {
//                     getProfile.updateBio(_ctrl1.text);
//                   });

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('SUCCESS')),
//                   );
//                 }
//               },
//               child: const Text('Submit'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
