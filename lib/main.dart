import 'package:flutter/material.dart';
import 'package:social_media_toolkit/linkedin_carousel_generator_page.dart';

void main() {
  runApp(const SocialMediaToolkitApp());
}

class SocialMediaToolkitApp extends StatelessWidget {
  const SocialMediaToolkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SocialMedia Toolkit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LinkedInCarouselGeneratorPage(),
    );
  }
}
