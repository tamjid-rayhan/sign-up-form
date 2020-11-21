
// Create user code
import 'package:flutter/cupertino.dart';

var headers = {
  'Content-Type': 'application/json'
};
var request = http.Request('POST', Uri.parse('https://django-auth-token.herokuapp.com/api/register/'));
request.body = '''{\r\n    "username": "Ron",\r\n    "first_name": "",\r\n    "last_name": "",\r\n    "password": "qwerty",\r\n    "profile": {\r\n        "phone_number": "",\r\n        "profile_picture": null\r\n    }\r\n}''';
request.headers.addAll(headers);

http.StreamedResponse response = await request.send();

if (response.statusCode == 200) {
print(await response.stream.bytesToString());
}
else {
print(response.reasonPhrase);
}

// Multipart request for profile update
var headers = {
  'Content-Type': 'multipart/form-data',
  'Authorization': 'Token e40d4b974a94bed7c954a6dd2dcdbce00fc978ac'
};
var request = http.MultipartRequest('PUT', Uri.parse('https://django-auth-token.herokuapp.com/api/profile/'));
request.fields.addAll({
'phone_number': '1234'
});
request.files.add(await http.MultipartFile.fromPath('profile_picture', '/path/to/file'));
request.headers.addAll(headers);

http.StreamedResponse response = await request.send();

if (response.statusCode == 200) {
print(await response.stream.bytesToString());
}
else {
print(response.reasonPhrase);
}