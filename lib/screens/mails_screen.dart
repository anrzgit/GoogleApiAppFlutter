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

  Future<void> fetchMail() async {
    // print('mail fetch init');
    // final httpClient = await AuthService().httpClient();
    // print(httpClient);
    // final gmailApi = GmailApi(httpClient);
    // final messages = await gmailApi.users.messages.list('me');
    // for (final message in messages.messages!) {
    //   final fullMessage = await gmailApi.users.messages.get('me', message.id!);
    //   print(fullMessage.snippet);
    // }
  }

  void fetchYoutube() async {
    print('youtube fetch init');
    final httpClient = AuthService().getHttpClient();
    print("httpClient in fetch youtube $httpClient");
    var youTubeApi = YouTubeApi(httpClient);
    var favorites = await youTubeApi.playlistItems.list(
      ['snippet'],
      playlistId: 'LL', // Liked List
    );
    var favoriteVideos = favorites.items!.map((e) => e.snippet!.title).toList();
    print('youtube fetch end');
    print(favoriteVideos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Mail Screen'),
            ElevatedButton(
              onPressed: () => fetchMail(),
              child: const Text('Fetch Mails'),
            ),
            ElevatedButton(
              onPressed: () => fetchYoutube(),
              child: const Text('Fetch youtube'),
            ),
          ],
        ),
      ),
    );
  }
}
