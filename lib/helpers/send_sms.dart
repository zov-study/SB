import 'package:simple_sms/simple_sms.dart';


Future<void> sendSms(List<String> contacts, String smsBody) async {
    final SimpleSms simpleSms = SimpleSms();
    simpleSms.sendSms(contacts, smsBody);
}