import 'package:flutter/material.dart';
import 'package:oz/modules/root/root_page.dart';
import 'package:oz/modules/shops/shops_page.dart';
import 'package:oz/modules/customers/customers_page.dart';
import 'package:oz/modules/customers/subscribe/subscribe_page.dart';
import 'package:oz/modules/users/users_page.dart';
import 'package:oz/modules/about/about_page.dart';
import 'package:oz/modules/migration/convert_clients.dart';

class Routes {
  final BuildContext context;
  Routes(this.context);
  getRoutes() {
    return {
      '/': (context) => RootPage(),
      '/shops': (context) => ShopsPage(title: 'Shops'),
      '/subscribe': (context) => SubscribePage(title: 'SUBSCRIPTION FORM'),
      '/clients': (context) => CustomersPage(title: 'CUSTOMERS'),
      '/migrate': (context) => ConvertClientsPage(title: 'MIGRATION PAGE'),
      '/users': (context) => UsersPage(title: 'USERS LIST',),
      '/about': (context) => AboutPage(title: 'About'),
    };
  }
}
