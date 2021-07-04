import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:chat_app/main.dart';
import 'package:path_provider/path_provider.dart';
import 'CustomUI/WindowButtons.dart';
import 'RSAUtils.dart';

class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SignUp',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
            body: WindowBorder(
                color: Color(0xFF805306),
                width: 1,
                child: Column(children: <Widget>[
                  Container(
                    height: 35,
                    color: Colors.blue,
                    child: WindowTitleBarBox(
                        child: Row(children: [
                      Expanded(
                          child: MoveWindow(
                              child: Row(
                        children: <Widget>[
                          Image.asset(
                            'assets/icons8-chat-96.jpg',
                            scale: 0.5,
                          ),
                          Text(
                            'Chat App',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          )
                        ],
                      ))),
                      WindowButtons()
                    ])),
                  ),
                  Expanded(
                    child: signUp(),
                  )
                ]))));
  }
}

class signUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<signUp> {
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerPasswordR = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'SignUp Page',
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 30, bottom: 0),
            child: TextField(
              controller: controllerUsername,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                  hintText: 'Enter your username'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 15, bottom: 0),
            child: TextField(
              controller: controllerEmail,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Enter your Email'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 15, bottom: 0),
            //padding: EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              controller: controllerPassword,
              obscureText: true,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter secure password'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 15, bottom: 0),
            //padding: EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              controller: controllerPasswordR,
              obscureText: true,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Repeat Password',
                  hintText: 'Enter same password'),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Container(
            height: 50,
            width: 250,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(20)),
            child: TextButton(
              onPressed: () {
                doUserRegistration();

                //Navigator.push(
                //    context, MaterialPageRoute(builder: (_) => HomePage()));
              },
              child: Text(
                'Sign Up',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
          ),
          SizedBox(
            height: 65,
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => MyApp()));
            },
            child: Text(
              'Already have an account? Login',
              style: TextStyle(color: Colors.blue.shade500, fontSize: 25),
            ),
          ),
        ],
      ),
    );
  }

  void showSuccess(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success!"),
          content: Text(message),
          actions: <Widget>[
            new TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => MyApp()));
              },
            )
          ],
        );
      },
    );
  }

  void showError(String errorMessage) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: Text(errorMessage),
          actions: <Widget>[
            new TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void doUserRegistration() async {
    //signup code here
    final username = controllerUsername.text.trim();
    final email = controllerEmail.text.trim();
    final password = controllerPassword.text.trim();
    final passwordr = controllerPasswordR.text.trim();

    if (email.isEmpty) {
      showError("Email Address cannot be empty!");
      return;
    }

    if (email.contains('@') == false) {
      showError("Not a valid Email Address!");
      return;
    }

    if (password != passwordr) {
      showError("Passwords Must Match!");
    } else {
      final user = ParseUser.createUser(
          username.toLowerCase(), password, email.toLowerCase());

      var response = await user.signUp();

      if (response.success) {
        QueryBuilder<ParseUser> UserQuery =
            QueryBuilder<ParseUser>(ParseUser.forQuery())
              ..orderByDescending('userID');

        int maxUserId = 0;

        var apiResponse = await UserQuery.query();
        if (apiResponse.success && apiResponse.result != null) {
          //print(apiResponse.results![0]);
          maxUserId = apiResponse.results![0]['userID'];
          //print(countUsers);
        }

        var userid = user
          ..set('userID', maxUserId + 1)
          ..set('EmailAddress', email);
        response = await userid.save();

        if (response.success) {
          showSuccess('User was successfully Registered!');

          /*var list = RSAUtils.generateKeys(1024);

          var userid = user..set('publicKey', list[0]);
          response = await userid.save();

          if (response.success) {
            final Directory directory =
                await getApplicationDocumentsDirectory();

            File file = File('${directory.path}/my_publicKey.pem');
            await file.writeAsString(list[0]);

            file = File('${directory.path}/my_privateKey.pem');
            await file.writeAsString(list[1]);

            showSuccess('User was successfully Registered!');
          } else {
            showError(response.error!.message);
          }*/
        } else
          showError(response.error!.message);
      } else {
        showError(response.error!.message);
      }
    }
  }
}
