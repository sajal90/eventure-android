import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes.dart';

Future<void> main() async { 
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[850],
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
        ),
        textTheme: TextTheme(
          bodySmall: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
