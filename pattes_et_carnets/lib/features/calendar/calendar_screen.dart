import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pattes_et_carnets/app/theme.dart';
import 'package:pattes_et_carnets/features/home/home_provider.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/models/enums.dart';
import 'package:pattes_et_carnets/shared/models/reminder_extensions.dart';
import 'package:pattes_et_carnets/shared/providers/database_provider.dart';
import 'package:pattes_et_carnets/shared/services/notification_service.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(catsStreamProvider);
    final remindersAsync = ref.watch(allPendingRemindersProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final cats = catsAsync.valueOrNull ?? [];
    final catMap = {for (final c in cats) c.id: c};

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rappels & Soins'),
                Text(
                  'Gardez un œil sur la santé de vos félins.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          remindersAsync.when(
            data: (reminders) {
              if (reminders.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(
                    cats: cats,
                    onAdd: (catId) => _showAddReminderSheet(context, ref, cats, catId),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final reminder = reminders[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ReminderCard(
                          reminder: reminder,
                          catName: catMap[reminder.catId]?.name,
                          onMarkDone: () async {
                            await ref
                                .read(remindersDaoProvider)
                                .markDone(reminder.id);
                            await NotificationService.cancelReminder(reminder.id);
                          },
                          onDelete: () async {
                            await ref
                                .read(remindersDaoProvider)
                                .deleteReminder(reminder.id);
                            await NotificationService.cancelReminder(reminder.id);
                          },
                        ),
                      );
                    },
                    childCount: reminders.length,
                  ),
                ),
              );
            },
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
        onPressed: () => _showAddReminderSheet(context, ref, cats, null),
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text('Ajouter un rappel'),
      ),
    );
  }

  Future<void> _showAddReminderSheet(
    BuildContext context,
    WidgetRef ref,
    List<Cat> cats,
    int? preselectedCatId,
  ) async {
    if (cats.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddReminderSheet(
        cats: cats,
        widgetRef: ref,
        preselectedCatId: preselectedCatId ?? cats.first.id,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reminder card
// ---------------------------------------------------------------------------

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.catName,
    required this.onMarkDone,
    required this.onDelete,
  });

  final Reminder reminder;
  final String? catName;
  final VoidCallback onMarkDone;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = reminder.healthStatus;
    final statusColor = status.statusColor(scheme);
    final daysLeft = reminder.dueDate.difference(DateTime.now()).inDays;
    final dueDateLabel = _dueDateLabel(reminder.dueDate, daysLeft);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.cardShadow],
        border: Border(
          left: BorderSide(color: statusColor, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: status.statusContainerColor(scheme),
                shape: BoxShape.circle,
              ),
              child: Icon(
                reminder.type.icon,
                size: 22,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dueDateLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusChip(status: status, scheme: scheme),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(reminder.title, style: theme.textTheme.titleSmall),
                  if (catName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      catName!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (reminder.description != null &&
                      reminder.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      reminder.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Actions column
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.check_circle_outline, color: scheme.primary),
                  tooltip: 'Marquer comme fait',
                  onPressed: onMarkDone,
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: scheme.outline),
                  tooltip: 'Supprimer',
                  onPressed: () => _confirmDelete(context),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _dueDateLabel(DateTime dueDate, int daysLeft) {
    if (daysLeft < 0) return 'En retard de ${-daysLeft} j';
    return switch (daysLeft) {
      0 => 'Aujourd\'hui',
      1 => 'Demain',
      int d when d <= 30 => 'Dans $d jours',
      _ => DateFormat('d MMM', 'fr').format(dueDate),
    };
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
              title: const Text('Supprimer ce rappel'),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.scheme});

  final HealthStatus status;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.statusContainerColor(scheme),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.statusColor(scheme),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.cats, required this.onAdd});

  final List<Cat> cats;
  final void Function(int? catId) onAdd;

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
            Icon(Icons.event_available, size: 72, color: scheme.primaryContainer),
            const SizedBox(height: 24),
            Text(
              'Tous les soins sont à jour',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Aucun rappel en attente. Ajoutez un rappel pour ne rien oublier.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (cats.isNotEmpty) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => onAdd(null),
                icon: const Icon(Icons.add_alert_outlined),
                label: const Text('Ajouter un rappel'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add reminder bottom sheet
// ---------------------------------------------------------------------------

class _AddReminderSheet extends ConsumerStatefulWidget {
  const _AddReminderSheet({
    required this.cats,
    required this.widgetRef,
    required this.preselectedCatId,
  });

  final List<Cat> cats;
  final WidgetRef widgetRef;
  final int preselectedCatId;

  @override
  ConsumerState<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends ConsumerState<_AddReminderSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  late int _selectedCatId;
  ReminderType _type = ReminderType.vaccin;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedCatId = widget.preselectedCatId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);

    final desc = _descController.text.trim();
    final dao = widget.widgetRef.read(remindersDaoProvider);
    final id = await dao.insertReminder(
      RemindersCompanion(
        catId: Value(_selectedCatId),
        type: Value(_type),
        dueDate: Value(_dueDate),
        title: Value(title),
        description: Value(desc.isEmpty ? null : desc),
      ),
    );

    // Schedule the notification for this new reminder.
    final catName = widget.cats.firstWhere(
      (c) => c.id == _selectedCatId,
      orElse: () => widget.cats.first,
    ).name;
    final reminder = await dao.getReminderById(id);
    if (reminder != null) {
      await NotificationService.scheduleReminder(reminder, catName);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _dueDate = picked);
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
            Text('Nouveau rappel', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 24),

            // Cat picker (only if more than one cat)
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
                        onSelected: (_) => setState(() => _selectedCatId = cat.id),
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
              children: ReminderType.values
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

            Text('Date prévue', style: theme.textTheme.titleMedium),
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
                      DateFormat('d MMMM yyyy', 'fr').format(_dueDate),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descController,
              minLines: 2,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
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
                    : const Text('Créer le rappel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
