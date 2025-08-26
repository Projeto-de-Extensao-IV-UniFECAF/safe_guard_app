import 'package:flutter/material.dart';
import 'screens/register_face_screen.dart';
import 'screens/responsible_screen.dart';
import 'screens/monitoring_screen.dart';

void main() {
  runApp(SafeFallApp());
}

class SafeFallApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeFall',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 18)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => RegisterFaceScreen(),
        '/responsible': (context) => ResponsibleScreen(),
        '/monitoring': (context) => MonitoringScreen(),
      },
    );
  }
}
