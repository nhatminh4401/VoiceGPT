import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_gpt/constants/constants.dart';
import 'package:voice_gpt/providers/model_provider.dart';
import 'package:voice_gpt/screens/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ModelsProvider())],
        child: (MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              scaffoldBackgroundColor: scaffoldBackgroundColor,
              appBarTheme: AppBarTheme(color: cardColor)),
          home: const ChatScreen(),
        )));
  }
}
