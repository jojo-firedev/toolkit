import 'package:flutter/material.dart';
import 'package:social_media_toolkit/router.dart';
import 'package:dynamic_path_url_strategy/dynamic_path_url_strategy.dart';

void main() {
  setPathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SocialMediaToolkitApp());
}

class SocialMediaToolkitApp extends StatelessWidget {
  const SocialMediaToolkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SocialMedia Toolkit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
