import 'package:flutter/material.dart';
import 'package:oz/settings/config.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  final String title;

  AboutPage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: app_color,
      ),
      body: Center(
        child: Container(
          child: Card(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 200.0,
                    ),
                    padding: EdgeInsets.all(10.0),
                  ),
                  Image.asset('assets/images/perfumes.jpg'),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      width: 300.0,
                      child: Text(
                        '''
                  We hunt the globe for affordable designer alternatives that make you feel a million dollars.  We always keep up to date with the what’s in style so that we can find beautiful fashionable, handbags and perfumes.
                  We source perfumes that not only smell amazing, they look amazing too. Our perfumes go through rigorous safety checks and 100% safe to wear.
                  ''',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Color.fromRGBO(8, 50, 79, 0.8),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: InkWell(
                      child: Text(
                        'Contact phone: 021 523 566\nEmail: eddie@smartbrands.co.nz',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: app_color,
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onTap: () async {
                        var url = 'tel:021523566';
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      },
                    ),
                  ),
                  Container(
                    color: Colors.grey[800],
                    padding: EdgeInsets.all(7.0),
                    child: InkWell(
                        child: Text(
                          '(c)2019 Design & Development O.Z., phone: +64 20 4148-9738',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onTap: () async {
                          var url =
                              'mailto:webaid@gmx.com?Subject=Mobile%20App%20enquiry.';
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
