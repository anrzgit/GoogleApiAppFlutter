import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gmail_clone/service/auth_service.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MailContent extends StatefulWidget {
  const MailContent({super.key, required this.messageId});

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
  String? subject;
  late String bodyHtml;
  late String mobileFriendlyHtml;
  bool _isLoading = false;
  late final WebViewController _controller;
  double webViewHeight = 300;
  var loadingPercentage = 0;

  ///
  @override
  void initState() {
    super.initState();
    fetchMailDetails(widget.messageId);
    _controller = WebViewController();
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  Future<void> fetchMailDetails(String messageId) async {
    try {
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

      // Find the subject header
      var subjectHeader =
          headers!.firstWhere((header) => header.name == 'Subject');

      // Get the subject
      subject = subjectHeader.value;

      // Find the from header
      var fromHeader = headers.firstWhere((header) => header.name == 'From');

      // Get the sender
      sender = fromHeader.value;

      ///
      var dateHeader = headers.firstWhere((header) => header.name == 'Date');

      date = dateHeader.value;

      ///
      print(333333333333);

      ///
      for (var part in parts!) {
        print('MIME type: ${part.mimeType}');
        print('Body: ${part.body}');

        if (part.mimeType == 'multipart/alternative' ||
            part.mimeType == 'multipart/mixed') {
          if (part.parts!.any((subpart) => subpart.mimeType == 'text/html')) {
            var bodyPart = part.parts!
                .firstWhere((subpart) => subpart.mimeType == 'text/html');
            var bodyData = bodyPart.body!.data;

            if (bodyData != null && bodyData.isNotEmpty) {
              String base64String =
                  bodyData.replaceAll('_', '/').replaceAll('-', '+');
              while (base64String.length % 4 != 0) {
                base64String += '=';
              }
              bodyHtml = utf8.decode(base64.decode(base64String));
            } else {
              print('bodyData is null or empty');
            }
          }
        } else if (part.mimeType == 'text/html') {
          var bodyData = part.body!.data;

          if (bodyData != null && bodyData.isNotEmpty) {
            String base64String =
                bodyData.replaceAll('_', '/').replaceAll('-', '+');
            while (base64String.length % 4 != 0) {
              base64String += '=';
            }
            bodyHtml = utf8.decode(base64.decode(base64String));
          } else {
            print('bodyData is null or empty');
          }
        }
      }

      ///

      print('Subject: $subject');
      print('Sender: $sender');
      print('Body: $bodyHtml');

      //making the html mobile friendly
      mobileFriendlyHtml =
          '<head><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>body { font-size: 20px; background-color: #EDE4E3; }</style></head>' +
              bodyHtml;

      setState(() {
        _isLoading = false;
        bodyHtml;
        //to load the html in webview
      });

      ///
      _controller.loadHtmlString(mobileFriendlyHtml);
      _controller.enableZoom(true);

      ///
      _controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            updateHeight();
            setState(() {
              loadingPercentage = 100;
            });
          },
        ),
      );
    } catch (e) {
      print("error $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  updateHeight() async {
    var height = await _controller
        .runJavaScriptReturningResult('document.documentElement.scrollHeight;');
    double webViewHeightViaHeight = double.parse(height.toString());
    if (webViewHeight != webViewHeightViaHeight) {
      setState(() {
        webViewHeight = webViewHeightViaHeight;
      });
    }
    print("height $height"); // prints height
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SizedBox(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('From: $sender '),
                            const SizedBox(
                              height: 8,
                            ),
                            Text('Date: $date'),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Subject: $subject',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: webViewHeight,
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        width: double.infinity,
                        color: Colors.pink[50],
                        child: Stack(
                          children: [
                            WebViewWidget(
                              controller: _controller,
                            ),
                            if (loadingPercentage < 100)
                              LinearProgressIndicator(
                                value: loadingPercentage / 100.0,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

////edit this