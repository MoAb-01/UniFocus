import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Manages the persistent status-bar notification shown while the user is
/// in an active UniFocus study room session. The notification:
///   - Shows the room code and elapsed study time
///   - Stays pinned in the notification shade (non-dismissable by swipe)
///   - Refreshes elapsed time every 60 seconds automatically
///   - Cancels itself when the session ends or the user leaves the room
///
/// This is an Android-only feature; all calls silently no-op on web/desktop.
class SessionNotificationService {
  static const int _kSessionNotificationId = 7001;
  static const String _kChannelId = 'study_session_active';
  static const String _kChannelName = 'Study Session';
  static const String _kChannelDesc =
      'Persistent notification shown during active study room sessions.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _isShowing = false;
  String _roomId = '';
  DateTime? _sessionStart;
  Timer? _updateTimer;

  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (!_isAndroid) return;
    if (_initialized) return;

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      _initialized = true;
    } catch (_) {
      // Gracefully no-op in tests or unsupported environments
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Starts showing the persistent session notification.
  /// Call this when the user successfully joins or creates a study room.
  Future<void> showSessionNotification({required String roomId}) async {
    if (!_isAndroid) return;
    await initialize();

    _roomId = roomId;
    _sessionStart = DateTime.now();
    _isShowing = true;

    await _notify(elapsed: Duration.zero);

    // Refresh the elapsed time every 60 seconds
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      if (_isShowing) await _notify(elapsed: _elapsed);
    });
  }

  /// Cancels the notification. Call when user leaves or session ends.
  Future<void> cancelSessionNotification() async {
    if (!_isAndroid) return;
    _isShowing = false;
    _updateTimer?.cancel();
    _updateTimer = null;
    _sessionStart = null;
    _roomId = '';
    try {
      await _plugin.cancel(_kSessionNotificationId);
    } catch (_) {}
  }

  void dispose() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Duration get _elapsed => _sessionStart != null
      ? DateTime.now().difference(_sessionStart!)
      : Duration.zero;

  String _formatElapsed(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m';
    return 'just started';
  }

  Future<void> _notify({required Duration elapsed}) async {
    final elapsedStr = _formatElapsed(elapsed);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _kChannelId,
        _kChannelName,
        channelDescription: _kChannelDesc,
        importance: Importance.low, // silent — no sound or vibration
        priority: Priority.low,
        ongoing: true, // pinned, cannot be swiped away
        autoCancel: false,
        showWhen: false,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(
          'Studying for $elapsedStr — tap to return to your room.',
          contentTitle: 'Study Session · $_roomId',
          summaryText: 'UniFocus',
        ),
      ),
    );

    try {
      await _plugin.show(
        _kSessionNotificationId,
        'Study Session · $_roomId',
        'Studying for $elapsedStr — tap to return',
        details,
      );
    } catch (_) {}
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Android automatically brings the app to foreground when the notification
    // is tapped because MainActivity is declared with launchMode="singleTop".
    // The active session screen is already on the navigation stack — no extra
    // routing needed.
  }
}
