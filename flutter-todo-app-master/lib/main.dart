import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './screens/home.dart';
import './screens/LoginScreen.dart';
import './screens/trash.dart';
import 'screens/HeroPage.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HeroPage(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => Home(),
      },
    );
  }
}

