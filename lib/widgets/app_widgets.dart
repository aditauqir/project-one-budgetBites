import 'package:flutter/material.dart';

const appPrimary = Color(0xFFFEC601);
const appIconColor = Color(0xFF6A3E37);
const appPrimarySoft = Color(0xFFFFF4C7);
const appAccentSoft = Color(0xFFF4ECE9);
const appSuccess = Color(0xFF16805D);
const appWarning = Color(0xFF9A6A00);
const appError = Color(0xFFB52F32);
const appInk = Color(0xFF17231E);
const appMuted = Color(0xFF706861);
const appBorder = Color(0xFFE6DED6);
const appCanvas = Color(0xFFFFFFFF);
const appHeadingWeight = FontWeight(560);
const appEmphasisWeight = FontWeight.w600;
const appAmountWeight = FontWeight.w500;

// Use the package font directly because its v2.1 IconData wrapper is not
// compatible with the current Flutter SDK's final IconData class.
abstract final class AppIcons {
  static const home = IconData(
    0xe2c2,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const activity = IconData(
    0xe000,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const add = IconData(
    0xe3d4,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const addCircle = IconData(
    0xe3d6,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const removeCircle = IconData(
    0xe32c,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const history = IconData(
    0xe1a0,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const settings = IconData(
    0xe272,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const wallet = IconData(
    0xe68a,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const shoppingBag = IconData(
    0xe416,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const store = IconData(
    0xe470,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const mapPin = IconData(
    0xe316,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const restaurant = IconData(
    0xe262,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const checklist = IconData(
    0xeadc,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const editNote = IconData(
    0xe34c,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const note = IconData(
    0xe63e,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const coffee = IconData(
    0xe1c2,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const food = IconData(
    0xeaa4,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const tag = IconData(
    0xe478,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const bookmark = IconData(
    0xe0ea,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const edit = IconData(
    0xe3b4,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const delete = IconData(
    0xe4a6,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const save = IconData(
    0xe248,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const clock = IconData(
    0xe19a,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const listPlus = IconData(
    0xe2f8,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const cloudOff = IconData(
    0xe1b6,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const inbox = IconData(
    0xe4aa,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const receipt = IconData(
    0xe3ec,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.color = Colors.white,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: borderColor ?? appBorder),
    ),
    child: child,
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(
    this.title, {
    super.key,
    this.trailing,
    this.fontWeight = appHeadingWeight,
  });

  final String title;
  final Widget? trailing;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: fontWeight, color: appInk),
        ),
      ),
      ?trailing,
    ],
  );
}

class EmptyMessage extends StatelessWidget {
  const EmptyMessage({
    super.key,
    required this.title,
    required this.detail,
    this.icon = AppIcons.inbox,
  });

  final String title;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Column(
      children: [
        Icon(icon, size: 34, color: appMuted),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: appEmphasisWeight)),
        const SizedBox(height: 4),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: const TextStyle(color: appMuted),
        ),
      ],
    ),
  );
}

String shortDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[value.month - 1]} ${value.day}';
}

String weekdayShort(DateTime value) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[value.weekday - 1];
}
