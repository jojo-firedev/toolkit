import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_toolkit/presentation/linkedin_carousel_generator/linkedin_carousel_generator_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      redirect: (final BuildContext context, final GoRouterState state) async =>
          '/linkedin-carousel',
    ),
    GoRoute(
      path: '/linkedin-carousel',
      builder: (final BuildContext context, final GoRouterState state) =>
          const LinkedInCarouselGeneratorPage(),
    ),
  ],
);
