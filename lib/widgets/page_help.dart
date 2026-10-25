import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_widgets.dart';

// same question button everywhere. the tooltip gives it a name for screen readers too.
class PageHelp extends StatelessWidget {
  const PageHelp({super.key, required this.title, required this.message});
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Help with $title',
    icon: SvgPicture.asset(
      'assets/icons/question-mark.svg',
      width: IconTheme.of(context).size ?? 24,
      height: IconTheme.of(context).size ?? 24,
      excludeFromSemantics: true,
      colorFilter: const ColorFilter.mode(appIconColor, BlendMode.srcIn),
    ),
    onPressed: () => showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        // long help can scroll when the phone text size is turned up.
        scrollable: true,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    ),
  );
}

// short name stays on the page. the extra how-to lives behind the question mark.
class PageHeading extends StatelessWidget {
  const PageHeading({super.key, required this.title, required this.help});
  final String title;
  final String help;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
      PageHelp(title: title, message: help),
    ],
  );
}
