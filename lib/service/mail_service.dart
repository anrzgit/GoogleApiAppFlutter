import 'package:gmail_clone/service/auth_service.dart';
import 'package:googleapis/gmail/v1.dart';

var _messageIds = [];
var _messageSubjects = [];
final _httpClient = AuthService().getHttpClient();

class MailService {
  Future fetchMailId() async {
    try {
      print('gmail fetch Start');
      print(1111111111111111111);

      var gmailApi = GmailApi(httpClient);
      print(22222222222222222);
      var messages = await gmailApi.users.messages.list('me', maxResults: 40);
      await getSubject(messages);

      print(messages);

      _messageIds = messages.messages!.map((e) => e.id).toList();

      ///
      print('gmail fetch end');

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
      print("messageSubjects $_messageSubjects");
    }
  }

  List<dynamic> get messageIds => _messageIds;
  List<dynamic> get messageSubjects => _messageSubjects;

  ///Attachments
  // Future<void> accessHtmlBody(String messageId) async {
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
  // }
}
