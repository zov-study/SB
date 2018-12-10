import 'package:url_launcher/url_launcher.dart';

void main(){
  sendEmail('zov-study@gmx.com;zov-fx@gmx.com','Text email!','Dear Wizard...');
}

Future<void> sendEmail(String bcc, String subject, String body) async{
    String url = 'mailto:?bcc=$bcc&subject=$subject&body=$body';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }

}