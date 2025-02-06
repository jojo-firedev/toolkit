import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Collection of tools',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  TextSpan(
                    text: '   |   by ',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  TextSpan(
                    text: 'jojo_firedev',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          launchUrlString('https://github.com/jojo-firedev'),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
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
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 100, maxWidth: 200),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
