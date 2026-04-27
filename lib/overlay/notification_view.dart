import 'package:flutter/material.dart';
import 'package:usland/state/notification_state.dart';
import 'package:usland/utils/design.dart';

class NotificationView extends StatelessWidget {
  final NotificationData? data;

  const NotificationView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // App icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: UslandDesign.periwinkle.withOpacity(0.15),
              border: Border.all(
                color: UslandDesign.periwinkle.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: data!.appIconPath != null
                ? ClipOval(
                    child: Image.asset(
                      data!.appIconPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultIcon(),
                    ),
                  )
                : _defaultIcon(),
          ),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data!.appName,
                  style: const TextStyle(
                    color: UslandDesign.textSecondary,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  data!.title,
                  style: const TextStyle(
                    color: UslandDesign.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (data!.body != null && data!.body!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    data!.body!,
                    style: const TextStyle(
                      color: UslandDesign.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultIcon() {
    return const Icon(
      Icons.notifications_outlined,
      color: UslandDesign.periwinkle,
      size: 18,
    );
  }
}
