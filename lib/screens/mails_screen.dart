import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gmail_clone/screens/mail_content_screem.dart';
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
  var messageIds = [];
  late List messageSubjects = [];
  final httpClient = AuthService().getHttpClient();
  // String? subject;
  // String? sender;

  @override
  void initState() {
    super.initState();

    AuthService().signInWithGoogle();
  }

  Future fetchMailId() async {
    try {
      print('gmail fetch Start');
      print(1111111111111111111);

      var gmailApi = GmailApi(httpClient);
      print(22222222222222222);
      var messages = await gmailApi.users.messages.list('me', maxResults: 40);
      await getSubject(messages);

      print(messages);

      ///
      // setState(() {
      //   messageIds = messages.messages!.map((e) => e.id).toList();
      // });
      messageIds = messages.messages!.map((e) => e.id).toList();

      ///
      print('gmail fetch end');

      // setState(() {
      //   _isLoading;
      // });
      return messageIds;
    } catch (e) {
      print('error in fetchMailId $e');
    }
  }

  Future getSubject(ListMessagesResponse messages) async {
    for (var message in messages.messages!) {
      // Get the message ID
      var messageId = message.id;

      var gmailApi = GmailApi(httpClient);

      // Get the message details
      var messageDetails = await gmailApi.users.messages.get('me', messageId!);

      // Access the message payload
      var payload = messageDetails.payload;
      // Access the message headers
      var headers = payload!.headers;

      // Find the subject header
      var subjectHeader =
          headers!.firstWhere((header) => header.name == 'Subject');
      // Get the subject
      var subject = subjectHeader.value;

      // Add the subject to the list
      messageSubjects.add(subject);
    }

    ///

    ///
  }

  ///Attachments
  Future<void> accessHtmlBody(String messageId) async {
//     var gmailApi = GmailApi(httpClient);
//     var messageDetails = await gmailApi.users.messages.get('me', messageId);

// // Access the message payload
//     var payload = messageDetails.payload;
// // Access the message parts
//     var parts = payload!.parts;

// // Find the part containing the HTML body
//     var htmlPart = parts!.firstWhere((part) => part.mimeType == 'text/html');
// // Get the body data
//     var htmlData = htmlPart.body!.data;

// // Decode the body data
//     var htmlText = utf8.decode(
//         base64.decode(htmlData!.replaceAll('_', '/').replaceAll('-', '+')));

// // Find the attachment parts
//     var attachmentParts = parts
//         .where((part) => part.filename != null && part.filename!.isNotEmpty);
// // Get the attachment IDs
//     var attachmentIds =
//         attachmentParts.map((part) => part.body!.attachmentId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
          future: fetchMailId(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    Container(
                      margin: const EdgeInsets.only(top: 200),
                      child: const Align(
                        alignment: Alignment.topCenter,
                        child: Text('Loading Your Mails...'),
                      ),
                    )
                  ],
                ),
              );
            }
            return SizedBox(
              width: double.infinity,
              child: ListView.builder(
                itemCount: messageIds.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MailContent(
                        subject: messageSubjects[index],
                        messageId: messageIds[index],
                      ),
                    ),
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                    color: Theme.of(context).colorScheme.background,
                    key: ValueKey(messageIds[index]),
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      height: 80,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          messageSubjects[index],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
