import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usland/state/notification_state.dart';
import 'package:usland/utils/design.dart';

class MediaView extends StatelessWidget {
  final MediaData? data;

  const MediaView({super.key, required this.data});

  static const _mediaChannel = MethodChannel('com.elsewhere.usland/media');

  Future<void> _togglePlayPause() async {
    try {
      await _mediaChannel.invokeMethod('togglePlayPause');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Album art
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: UslandDesign.periwinkle.withOpacity(0.15),
            ),
            child: data!.albumArtPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      data!.albumArtPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultArt(),
                    ),
                  )
                : _defaultArt(),
          ),
          const SizedBox(width: 12),
          // Track info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data!.trackName,
                  style: const TextStyle(
                    color: UslandDesign.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  data!.artistName,
                  style: const TextStyle(
                    color: UslandDesign.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Play/pause button
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: UslandDesign.periwinkle.withOpacity(0.15),
              ),
              child: Icon(
                data!.isPlaying ? Icons.pause : Icons.play_arrow,
                color: UslandDesign.periwinkle,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultArt() {
    return const Icon(
      Icons.music_note,
      color: UslandDesign.periwinkle,
      size: 20,
    );
  }
}
