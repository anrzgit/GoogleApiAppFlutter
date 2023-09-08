import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gmail_clone/service/auth_service.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MailContent extends StatefulWidget {
  const MailContent(
      {super.key, required this.subject, required this.messageId});
  final String subject;
  final String messageId;

  @override
  State<MailContent> createState() => _MailContentState();
}

class _MailContentState extends State<MailContent> {
  ///
  ///
  final httpClient = AuthService().getHttpClient();

  ///
  String? sender;
  String? date;
  late String bodyHtml;
  bool _isLoading = false;
  late final WebViewController _controller;

  ///
  @override
  void initState() {
    super.initState();
    fetchMailDetails(widget.messageId);
    _controller = WebViewController();
  }

  Future<void> fetchMailDetails(String messageId) async {
    print('mail fetch init');
    setState(() {
      _isLoading = true;
    });

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
    sender = fromHeader.value!;

    ///
    var dateHeader = headers.firstWhere((header) => header.name == 'Date');
    date = dateHeader.value;

    ///

    ///
    var bodyPart = parts!.firstWhere((part) => part.mimeType == 'text/html');
    var bodyData = bodyPart.body!.data;
    bodyHtml = utf8.decode(
        base64.decode(bodyData!.replaceAll('_', '/').replaceAll('-', '+')));

    ///

    print('Subject: $subject');
    print('Sender: $sender');
    print('Body: $bodyHtml');

    setState(() {
      _isLoading = false;
      bodyHtml;
      //to load the html in webview
      _controller.loadHtmlString(bodyHtml);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From: $sender '),
                    Text('Date: $date'),
                    const SizedBox(height: 10),
                    Text(widget.subject,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Expanded(
                      child: Container(
                          width: double.infinity,
                          color: Colors.pink[50],
                          child: WebViewWidget(controller: _controller)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
