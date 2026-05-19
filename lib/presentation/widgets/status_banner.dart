import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/data_load_source.dart';
import '../../services/sync_manager.dart';

class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.isOnline,
    required this.syncState,
    required this.pendingCount,
    this.dataLoadSource,
  });

  final bool isOnline;
  final SyncState syncState;
  final int pendingCount;
  final DataLoadSource? dataLoadSource;

  @override
  Widget build(BuildContext context) {
    final offline = !isOnline;
    final syncing = syncState == SyncState.syncing;
    final failed = syncState == SyncState.failed;

    late Color accent;
    late IconData icon;
    late String title;
    String? subtitle;

    if (offline) {
      accent = AppColors.warning;
      icon = Icons.wifi_off_rounded;
      title = 'You\'re offline';
      subtitle = 'Showing saved products from your device';
    } else if (syncing) {
      accent = AppColors.primary;
      icon = Icons.sync_rounded;
      title = 'Syncing';
      subtitle = 'Updating your favorites…';
    } else if (failed) {
      accent = AppColors.error;
      icon = Icons.cloud_off_rounded;
      title = 'Sync failed';
      subtitle = 'We\'ll retry when you\'re back online';
    } else if (pendingCount > 0) {
      accent = AppColors.warning;
      icon = Icons.schedule_rounded;
      title = '$pendingCount pending';
      subtitle = 'Favorite changes waiting to sync';
    } else if (dataLoadSource == DataLoadSource.localCache) {
      accent = AppColors.primary;
      icon = Icons.sd_storage_rounded;
      title = 'Data loaded locally';
    } else if (dataLoadSource == DataLoadSource.api) {
      accent = AppColors.success;
      icon = Icons.cloud_done_rounded;
      title = 'Data collected online';
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: syncing
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accent,
                      ),
                    )
                  : Icon(icon, size: 18, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle case final sub?) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
