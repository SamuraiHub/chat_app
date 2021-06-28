import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chat_app/SignUp.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:chat_app/Screens/Homescreen.dart';

import 'CustomUI/WindowButtons.dart';
import 'User.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'EPARW6nRAAyp5uehoDE7rBEby4wtehcZf9EayykS';
  final keyClientKey = 'fDaL2DjyC9YdwCwZ4RB5c5vhACROaMOO1EjjL4Zn';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  runApp(MyApp());

  doWhenWindowReady(() {
    final win = appWindow;
    final initialSize = Size(950, 700);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Chat App";
    win.show();
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Login',
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
                    child: Login(),
                  )
                ]))));
  }
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  late final User sourchat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Login Page',
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
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
          /*FlatButton(
              onPressed: () {
                //TODO FORGOT PASSWORD SCREEN GOES HERE
              },
              child: Text(
                'Forgot Password',
                style: TextStyle(color: Colors.blue, fontSize: 15),
              ),
            ),*/
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
                doUserLogin();

                //Navigator.push(
                //    context, MaterialPageRoute(builder: (_) => HomePage()));
              },
              child: Text(
                'Login',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
          ),
          SizedBox(
            height: 145,
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => SignUp()));
            },
            child: Text(
              'New User? Create Account',
              style: TextStyle(color: Colors.blue.shade500, fontSize: 25),
            ),
          ),
        ],
      ),
    );
  }

  void doUserLogin() async {
    final username = controllerUsername.text.trim();
    final password = controllerPassword.text.trim();

    final user = ParseUser(username.toLowerCase(), password, null);

    var response = await user.login();

    if (response.success) {
      sourchat =
          User(username, user.get('userID'), user.emailAddress.toString());
      showSuccess("User was successfully login!");
    } else {
      showError(response.error!.message);
    }
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
                    context,
                    MaterialPageRoute(
                        builder: (_) => Homescreen(
                              sourchat: sourchat,
                            )));
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
}
