/// Build-time switches for the classroom demonstrations.
///
/// Slow-save is off in normal builds. Turn it on to record the required
/// double-receipt check:
///
///   flutter run --dart-define=SLOW_SAVE=true
///
/// With it on, a purchase write waits [slowSaveDelay] before touching the
/// database. Tapping Save twice during that wait must still record exactly one
/// receipt, because the editor locks the button before the first write starts.
const bool simulateSlowSave = bool.fromEnvironment('SLOW_SAVE');

const Duration slowSaveDelay = Duration(seconds: 2);
