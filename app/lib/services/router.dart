import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_toolkit/presentation/home/home_page.dart';
import 'package:social_media_toolkit/presentation/image_converter/image_converter_page.dart';
import 'package:social_media_toolkit/presentation/linkedin_carousel_generator/linkedin_carousel_generator_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (final BuildContext context, final GoRouterState state) =>
          const HomePage(),
    ),
    GoRoute(
      path: '/social-media/linkedin-carousel',
      builder: (final BuildContext context, final GoRouterState state) =>
          const LinkedInCarouselGeneratorPage(),
    ),
    GoRoute(
      path: '/converter/image-compressor',
      builder: (final BuildContext context, final GoRouterState state) =>
          ImageCompressorPage(),
    ),
  ],
);
