import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gmail_clone/service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/gmail/v1.dart';

/// Provides the `YouTubeApi` class.
import 'package:googleapis/youtube/v3.dart';

class MailScreen extends StatefulWidget {
  const MailScreen({super.key});

  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  static const String userId = 'me';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Mail Screen'),
          ],
        ),
      ),
    );
  }
}
