import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/study_room.dart';

/// Real audio playback layer for UniFocus multiplayer study rooms.
/// Synchronizes audio across all room participants using server/startedAt timestamps.
///
/// Synchronization Architecture:
/// - Host has authority to play, pause, seek, and change room-wide tracks.
/// - Room participants listen to the room music state and sync their local player.
/// - Participants have individual control over local mute and volume.
/// - Late joiners calculate target playback position locally:
///   `position = positionSeconds + (now - startedAt)` and seek directly.
class RoomAudioPlayerService {
  final AudioPlayer? _player;
  String? _loadedAudioUrl;
  String? _currentTrackId;
  bool _isPlaying = false;
  double _localVolume = 0.8;
  bool _isMuted = false;
  DateTime? _lastSyncTime;

  RoomAudioPlayerService({
    AudioPlayer? player,
    bool? initializePlatformPlayer,
  }) : _player = player ??
            ((initializePlatformPlayer ?? !_isTestEnvironment())
                ? _createSafePlayer()
                : null) {
    _init();
  }

  static bool _isTestEnvironment() {
    try {
      final binding = WidgetsBinding.instance;
      return binding.runtimeType.toString().contains('Test');
    } catch (_) {
      return false;
    }
  }

  static AudioPlayer? _createSafePlayer() {
    try {
      return AudioPlayer();
    } catch (e) {
      debugPrint('[RoomAudio] Could not create AudioPlayer: $e');
      return null;
    }
  }

  void _init() {
    try {
      _player?.setReleaseMode(ReleaseMode.loop);
      _player?.setVolume(_localVolume);
    } catch (e) {
      debugPrint('[RoomAudio] Initialization error: $e');
    }
  }

  bool get isPlaying => _isPlaying;
  double get localVolume => _localVolume;
  bool get isMuted => _isMuted;
  String? get currentTrackId => _currentTrackId;

  /// Synchronizes local audio playback with the shared room music state.
  Future<void> syncWithRoomMusic({
    required RoomMusicState musicState,
    required bool isLocalMuted,
    required double localVolume,
  }) async {
    _isMuted = isLocalMuted;
    _localVolume = localVolume;

    // 1. Update volume immediately
    final effectiveVolume = isLocalMuted ? 0.0 : localVolume.clamp(0.0, 1.0);
    try {
      await _player?.setVolume(effectiveVolume);
    } catch (e) {
      debugPrint('[RoomAudio] setVolume failed: $e');
    }

    final targetUrl = musicState.audioUrl;
    if (targetUrl.isEmpty) {
      if (_isPlaying) {
        await pause();
      }
      return;
    }

    final trackChanged = _currentTrackId != musicState.trackId || _loadedAudioUrl != targetUrl;
    final targetPositionSec = musicState.currentPositionSeconds;
    final targetDuration = Duration(seconds: targetPositionSec);

    // 2. Handle Track Loading
    if (trackChanged) {
      _currentTrackId = musicState.trackId;
      _loadedAudioUrl = targetUrl;
      try {
        await _player?.stop();
        if (_player != null) {
          if (targetUrl.startsWith('asset://') || targetUrl.startsWith('assets/')) {
            final assetPath = targetUrl.replaceFirst('asset://', '').replaceFirst('assets/', '');
            await _player!.setSource(AssetSource(assetPath));
          } else {
            await _player!.setSource(UrlSource(targetUrl));
          }
        }
      } catch (e) {
        debugPrint('[RoomAudio] Failed to set audio source $targetUrl: $e');
      }
    }

    // 3. Handle Play / Pause State
    if (musicState.isPlaying) {
      if (!_isPlaying || trackChanged) {
        try {
          if (targetPositionSec > 0) {
            await _player?.seek(targetDuration);
          }
          await _player?.resume();
          _isPlaying = true;
          _lastSyncTime = DateTime.now();
        } catch (e) {
          debugPrint('[RoomAudio] Resume / Play error: $e');
        }
      } else {
        // Drift check every ~5 seconds
        final now = DateTime.now();
        if (_lastSyncTime == null || now.difference(_lastSyncTime!).inSeconds >= 5) {
          _lastSyncTime = now;
          try {
            final curPos = await _player?.getCurrentPosition();
            if (curPos != null) {
              final drift = (curPos.inSeconds - targetPositionSec).abs();
              if (drift > 3) {
                debugPrint('[RoomAudio] Drift detected ($drift s). Re-seeking to $targetPositionSec s');
                await _player?.seek(targetDuration);
              }
            }
          } catch (_) {}
        }
      }
    } else {
      if (_isPlaying) {
        try {
          await _player?.pause();
          _isPlaying = false;
          if (targetPositionSec > 0) {
            await _player?.seek(targetDuration);
          }
        } catch (e) {
          debugPrint('[RoomAudio] Pause error: $e');
        }
      }
    }
  }

  Future<void> pause() async {
    _isPlaying = false;
    try {
      await _player?.pause();
    } catch (e) {
      debugPrint('[RoomAudio] pause error: $e');
    }
  }

  Future<void> resume() async {
    _isPlaying = true;
    try {
      await _player?.resume();
    } catch (e) {
      debugPrint('[RoomAudio] resume error: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player?.seek(position);
    } catch (e) {
      debugPrint('[RoomAudio] seek error: $e');
    }
  }

  Future<void> setLocalVolume(double volume) async {
    _localVolume = volume.clamp(0.0, 1.0);
    final effective = _isMuted ? 0.0 : _localVolume;
    try {
      await _player?.setVolume(effective);
    } catch (e) {
      debugPrint('[RoomAudio] setVolume error: $e');
    }
  }

  Future<void> setLocalMute(bool muted) async {
    _isMuted = muted;
    final effective = _isMuted ? 0.0 : _localVolume;
    try {
      await _player?.setVolume(effective);
    } catch (e) {
      debugPrint('[RoomAudio] setVolume error: $e');
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    try {
      await _player?.stop();
    } catch (e) {
      debugPrint('[RoomAudio] stop error: $e');
    }
  }

  void dispose() {
    try {
      _player?.dispose();
    } catch (_) {}
  }
}
