import 'package:flutter_email_sender/flutter_email_sender.dart';

void main(){
  sendEmail('eddie@smartbrands.co.nz',['zov-study@gmx.com','zov-fx@gmx.com'],'Text email!','Dear Wizard...');
}

Future<String> sendEmail(String from, List<String> bcc, String subject, String body) async{
    final Email email = Email(
      body: body,
      subject: subject,
      recipients: bcc,
      // attachmentPath: attachment,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      platformResponse = error.toString();
    }
  return platformResponse;
}