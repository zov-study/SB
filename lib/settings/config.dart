import 'package:flutter/material.dart';

// App settings
const String app_title = 'Smart Brands';
const Color app_color = Color.fromRGBO(160, 0, 0, 1.0);
const Color app_theme_color = Colors.red;
const bool app_debug_mode = false;
const int app_time_duration = 1000;
const int ai_choice_duration = 2000;

// App Types
enum FormType { login, signin }
enum AuthStatus { notDetermined, notSignedIn, signedIn }
enum UserRole { guest, shopAssistant, owner, admin }
enum ImageMode { None, Asset, Network }

//Main page
const String main_title = 'Smart Brands';
const Color main_color = Color.fromRGBO(160, 0, 0, 1.0);
const String main_image = 'assets/images/logo.jpg';
const double main_image_width = 260.0;
const String main_slogan = 'SHOP SMART, PAY LESS';
const Color main_slogan_color = Color.fromRGBO(160, 0, 0, 1.0);
const double main_slogan_font_size=18.0;
const FontWeight main_slogan_font_weight=FontWeight.w600;

// Drawer
const List<String>roles=['Guest','Shop Assistant','Owner','Administrator'];

// Snack Bar
const Color snackbar_color = Color.fromRGBO(160, 0, 0, 1.0);
const int snackbar_delay = 3;

// Cities
//About
const String about_title = 'About';
const Color about_color = Colors.black;
