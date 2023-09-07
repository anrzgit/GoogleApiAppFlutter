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
  var messageIds = [];

  @override
  void initState() {
    super.initState();
    fetchMailId();
  }

  Future<void> fetchMailId() async {
    print('gmail fetch Start');
    final httpClient = AuthService().getHttpClient();
    var gmailApi = GmailApi(httpClient);
    var messages = await gmailApi.users.messages.list('me');

    print(messages);
    setState(() {
      messageIds = messages.messages!.map((e) => e.id).toList();
    });
    print('gmail fetch end');
    print(messageIds);
    fetchMail(messageIds[0]);
    // accessHtmlBody(messageIds[0]);
  }

  Future<void> fetchMail(String messageId) async {
    print('mail fetch init');
    final httpClient = AuthService().getHttpClient();
    var gmailApi = GmailApi(httpClient);
    // Get the message details
    var messageDetails = await gmailApi.users.messages.get('me', messageId);

    // Access the message payload
    var payload = messageDetails.payload;

    print("payload,$payload");
    // Access the message headers
    var headers = payload!.headers;
    // Access the message parts
    var parts = payload.parts;

    print("headers,$headers");

    // Find the part containing the message body

    // Find the subject header
    var subjectHeader =
        headers!.firstWhere((header) => header.name == 'Subject');
    // Get the subject
    var subject = subjectHeader.value;

    // Find the from header
    var fromHeader = headers.firstWhere((header) => header.name == 'From');
    // Get the sender
    var sender = fromHeader.value;

    ///
    var bodyPart = parts!.firstWhere((part) => part.mimeType == 'text/plain');
    var bodyData = bodyPart.body!.data;
    var bodyText = utf8.decode(
        base64.decode(bodyData!.replaceAll('_', '/').replaceAll('-', '+')));

    ///

    print('Subject: $subject');
    print('Sender: $sender');
    print('bodyText: $bodyText');
  }

  Future<void> accessHtmlBody(String messageId) async {
//     final httpClient = AuthService().getHttpClient();
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
    return Scaffold(
      body: Container(
        color: Colors.pink[50],
        width: double.infinity,
        child: ListView.builder(
          itemCount: messageIds.length,
          itemBuilder: (context, index) => Card(
            key: ValueKey(messageIds[index]),
            child: SizedBox(
              height: 50,
              child: Text(
                messageIds[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
