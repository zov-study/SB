import 'package:url_launcher/url_launcher.dart';

void main(){
  sendSMS('00121255;11564156','Dear Wizard...');
}

Future<void> sendSMS(String phones, String message) async{
    String url = 'sms:$phones&body=$message';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }

}