import 'Home_Page.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AuthPage extends StatelessWidget {
  final LocalAuthentication localAuth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () async {
          bool weCanCheckBiometrics = await localAuth.canCheckBiometrics;

          if (weCanCheckBiometrics) {
            bool authenticated = await localAuth.authenticateWithBiometrics(
              localizedReason: "Authenticate to see your photo.",
            );

            if (authenticated) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            }
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: RaisedButton(
                onPressed: () {

                },
                child: Text('Enter pin to Login'),
              ),
            ),
            Icon(
              Icons.fingerprint,
              size: 70.0,
            ),
            Text("Touch to Login", textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}