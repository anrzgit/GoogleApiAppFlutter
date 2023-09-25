import 'package:flutter/material.dart';
import 'package:gmail_clone/screens/mail_content_screem.dart';
import 'package:gmail_clone/service/auth_service.dart';
import 'package:gmail_clone/service/mail_service.dart';
import 'package:googleapis/gmail/v1.dart';

class MailScreen extends StatefulWidget {
  const MailScreen({super.key});

  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  ///
  ///
  Future fetchMailId = MailService().fetchMailId();
  late final List _mailIDs = MailService().messageIds;
  late List _messageSubjectsToDisplay;
  bool _isLoading = false;

  ///
  ///if i initialise a future it will render only a time only
  late Future _future;

  ///

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    _future = refreshForMails();

    _messageSubjectsToDisplay = MailService().messageSubjects;
  }

  Future<dynamic> refreshForMails() async {
    // await AuthService().signInWithGoogle();
    await MailService().fetchMailId();
    _messageSubjectsToDisplay = MailService().messageSubjects;
  }

  Future<String> getSubject(String messageId) async {
    // Create a GmailApi object
    var gmailApi = GmailApi(httpClient);

    // Get the message details
    var messageDetails = await gmailApi.users.messages.get('me', messageId);

    // Access the message payload
    var payload = messageDetails.payload;
    // Access the message headers
    var headers = payload!.headers;

    // Find the subject header
    var subjectHeader =
        headers!.firstWhere((header) => header.name == 'Subject');
    // Get the subject
    var subject = subjectHeader.value!;
    // Add the subject to the list

    return subject;
  }

  ///Attachments

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: RefreshIndicator(
            onRefresh: () => refreshForMails(),
            child: FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: MailService().messageIds.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MailContent(
                          messageId: MailService().messageIds[index],
                        ),
                      ),
                    ),
                    child: Card(
                      margin:
                          const EdgeInsets.only(left: 10, right: 10, top: 10),
                      color: Theme.of(context).colorScheme.background,
                      key: ValueKey(MailService().messageIds[index]),
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        height: 80,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FutureBuilder<String>(
                            future: getSubject(_mailIDs[index]),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(snapshot.data!);
                              } else {
                                return const LinearProgressIndicator();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
