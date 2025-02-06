import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📢 Social Media Toolkit")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(20),
        children: [
          _buildToolCard(
            context,
            "📄 LinkedIn Carousel",
            '/social-media/linkedin-carousel',
          ),
          _buildToolCard(
            context,
            "Compress Images",
            '/converter/image-compressor',
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, String title, String page) {
    return GestureDetector(
      onTap: () => context.go(page),
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 5,
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
