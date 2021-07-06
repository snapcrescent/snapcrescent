import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/resository/app_config_resository.dart';
import 'package:snap_crescent/screens/sync_process/sync_process.dart';
import 'package:snap_crescent/utils/constants.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Snap Crescent'),
          centerTitle: true,
        ),
        body: _LoginScreenView());
  }
}

class _LoginScreenView extends StatefulWidget {
  @override
  _LoginScreenViewState createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<_LoginScreenView> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.onUserInteraction;

  final RegExp _urlRegex = RegExp(
      r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?",
      caseSensitive: false);

  TextEditingController serverURLController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  _onLoginPressed() {
    AppConfig serverUrlConfig = new AppConfig(
        configkey: Constants.appConfigServerURL,
        configValue: serverURLController.text);

    AppConfigResository.instance.saveOrUpdateConfig(serverUrlConfig).then((value) =>
        {Navigator.pushReplacementNamed(context, SyncProcessScreen.routeName)});
  }

  _showValidationErrors() {
    Fluttertoast.showToast(
        msg: "Please fix the errors",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: ListView(children: <Widget>[
                      Expanded(
                          child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Sign in',
                                style: TextStyle(fontSize: 20),
                              ))),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          autovalidateMode: _autovalidateMode,
                          controller: serverURLController,
                          validator: (v) {
                            if (v!.length > 0 && _urlRegex.hasMatch(v)) {
                              return null;
                            } else {
                              return 'Please enter a valid url';
                            }
                          },
                          decoration: InputDecoration(labelText: 'Server URL'),
                        ),
                      )),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.all(10),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'User Name',
                          ),
                        ),
                      )),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: TextField(
                          obscureText: true,
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                          ),
                        ),
                      )),
                      Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: ElevatedButton(
                            child: Text("Login"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _onLoginPressed();
                              } else {
                                _showValidationErrors();
                                setState(() {
                                  _autovalidateMode = AutovalidateMode.always;
                                });
                              }
                            },
                          ))
                    ])))
          ],
        ));
  }
}
