import 'package:flutter/material.dart';
import 'package:gmail_clone/service/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;

  void loginUser() {
    setState(() {
      _isLoading = true;
    });
    AuthService().signInWithGoogle().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Column(
          children: [
            const Spacer(flex: 2),
            ElevatedButton(
              onPressed: () => loginUser(),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Sign in with Google'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
