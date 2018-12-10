import 'package:simple_sms/simple_sms.dart';


void main() {
  }

//  void _sendSMS(String message, List<String> recipents) async {
//     String _result =
//         await FlutterSms.sendSMS(message: message, recipients: recipents);
//     // setState(() => _message = _result);
//   }


Future<void> sendSms(List<String> contacts, String smsBody) async {
    final SimpleSms simpleSms = SimpleSms();
    simpleSms.sendSms(contacts, smsBody);
}