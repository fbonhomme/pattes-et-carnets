import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drift/drift.dart' show Value;

import 'package:pattes_et_carnets/app/theme.dart';
import 'package:pattes_et_carnets/features/home/home_provider.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/models/enums.dart';
import 'package:pattes_et_carnets/shared/models/reminder_extensions.dart';
import 'package:pattes_et_carnets/shared/providers/database_provider.dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

class CatProfileScreen extends ConsumerWidget {
  const CatProfileScreen({super.key, required this.catId});

  final String catId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(catId) ?? 0;
    final catAsync = ref.watch(catByIdProvider(id));

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
                _HealthSection(reminders: reminders, catId: cat.id),
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
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Modifier',
          onPressed: () => _showEditSheet(context, ref),
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
        background: _HeroBackground(cat: cat),
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditCatSheet(cat: cat, ref: ref),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero background: photo + gradient + info overlay
// ---------------------------------------------------------------------------

class _HeroBackground extends ConsumerWidget {
  const _HeroBackground({required this.cat});

  final Cat cat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final hasPhoto = cat.photoPath != null && cat.photoPath!.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Photo or placeholder
        GestureDetector(
          onTap: () => _pickPhoto(context, ref),
          child: hasPhoto
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
                      Icon(Icons.add_a_photo_outlined,
                          size: 28, color: scheme.outline),
                      const SizedBox(height: 4),
                      Text(
                        'Ajouter une photo',
                        style: TextStyle(color: scheme.outline, fontSize: 13),
                      ),
                    ],
                  ),
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
        // Info overlay (breed + birthdate) — fades with the background
        Positioned(
          left: 20,
          right: 20,
          bottom: 52,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${cat.sex.label} • ${cat.breed ?? 'Race inconnue'}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                  fontFamily: 'Nunito Sans',
                ),
              ),
              if (cat.birthDate != null)
                Text(
                  'Né(e) le ${_formatDate(cat.birthDate!)}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontFamily: 'Nunito Sans',
                  ),
                ),
            ],
          ),
        ),
        // Camera overlay badge (if photo exists)
        if (hasPhoto)
          Positioned(
            bottom: 56,
            right: 16,
            child: GestureDetector(
              onTap: () => _pickPhoto(context, ref),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30),
                ),
                child: const Icon(Icons.photo_camera,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickPhoto(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image == null) return;
    await ref.read(catsDaoProvider).updateCat(
          CatsCompanion(id: Value(cat.id), photoPath: Value(image.path)),
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
  const _HealthSection({required this.reminders, required this.catId});

  final List<Reminder> reminders;
  final int catId;

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
                child: _ReminderCard(reminder: r, catId: catId),
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
  const _ReminderCard({required this.reminder, required this.catId});

  final Reminder reminder;
  final int catId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = reminder.healthStatus;
    final color = status.statusColor(scheme);
    final containerColor = status.statusContainerColor(scheme);
    final daysLeft = reminder.dueDate.difference(DateTime.now()).inDays;

    final chipLabel = switch (daysLeft) {
      < 0 => 'En retard',
      0 => "Aujourd'hui",
      1 => 'Demain',
      _ => 'Dans $daysLeft j.',
    };

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
              chipLabel,
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

// ---------------------------------------------------------------------------
// Edit cat bottom sheet
// ---------------------------------------------------------------------------

class _EditCatSheet extends ConsumerStatefulWidget {
  const _EditCatSheet({required this.cat, required this.ref});

  final Cat cat;
  final WidgetRef ref;

  @override
  ConsumerState<_EditCatSheet> createState() => _EditCatSheetState();
}

class _EditCatSheetState extends ConsumerState<_EditCatSheet> {
  late final _nameCtrl = TextEditingController(text: widget.cat.name);
  late final _breedCtrl = TextEditingController(text: widget.cat.breed ?? '');
  late final _weightCtrl = TextEditingController(
    text: widget.cat.weightKg?.toString() ?? '',
  );
  late final _chipCtrl =
      TextEditingController(text: widget.cat.chipNumber ?? '');
  late final _bloodTypeCtrl =
      TextEditingController(text: widget.cat.bloodType ?? '');

  late CatSex _sex = widget.cat.sex;
  late DateTime? _birthDate = widget.cat.birthDate;
  late final List<String> _allergies = List<String>.from(widget.cat.allergies);
  late int? _selectedVetId = widget.cat.vetId;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _weightCtrl.dispose();
    _chipCtrl.dispose();
    _bloodTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);

    await ref.read(catsDaoProvider).updateCat(
          CatsCompanion(
            id: Value(widget.cat.id),
            name: Value(name),
            breed: Value(_breedCtrl.text.trim().isEmpty
                ? null
                : _breedCtrl.text.trim()),
            sex: Value(_sex),
            birthDate: Value(_birthDate),
            weightKg: Value(double.tryParse(_weightCtrl.text.trim())),
            chipNumber: Value(_chipCtrl.text.trim().isEmpty
                ? null
                : _chipCtrl.text.trim()),
            bloodType: Value(_bloodTypeCtrl.text.trim().isEmpty
                ? null
                : _bloodTypeCtrl.text.trim()),
            allergies: Value(_allergies),
            vetId: Value(_selectedVetId),
          ),
        );

    if (mounted) Navigator.pop(context);
  }

  Future<void> _addAllergen() async {
    String? value;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Nouvelle allergie'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Ex: Poulet, Poisson…'),
            onSubmitted: (_) {
              value = ctrl.text.trim();
              Navigator.pop(ctx);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                value = ctrl.text.trim();
                Navigator.pop(ctx);
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
    if (value != null && value!.isNotEmpty && !_allergies.contains(value)) {
      setState(() => _allergies.add(value!));
    }
  }

  Future<void> _addVet() async {
    final nameCtrl = TextEditingController();
    final clinicCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    int? newId;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau vétérinaire'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nom *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: clinicCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Clinique'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              newId = await ref.read(vetsDaoProvider).insertVet(
                    VetsCompanion(
                      name: Value(name),
                      clinic: Value(clinicCtrl.text.trim().isEmpty
                          ? null
                          : clinicCtrl.text.trim()),
                      phone: Value(phoneCtrl.text.trim()),
                    ),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );

    nameCtrl.dispose();
    clinicCtrl.dispose();
    phoneCtrl.dispose();

    if (newId != null && mounted) {
      setState(() => _selectedVetId = newId);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Date de naissance',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final vetsAsync = ref.watch(allVetsProvider);
    final birthLabel = _birthDate != null
        ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
        : 'Choisir une date';

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Modifier le profil', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nom *', prefixIcon: Icon(Icons.pets)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _breedCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Race'),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Poids (kg)', prefixIcon: Icon(Icons.monitor_weight_outlined)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _bloodTypeCtrl,
                  decoration: const InputDecoration(labelText: 'Groupe sanguin'),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            TextField(
              controller: _chipCtrl,
              decoration: const InputDecoration(labelText: 'N° de puce', prefixIcon: Icon(Icons.tag)),
            ),
            const SizedBox(height: 20),
            Text('Sexe', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<CatSex>(
              segments: const [
                ButtonSegment(value: CatSex.female, label: Text('Femelle'), icon: Icon(Icons.female)),
                ButtonSegment(value: CatSex.male, label: Text('Mâle'), icon: Icon(Icons.male)),
              ],
              selected: {_sex},
              onSelectionChanged: (s) => setState(() => _sex = s.first),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cake_outlined),
              title: const Text('Date de naissance'),
              subtitle: Text(birthLabel),
              onTap: _pickDate,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: scheme.outlineVariant)),
            ),
            const SizedBox(height: 20),
            Text('Allergies', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final allergen in _allergies)
                  Chip(
                    label: Text(allergen),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () =>
                        setState(() => _allergies.remove(allergen)),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                  onPressed: _addAllergen,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Vétérinaire', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            vetsAsync.when(
              data: (vets) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ChoiceChip(
                        label: const Text('Aucun'),
                        selected: _selectedVetId == null,
                        onSelected: (_) =>
                            setState(() => _selectedVetId = null),
                      ),
                      for (final vet in vets)
                        ChoiceChip(
                          label: Text(vet.name),
                          selected: _selectedVetId == vet.id,
                          onSelected: (_) =>
                              setState(() => _selectedVetId = vet.id),
                        ),
                    ],
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nouveau véto'),
                    onPressed: _addVet,
                  ),
                ],
              ),
              loading: () => const SizedBox(
                height: 32,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
