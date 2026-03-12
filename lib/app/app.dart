import 'package:ctnh_wiki/app/wiki_app_shell.dart';
import 'package:flutter/material.dart';

class CtnhWikiApp extends StatelessWidget {
  const CtnhWikiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CTNH Wiki',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F0E8),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF425C45),
          secondary: Color(0xFFC88A3D),
          surface: Color(0xFFFFFBF4),
        ),
      ),
      home: const WikiAppShell(),
    );
  }
}
