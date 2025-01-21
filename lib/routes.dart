import 'package:eventure/main.dart';
import 'package:flutter/material.dart';
import 'modules/main_screen.dart';
// import 'modules/profile_page.dart';
// import 'modules/create_page.dart';
// import 'modules/events.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => MainPage(),
  // '/profile': (context) => ProfilePage(),
  // '/create': (context) => CreatePage(),
  // '/Events': (context) => Events(),
};
