import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pattes_et_carnets/app/theme.dart';
import 'package:pattes_et_carnets/shared/providers/data_providers.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/models/enums.dart';
import 'package:pattes_et_carnets/shared/providers/database_provider.dart';
import 'package:pattes_et_carnets/shared/services/care_actions.dart';
import 'package:pattes_et_carnets/shared/services/photo_storage.dart';
import 'package:pattes_et_carnets/shared/widgets/photo_picker.dart';

/// Shell tab → no catId (all entries).
/// Full-screen push → catId provided (cat-specific entries).
class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key, this.catId});

  final int? catId;

  @override
  Widget build(BuildContext context) {
    final id = catId;
    return id != null ? _CatJournalView(catId: id) : const _AllJournalView();
  }
}

// ---------------------------------------------------------------------------
// All-cats journal (shell tab)
// ---------------------------------------------------------------------------

class _AllJournalView extends ConsumerWidget {
  const _AllJournalView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(allHealthEntriesProvider);
    final catsAsync = ref.watch(catsStreamProvider);
    final cats = catsAsync.valueOrNull ?? <Cat>[];
    final catMap = <int, Cat>{for (final c in cats) c.id: c};
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Journal de santé'),
                Text(
                  'Toutes les entrées',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          entriesAsync.when(
            data: (entries) => entries.isEmpty
                ? SliverFillRemaining(
                    child: _EmptyState(
                      onAdd: () => _showEntrySheet(context, cats),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _TimelineEntry(
                          entry: entries[i],
                          catName: catMap[entries[i].catId]?.name,
                          isFirst: i == 0,
                          isLast: i == entries.length - 1,
                          onTap: () => _showEntrySheet(
                            context,
                            cats,
                            entry: entries[i],
                          ),
                          onDelete: () => deleteEntry(
                            ref.read(databaseProvider),
                            entries[i],
                          ),
                        ),
                        childCount: entries.length,
                      ),
                    ),
                  ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEntrySheet(context, cats),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Ajouter une note'),
      ),
    );
  }

  Future<void> _showEntrySheet(
    BuildContext context,
    List<Cat> cats, {
    HealthEntry? entry,
  }) async {
    if (cats.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EntrySheet(
        catId: entry?.catId ?? cats.first.id,
        cats: cats,
        entry: entry,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Per-cat journal (full-screen push from CatProfileScreen)
// ---------------------------------------------------------------------------

class _CatJournalView extends ConsumerWidget {
  const _CatJournalView({required this.catId});

  final int catId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catAsync = ref.watch(catByIdProvider(catId));
    final entriesAsync = ref.watch(catHealthEntriesProvider(catId));
    final theme = Theme.of(context);
    final catName = catAsync.valueOrNull?.name ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  catName.isEmpty ? 'Journal de santé' : 'Journal de $catName',
                ),
                if (catName.isNotEmpty)
                  Text(
                    'Suivi chronologique',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.crisis_alert),
                tooltip: 'Mode urgence',
                onPressed: () => context.push('/emergency/$catId'),
              ),
            ],
          ),
          entriesAsync.when(
            data: (entries) => entries.isEmpty
                ? SliverFillRemaining(
                    child: _EmptyState(
                      onAdd: () => _showEntrySheet(context),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _TimelineEntry(
                          entry: entries[i],
                          catName: null,
                          isFirst: i == 0,
                          isLast: i == entries.length - 1,
                          onTap: () =>
                              _showEntrySheet(context, entry: entries[i]),
                          onDelete: () => deleteEntry(
                            ref.read(databaseProvider),
                            entries[i],
                          ),
                        ),
                        childCount: entries.length,
                      ),
                    ),
                  ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEntrySheet(context),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Ajouter une note'),
      ),
    );
  }

  Future<void> _showEntrySheet(BuildContext context, {HealthEntry? entry}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EntrySheet(
        catId: catId,
        cats: const [],
        entry: entry,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline entry
// ---------------------------------------------------------------------------

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.entry,
    required this.catName,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    required this.onDelete,
  });

  final HealthEntry entry;
  final String? catName;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).colorScheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (!isFirst) Container(width: 2, height: 12, color: lineColor),
                _EntryTypeIcon(type: entry.type),
                if (!isLast)
                  Expanded(
                    child: Center(child: Container(width: 2, color: lineColor)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: isFirst ? 0 : 12,
                bottom: isLast ? 0 : 16,
              ),
              child: GestureDetector(
                onTap: onTap,
                child: _EntryCard(
                  entry: entry,
                  catName: catName,
                  onDelete: onDelete,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryTypeIcon extends StatelessWidget {
  const _EntryTypeIcon({required this.type});

  final HealthEntryType type;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(type.icon, size: 20, color: scheme.onPrimaryContainer),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.catName,
    required this.onDelete,
  });

  final HealthEntry entry;
  final String? catName;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dateStr = DateFormat('dd MMM', 'fr').format(entry.date);
    final hasPhoto = entry.photoPath != null;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.cardShadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPhoto)
            Image.file(
              File(entry.photoPath!),
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        entry.type.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: scheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(entry.title, style: theme.textTheme.titleSmall),
                if (catName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    catName!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (entry.note != null && entry.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.note!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
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

  void _confirmDelete(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text('Supprimer cette entrée'),
              textColor: Theme.of(context).colorScheme.error,
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Annuler'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_edu_outlined,
              size: 72,
              color: scheme.primaryContainer,
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune entrée dans le journal',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enregistrez les visites vétérinaires, vaccinations et autres soins.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une entrée'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add entry bottom sheet
// ---------------------------------------------------------------------------

class _EntrySheet extends ConsumerStatefulWidget {
  const _EntrySheet({
    required this.catId,
    required this.cats,
    this.entry,
  });

  final int catId;
  final List<Cat> cats;

  /// Entry being edited; null to create a new one.
  final HealthEntry? entry;

  @override
  ConsumerState<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<_EntrySheet> {
  late final _titleController = TextEditingController(text: widget.entry?.title);
  late final _noteController = TextEditingController(text: widget.entry?.note);
  late int _selectedCatId = widget.catId;
  late HealthEntryType _type = widget.entry?.type ?? HealthEntryType.note;
  late DateTime _date = widget.entry?.date ?? DateTime.now();
  late String? _photoPath = widget.entry?.photoPath;
  bool _saving = false;
  bool _saved = false;

  @override
  void dispose() {
    // A photo picked in a sheet the user then dismissed would be orphaned.
    if (!_saved && _photoPath != widget.entry?.photoPath) deletePhoto(_photoPath);
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final image = await pickPhoto(context, title: 'Photo de la note');
      if (image == null) return;
      final path = await savePhoto(image, prefix: 'entry');
      if (_photoPath != widget.entry?.photoPath) await deletePhoto(_photoPath);
      if (mounted) setState(() => _photoPath = path);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erreur photo : $e')));
    }
  }

  Future<void> _removePhoto() async {
    if (_photoPath != widget.entry?.photoPath) await deletePhoto(_photoPath);
    setState(() => _photoPath = null);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);

    final note = _noteController.text.trim();
    final dao = ref.read(healthEntriesDaoProvider);
    final editing = widget.entry;
    final data = HealthEntriesCompanion(
      catId: Value(_selectedCatId),
      type: Value(_type),
      date: Value(_date),
      title: Value(title),
      note: Value(note.isEmpty ? null : note),
      photoPath: Value(_photoPath),
    );
    if (editing == null) {
      await dao.insertEntry(data);
    } else {
      await dao.updateEntry(
        data.copyWith(id: Value(editing.id), createdAt: Value(editing.createdAt)),
      );
      if (editing.photoPath != _photoPath) await deletePhoto(editing.photoPath);
    }
    _saved = true;

    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.entry == null ? 'Nouvelle entrée' : 'Modifier l\'entrée',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            // Cat picker (only when opened from the all-cats tab)
            if (widget.cats.length > 1) ...[
              Text('Chat concerné', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: widget.cats
                    .map(
                      (cat) => ChoiceChip(
                        label: Text(cat.name),
                        selected: cat.id == _selectedCatId,
                        onSelected: (_) =>
                            setState(() => _selectedCatId = cat.id),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],

            Text('Type', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HealthEntryType.values
                  .map(
                    (t) => FilterChip(
                      avatar: Icon(t.icon, size: 16),
                      label: Text(t.label),
                      selected: t == _type,
                      onSelected: (_) => setState(() => _type = t),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),

            Text('Date', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('d MMMM yyyy', 'fr').format(_date),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              autofocus: widget.entry == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note (optionnel)',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            if (_photoPath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_photoPath!),
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(_photoPath == null ? 'Ajouter une photo' : 'Changer la photo'),
                  onPressed: _pickPhoto,
                ),
                if (_photoPath != null)
                  TextButton(
                    onPressed: _removePhoto,
                    child: const Text('Retirer'),
                  ),
              ],
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
