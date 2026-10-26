import 'package:flutter/material.dart';

import 'app_widgets.dart';
import '../app_controller.dart';
import '../logic/lunch_lens.dart';
import '../models.dart';

// a small suggestion with its reason. it never fills or saves a price by itself.
class LunchLens extends StatefulWidget {
  const LunchLens({
    super.key,
    required this.controller,
    required this.mealId,
    required this.before,
    this.editingId,
  });
  final AppController controller;
  final int? mealId;
  final DateTime before;
  final int? editingId;
  @override
  State<LunchLens> createState() => _LunchLensState();
}

class _LunchLensState extends State<LunchLens> {
  bool _hidden = false;
  @override
  Widget build(BuildContext context) {
    // hiding this only hides the suggestion, it does not save anything.
    if (_hidden) {
      return TextButton(
        onPressed: () => setState(() => _hidden = false),
        child: const Text('Show estimate'),
      );
    }
    // listen again after a receipt changes so the estimate is not old.
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final estimate = estimateLunch(
          widget.controller.purchases,
          mealId: widget.mealId,
          before: widget.before,
          editingId: widget.editingId,
        );
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lunch Lens', style: theme.textTheme.titleMedium),
            // no guesses when we have less than three earlier receipts.
            if (estimate == null)
              const Text(
                'Log this meal three times to get a price suggestion.',
              )
            else ...[
              Text(
                'Estimated ${formatMoney(estimate.cents)}',
                style: theme.textTheme.titleLarge,
              ),
              Text(
                'Based on your last three purchases: ${estimate.inputs.map((e) => formatMoney(e.amountCents)).join(', ')}.',
              ),
              Text(
                '${shortDate(estimate.inputs.last.purchasedAt)} – ${shortDate(estimate.inputs.first.purchasedAt)}',
              ),
              const Text(
                'Based on past prices. Your next purchase may cost more or less.',
              ),
            ],
            const Text(
              'This is just a guide. Change the price when you plan or log it.',
            ),
            TextButton(
              onPressed: () => setState(() => _hidden = true),
              child: const Text('Hide estimate'),
            ),
          ],
        );
      },
    );
  }
}
