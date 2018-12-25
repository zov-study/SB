import 'package:flutter/material.dart';
import 'package:oz/modules/root/root_page.dart';
import 'package:oz/modules/shops/shops_page.dart';
import 'package:oz/modules/customers/customers_page.dart';
import 'package:oz/modules/customers/subscribe/subscribe_page.dart';
import 'package:oz/modules/categories/categories_page.dart';
import 'package:oz/modules/stock/stock_page.dart';
import 'package:oz/modules/users/users_page.dart';
import 'package:oz/modules/about/about_page.dart';
import 'package:oz/modules/migration/convert_clients.dart';

class Routes {
  final BuildContext context;
  Routes(this.context);
  getRoutes() {
    return {
      '/': (context) => RootPage(),
      '/shops': (context) => ShopsPage(title: 'SHOPS'),
      '/subscribe': (context) => SubscribePage(title: 'SUBSCRIPTION FORM'),
      '/clients': (context) => CustomersPage(title: 'CUSTOMERS'),
      '/categories': (context) => CategoriesPage(title: 'CATEGORIES'),
      '/stock': (context) => StockPage(title: 'STOCK'),
      '/migrate': (context) => ConvertClientsPage(title: 'MIGRATION PAGE'),
      '/users': (context) => UsersPage(title: 'USERS LIST',),
      '/about': (context) => AboutPage(title: 'ABOUT'),
    };
  }
}
