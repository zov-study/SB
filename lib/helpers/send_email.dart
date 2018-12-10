// import 'package:mailer/mailer.dart';

// void main(){
//   sendEmail('eddie@smartbrands.co.nz',['zov-study@gmx.com','zov-fx@gmx.com'],'Text email!','Dear Wizard...');
// }

// bool sendEmail(String from, List<String> bcc, String subject, String body){
//   // If you want to use an arbitrary SMTP server, go with `new SmtpOptions()`.
//   // This class below is just for convenience. There are more similar classes available.
//   var options = new  SmtpOptions()
//     ..hostName = 'smtp.ihug.co.nz'
//     ..port = 25;
//     // ..username = 'eddie@smartbrands.co.nz'
//     // ..password = 'Tiger9778'; // Note: if you have Google's "app specific passwords" enabled,
//   // you need to use one of those here.

//   // How you use and store passwords is up to you. Beware of storing passwords in plain.

//   // Create our email transport.
//   var emailTransport = new SmtpTransport(options);

//   // Create our mail/envelope.
//   var envelope = new Envelope()
//     ..from = from
//     ..bccRecipients.addAll(bcc)
//     ..subject = subject
//     ..text = body;

//   // Email it.
//   emailTransport.send(envelope)
//       .then((envelope) => print('Email sent!'))
//       .catchError((e) {
//         print('Error occurred: $e');
//         printDebugInformation();
//       });
//   return true;
// }