import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pattes_et_carnets/app/theme.dart';
import 'package:pattes_et_carnets/features/cat_profile/edit_cat_sheet.dart';
import 'package:pattes_et_carnets/shared/providers/data_providers.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/models/enums.dart';
import 'package:pattes_et_carnets/shared/models/reminder_extensions.dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

class CatProfileScreen extends ConsumerWidget {
  const CatProfileScreen({super.key, required this.catId});

  final int catId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catAsync = ref.watch(catByIdProvider(catId));

    return catAsync.when(
      data: (cat) {
        if (cat == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Chat introuvable')),
          );
        }
        return _CatProfileView(cat: cat);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Erreur : $e')),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main view
// ---------------------------------------------------------------------------

class _CatProfileView extends ConsumerWidget {
  const _CatProfileView({required this.cat});

  final Cat cat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref
            .watch(catRemindersProvider(cat.id))
            .valueOrNull
            ?.where((r) => !r.isDone)
            .toList() ??
        [];
    reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final entries =
        ref.watch(catHealthEntriesProvider(cat.id)).valueOrNull ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _HeroSliverAppBar(cat: cat),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _QuickStats(cat: cat),
                const SizedBox(height: 28),
                _HealthSection(reminders: reminders),
                const SizedBox(height: 28),
                _RecentNotes(entries: entries, catId: cat.id),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero SliverAppBar
// ---------------------------------------------------------------------------

class _HeroSliverAppBar extends ConsumerWidget {
  const _HeroSliverAppBar({required this.cat});

  final Cat cat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      stretch: true,
      backgroundColor: scheme.surface,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.photo_camera_outlined),
          tooltip: 'Photo de profil',
          onPressed: () => changeCatPhoto(context, ref, cat.id),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Modifier',
          onPressed: () => _showEditSheet(context),
        ),
        IconButton(
          icon: const Icon(Icons.crisis_alert),
          tooltip: 'Mode urgence',
          onPressed: () => context.push('/emergency/${cat.id}'),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
        title: Text(
          cat.name,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
          ),
        ),
        stretchModes: const [StretchMode.zoomBackground],
        background: _HeroBackground(
          cat: cat,
          onPhotoTap: () => changeCatPhoto(context, ref, cat.id),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditCatSheet(cat: cat),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero background: photo + gradient + info overlay
// ---------------------------------------------------------------------------

class _HeroBackground extends StatelessWidget {
  const _HeroBackground({required this.cat, required this.onPhotoTap});

  final Cat cat;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasPhoto = cat.photoPath != null && cat.photoPath!.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        hasPhoto
            ? Image.file(File(cat.photoPath!), fit: BoxFit.cover)
            : Container(
                color: scheme.surfaceContainerHigh,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 96,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary.withAlpha(80),
                      ),
                    ),
                    Icon(Icons.add_a_photo_outlined, size: 28, color: scheme.outline),
                    const SizedBox(height: 4),
                    Text('Ajouter une photo',
                        style: TextStyle(color: scheme.outline, fontSize: 13)),
                  ],
                ),
              ),
        // Bottom gradient
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xCC000000)],
              stops: [0.45, 1.0],
            ),
          ),
        ),
        // Info overlay (breed + birthdate)
        Positioned(
          left: 20,
          right: 20,
          bottom: 52,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${cat.sex.label} • ${cat.breed ?? 'Race inconnue'}',
                style: const TextStyle(color: Colors.white70, fontSize: 17, fontFamily: 'Nunito Sans'),
              ),
              if (cat.birthDate != null)
                Text(
                  'Né(e) le ${_formatDate(cat.birthDate!)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'Nunito Sans'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ---------------------------------------------------------------------------
// Quick stats row
// ---------------------------------------------------------------------------

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.cat});

  final Cat cat;

  @override
  Widget build(BuildContext context) {
    final weight = cat.weightKg != null ? '${cat.weightKg} kg' : '—';
    final chip = cat.chipNumber != null
        ? cat.chipNumber!.length > 8
            ? '${cat.chipNumber!.substring(0, 8)}…'
            : cat.chipNumber!
        : '—';

    return Row(
      children: [
        Expanded(child: _StatTile(icon: Icons.cake_outlined, label: 'Âge', value: cat.ageLabel)),
        const SizedBox(width: 12),
        Expanded(child: _StatTile(icon: Icons.monitor_weight_outlined, label: 'Poids', value: weight)),
        const SizedBox(width: 12),
        Expanded(child: _StatTile(icon: Icons.tag, label: 'Puce', value: chip)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          Icon(icon, color: scheme.primary, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.labelLarge
                ?.copyWith(color: scheme.primary, fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Health & Prevention section
// ---------------------------------------------------------------------------

class _HealthSection extends StatelessWidget {
  const _HealthSection({required this.reminders});

  final List<Reminder> reminders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Santé & Prévention', style: theme.textTheme.headlineMedium),
            TextButton(
              onPressed: () => context.push('/calendar'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (reminders.isEmpty)
          _UpToDateBanner()
        else
          ...reminders.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ReminderCard(reminder: r),
              )),
      ],
    );
  }
}

class _UpToDateBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: scheme.primary, width: 4)),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withAlpha(60),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified, color: scheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tout est à jour',
                    style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                Text('Tous les soins sont effectués.',
                    style: TextStyle(
                        color: scheme.onSurfaceVariant, fontSize: 14)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withAlpha(40),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text('OK',
                style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = reminder.healthStatus;
    final color = status.statusColor(scheme);
    final containerColor = status.statusContainerColor(scheme);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: const [AppTheme.cardShadow],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: containerColor.withAlpha(80),
              shape: BoxShape.circle,
            ),
            child: Icon(reminder.type.icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.type.label,
                  style: theme.textTheme.labelLarge?.copyWith(color: color),
                ),
                if (reminder.description != null)
                  Text(
                    reminder.description!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: containerColor.withAlpha(50),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              reminder.dueLabel,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent notes section
// ---------------------------------------------------------------------------

class _RecentNotes extends StatelessWidget {
  const _RecentNotes({required this.entries, required this.catId});

  final List<HealthEntry> entries;
  final int catId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Dernières Notes', style: theme.textTheme.headlineMedium),
            TextButton(
              onPressed: () => context.push('/journal/$catId'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [AppTheme.cardShadow],
            ),
            child: Text(
              'Aucune note pour l\'instant.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant, fontStyle: FontStyle.italic),
            ),
          )
        else
          _NoteCard(entry: entries.first),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.entry});

  final HealthEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final daysDiff = DateTime.now().difference(entry.createdAt).inDays;
    final timeLabel = switch (daysDiff) {
      0 => "Aujourd'hui",
      1 => 'Il y a 1 jour',
      < 30 => 'Il y a $daysDiff jours',
      _ => 'Il y a ${(daysDiff / 30).floor()} mois',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.history_edu_outlined,
                color: scheme.outlineVariant, size: 28),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      entry.type.label,
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                entry.note ?? entry.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                timeLabel,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: scheme.outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
