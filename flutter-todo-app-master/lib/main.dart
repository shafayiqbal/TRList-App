import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './screens/Home.dart';
import './screens/LoginScreen.dart';
import './screens/trash.dart';
import './screens/HeroPage.dart';
import './screens/RegisterScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //     .collection("users")
  //     .doc("cc29z7oTyp0PDv9wUFXA")
  //     .get();

  // print(snapshot.data().toString());
  // Map<String, dynamic> newUserData = {
  //   "name": "Zain Hassan",
  //   "email": "zain@gmail.com"
  // };
  // await _firestore.collection("users").add(newUserData);
  // print("newusersaved");

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
      home: (FirebaseAuth.instance.currentUser != null) ? Home() : HeroPage(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => Home(),
        '/register': (context) => RegisterScreen(),
        '/hero': (context) => HeroPage(),
      },
    );
  }
}
