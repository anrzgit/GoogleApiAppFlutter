import 'package:flutter/material.dart';
import 'package:gmail_clone/screens/mail_content_screem.dart';
import 'package:gmail_clone/service/auth_service.dart';
import 'package:gmail_clone/service/mail_service.dart';

class MailScreen extends StatefulWidget {
  const MailScreen({super.key});

  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  ///
  ///
  Future fetchMailId = MailService().fetchMailId();
  late List _messageSubjectsToDisplay;

  ///
  late Future _future;

  ///

  @override
  void initState() {
    super.initState();
    _future = refreshForMails();

    _messageSubjectsToDisplay = MailService().messageSubjects;
    setState(() {
      _messageSubjectsToDisplay;
    });
  }

  Future<dynamic> refreshForMails() async {
    await AuthService().signInWithGoogle();
    await MailService().fetchMailId();
    _messageSubjectsToDisplay = MailService().messageSubjects;
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
              builder: (context, snapshot) => ListView.builder(
                itemCount: MailService().messageIds.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MailContent(
                        subject: MailService().messageSubjects[index],
                        messageId: MailService().messageIds[index],
                      ),
                    ),
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
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
                        child: Text(
                          MailService().messageSubjects[index],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
