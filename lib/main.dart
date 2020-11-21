import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

const SERVER_IP = 'https://django-auth-token.herokuapp.com';

void main() => runApp(SignUp());

/// This is the main application widget.
class SignUp extends StatelessWidget {
  static const String _title = 'Sign Up';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: MyStatefulWidget(),
      ),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  File _image;

  Future<int> blankProfileSignUp(String username, String password,
      String firstname, String lastname) async {
    // Create user code
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse('$SERVER_IP/api/register/'));
    // var profileJson = jsonEncode({"phone_number":"", "profile_picture": null});
    var userJson = jsonEncode({
      "username": username,
      "first_name": firstname,
      "last_name": lastname,
      "password": password,
      "profile": {"phone_number": "", "profile_picture": null}
    });
    // print(profileJson);
    print(userJson.toString());
    request.body = userJson;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
    return response.statusCode;
  }

  Future<String> retrieveUserToken(String username, String password) async {
    var res = await http.post("$SERVER_IP/api-token-auth/",
        body: {"username": username, "password": password});
    if (res.statusCode == 200) {
      // var jsonSource = res.body;
      var tokenJson = json.decode(res.body);
      String token = tokenJson["token"];
      return token;
    } else {
      return null;
    }
  }

  Future<int> updateProfile(String token, String phoneNumber, String imagePath) async {
    var headers = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Token ' + token
    };
    var request = http.MultipartRequest('PUT', Uri.parse('$SERVER_IP/api/profile/'));
    request.fields.addAll({
      'phone_number': phoneNumber
    });
    request.files.add(await http.MultipartFile.fromPath('profile_picture', imagePath));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
    return response.statusCode;
  }

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget profileImageField(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 32,
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              _showPicker(context);
            },
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xffFDCF09),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.file(
                        _image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fitHeight,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(50)),
                      width: 100,
                      height: 100,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
            ),
          ),
        )
      ],
    );
  }

  Widget requiredFormField(
      TextEditingController controller, String hintString, String errorText) {
    return Container(
        child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintString,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return errorText;
        }
        return null;
      },
    ));
  }

  Widget passwordFormField() {
    return Container(
        child: TextFormField(
      obscureText: true,
      controller: _passwordController,
      decoration: const InputDecoration(
        hintText: 'Password',
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Password is required!';
        }
        return null;
      },
    ));
  }

  Widget retypePasswordFormField() {
    return Container(
        child: TextFormField(
      obscureText: true,
      decoration: const InputDecoration(
        hintText: 'Retype Password',
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please retype Password!';
        } else if (value != _passwordController.text) {
          return 'Passwords don\'t match';
        }
        return null;
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          profileImageField(context),
          requiredFormField(
              _usernameController, 'Username', 'Username is required!'),
          requiredFormField(
              _firstNameController, 'First Name', 'First name is required!'),
          requiredFormField(
              _lastNameController, 'Last Name', 'Last name is required!'),
          requiredFormField(_phoneNumberController, 'Phone Number',
              'Phone number is required!'),
          passwordFormField(),
          retypePasswordFormField(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                String token = "";
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState.validate()) {
                  // Process data.

                  await blankProfileSignUp(
                      _usernameController.text,
                      _passwordController.text,
                      _firstNameController.text,
                      _lastNameController.text);
                }
                token = await retrieveUserToken(_usernameController.text,
                    _passwordController.text);
                print(token);
                await updateProfile(token, _phoneNumberController.text,
                    _image.path);

              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
