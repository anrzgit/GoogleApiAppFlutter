import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gmail_clone/service/auth_service.dart';

class PhoneNumberSignIn extends StatefulWidget {
  const PhoneNumberSignIn({super.key});

  @override
  _PhoneNumberSignInState createState() => _PhoneNumberSignInState();
}

class _PhoneNumberSignInState extends State<PhoneNumberSignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();

  String _verificationId = '';
  bool _isSMSCodeSent = false;

  void _verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91${_phoneNumberController.text}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
    setState(() {
      _isSMSCodeSent = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent'),
        ),
      );
    });
  }

  void _signInWithPhoneNumber() async {
    await AuthService()
        .signInWithPhoneNumber(_verificationId, _smsController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).primaryColorLight,
      ),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _phoneNumberController,
            decoration: const InputDecoration(
              hintText: '+91',
              labelText: 'Do not add +91',
            ),
          ),
          TextField(
            controller: _smsController,
            decoration: const InputDecoration(
              labelText: 'SMS Code',
            ),
          ),
          _isSMSCodeSent
              ? TextButton(
                  onPressed: _signInWithPhoneNumber,
                  child: const Text('Sign in '),
                )
              : TextButton(
                  onPressed: _verifyPhoneNumber,
                  child: const Text('Send OTP'),
                ),
        ],
      ),
    );
  }
}
