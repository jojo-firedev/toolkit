import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_toolkit/presentation/home/home_page.dart';
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
      path: '/socialmedia/linkedin-carousel',
      builder: (final BuildContext context, final GoRouterState state) =>
          const LinkedInCarouselGeneratorPage(),
    ),
  ],
);
