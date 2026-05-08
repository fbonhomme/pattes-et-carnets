import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pattes_et_carnets/app/theme.dart';
import 'package:pattes_et_carnets/features/home/home_provider.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/models/enums.dart';
import 'package:pattes_et_carnets/shared/models/reminder_extensions.dart';

class CatCard extends ConsumerWidget {
  const CatCard({
    super.key,
    required this.cat,
    required this.onTap,
    required this.onMoreTap,
  });

  final Cat cat;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(catRemindersProvider(cat.id));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final pending = remindersAsync.valueOrNull
            ?.where((r) => !r.isDone)
            .toList() ??
        [];
    pending.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final urgentReminder = pending.isEmpty ? null : pending.first;
    final status = urgentReminder?.healthStatus ?? HealthStatus.upToDate;

    final borderColor = status.statusColor(scheme);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: borderColor, width: 4),
          ),
          boxShadow: const [AppTheme.cardShadow],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header row: avatar + name + more button ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CatAvatar(cat: cat, borderColor: borderColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        cat.name,
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        cat.ageLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onMoreTap,
                  icon: Icon(Icons.more_vert, color: scheme.outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // --- Health status badge ---
            _StatusBadge(reminder: urgentReminder, status: status),
            // --- "Voir le carnet" link ---
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  foregroundColor: scheme.primary,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                label: const Text('Voir le carnet'),
                icon: const Icon(Icons.arrow_forward, size: 16),
                iconAlignment: IconAlignment.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CatAvatar extends StatelessWidget {
  const _CatAvatar({required this.cat, required this.borderColor});

  final Cat cat;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasPhoto = cat.photoPath != null && cat.photoPath!.isNotEmpty;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor.withAlpha(100),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.file(
                File(cat.photoPath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Placeholder(name: cat.name, scheme: scheme),
              )
            : _Placeholder(name: cat.name, scheme: scheme),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.name, required this.scheme});

  final String name;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scheme.surfaceContainerHigh,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.reminder, required this.status});

  final Reminder? reminder;
  final HealthStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = status.statusColor(scheme);
    final bgColor = status.statusContainerColor(scheme).withAlpha(60);

    final (icon, label) = _resolve(scheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, String) _resolve(ColorScheme scheme) {
    final r = reminder;
    if (r == null) return (Icons.verified, 'Tout est à jour');

    final daysLeft = r.dueDate.difference(DateTime.now()).inDays;
    final timeLabel = switch (daysLeft) {
      < 0 => 'En retard',
      0 => "Aujourd'hui",
      1 => 'Demain',
      _ => 'Dans $daysLeft jours',
    };

    final icon = switch (status) {
      HealthStatus.late => Icons.warning_rounded,
      HealthStatus.upcoming => Icons.schedule,
      HealthStatus.upToDate => Icons.verified,
    };

    return (icon, '${r.title} — $timeLabel');
  }
}
