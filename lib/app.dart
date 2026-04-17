import 'package:flutter/material.dart';
import 'features/auth/pages/login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LostLink',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      ),
      home: const LoginPage(),
    );
  }
}