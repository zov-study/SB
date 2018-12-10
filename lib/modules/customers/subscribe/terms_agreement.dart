import 'package:flutter/material.dart';
import 'package:oz/settings/config.dart';

Widget termsAgreement(Function callback) {
  return AlertDialog(
    title: Text(
      "Terms and Conditions",
      style: TextStyle(
          color: Colors.blueGrey, decoration: TextDecoration.underline),
    ),
    content: Container(
      child: SingleChildScrollView(
        child: Text(
          '''
  This privacy policy explains how we may collect, store, use, and disclose any personal information that you provide to us when using this website. Your continued use of this website provides your unconditional consent to us collecting, storing, using, and disclosing your personal information in the manner set out below. This privacy policy is subject to, and must be read in conjunction with, our Terms of Use.
General

  In this privacy policy ‘we’, ‘us’, and ‘our’ refers to the SmartBrands.

Collection

  We may collect your personal information (including, without limitation, your name, email address, phone number, and postal address) when you use this website.  You may decide not to provide your personal information to us. However, if you do not provide it, we may not be able to provide you with access to certain information or services.

Automated collection

  When you visit our website, we may use automated technology (such as usage monitoring software, cookies, and sessions) to collect and store certain information about your visit. Please see the Cookies for more information.

Use and disclosure

  We will not use or disclose your personal information except in accordance with the New Zealand Privacy Act 1993.  We may use your personal information to:

verify your identity and to assist you if you forget your username or password for any of the services we provide to you via the Internet;
communicate with you;
analyse usage of this website;
provide you with further information, news, and promotional material; and
improve the content of this website and to customise this website to your preferences.
  We will not sell, rent, or lease your personal information to third parties.  Your personal information will be made available internally for the above purposes and we may also disclose your personal information to third parties, who have agreed to treat your personal information in accordance with this privacy policy, for similar purposes. By providing us with your personal information, you consent to our using and disclosing your personal information in the manner set out above.

  We will only use or disclose personal information that you have provided to us, or which we have obtained about you:
  
for the above-mentioned purposes;

if you have authorised us to do so;
if we have given you notification of the intended use or disclosure and you have not objected to that use or disclosure;
if we believe that the use or disclosure is reasonably necessary to assist a law enforcement agency or an agency responsible for national security in the performance of their functions;
if we believe that the use or disclosure is reasonably necessary to enforce any legal rights we may have, or is reasonably necessary to protect the rights, property and safety of us, our customers, or others; or
if we are authorised, required or permitted by law to disclose the information.
Storage and security
  Personal information collected on this website is collected and held by Tourism New Zealand. We will take reasonable efforts to protect personal information that is held by us from loss, misuse, unauthorised access, disclosure, alteration, or destruction.   

Third party websites
  This website may contain hyperlinks to third party websites. We are not responsible for the content of such websites, or for the manner in which those websites collect, hold, use, and distribute any personal information you provide.  When visiting a third party website from hyperlinks displayed on this website, we encourage you to review the privacy statements of those websites so that you can understand how the personal information you provide will be will collected, held, used and distributed.  

Right to access and correct
  You may request access to, or correction of, any personal information we hold about you by contacting our privacy officer at privacypolicy@tnz.govt.nz

  To ensure that the personal information we hold about you is accurate and current, please notify us of any changes to your personal information as soon as possible.

Changes to our Privacy Policy

  We reserve the right, at our discretion, to update or revise this privacy policy at any time. Changes to this privacy policy will take effect immediately once published on this website.  Please check this privacy policy regularly for modifications and updates.  If you continue to use this website or if you provide any personal information after we post changes to this privacy policy, this will indicate your acceptance of any such changes.

  
This privacy policy was last updated on 07 May 2018.


    ''',
          softWrap: true,
          textAlign: TextAlign.justify,
        ),
      ),
    ),
    actions: <Widget>[
      RaisedButton(
        color: app_color,
        child: Text(
          'Agree',
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        onPressed: (() {
          callback();
        }),
      )
    ],
  );
}
