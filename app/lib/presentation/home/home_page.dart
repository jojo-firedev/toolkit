import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: 'FD Toolkit',
        primaryColor:
            Theme.of(context).primaryColor.value, // This line is required
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text('FD Toolkit')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(20),
        children: [
          _buildToolCard(
            context,
            'LinkedIn Carousel',
            '/social-media/linkedin-carousel',
          ),
          _buildToolCard(
            context,
            'Compress Images',
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
