import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pattes_et_carnets/app/theme.dart';
import 'package:pattes_et_carnets/shared/providers/data_providers.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/models/enums.dart';
import 'package:pattes_et_carnets/shared/models/reminder_extensions.dart';
import 'package:pattes_et_carnets/shared/providers/database_provider.dart';
import 'package:pattes_et_carnets/shared/services/care_actions.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _month = DateUtils.dateOnly(DateTime.now()).copyWith(day: 1);
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final catsAsync = ref.watch(catsStreamProvider);
    final remindersAsync = ref.watch(allPendingRemindersProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final db = ref.read(databaseProvider);

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
          ...remindersAsync.when<List<Widget>>(
            data: (reminders) {
              if (reminders.isEmpty) {
                return [
                  SliverFillRemaining(
                    child: _EmptyState(
                      cats: cats,
                      onAdd: () => _showReminderSheet(cats),
                    ),
                  ),
                ];
              }
              final selected = _selectedDay;
              final visible = selected == null
                  ? reminders
                  : reminders
                      .where((r) => DateUtils.isSameDay(r.dueDate, selected))
                      .toList();
              return [
                SliverToBoxAdapter(
                  child: _MonthGrid(
                    month: _month,
                    selectedDay: selected,
                    reminders: reminders,
                    onMonthChanged: (m) => setState(() => _month = m),
                    // Tapping the selected day again shows every reminder.
                    onDayTap: (d) => setState(() => _selectedDay =
                        selected != null && DateUtils.isSameDay(d, selected)
                            ? null
                            : d),
                  ),
                ),
                if (visible.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Aucun rappel ce jour-là.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final reminder = visible[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ReminderCard(
                            reminder: reminder,
                            catName: catMap[reminder.catId]?.name,
                            onTap: () =>
                                _showReminderSheet(cats, reminder: reminder),
                            onMarkDone: () => markReminderDone(db, reminder.id),
                            onDelete: () => deleteReminder(db, reminder.id),
                          ),
                        );
                      },
                      childCount: visible.length,
                    ),
                  ),
                ),
              ];
            },
            loading: () => const [
              SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (e, _) => [
              SliverFillRemaining(
                child: Center(child: Text('Erreur: $e')),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReminderSheet(cats),
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text('Ajouter un rappel'),
      ),
    );
  }

  /// Creates a reminder, or edits [reminder] when given.
  Future<void> _showReminderSheet(List<Cat> cats, {Reminder? reminder}) async {
    if (cats.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, // cover the bottom nav bar
      backgroundColor: Colors.transparent,
      builder: (_) => _ReminderSheet(
        cats: cats,
        reminder: reminder,
        initialDueDate: _selectedDay,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Month grid
// ---------------------------------------------------------------------------

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectedDay,
    required this.reminders,
    required this.onMonthChanged,
    required this.onDayTap,
  });

  /// First day of the displayed month.
  final DateTime month;
  final DateTime? selectedDay;
  final List<Reminder> reminders;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDayTap;

  static const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Worst status per day (HealthStatus is ordered upToDate < upcoming < late).
    final statusByDay = <DateTime, HealthStatus>{};
    for (final r in reminders) {
      final day = DateUtils.dateOnly(r.dueDate);
      final status = r.healthStatus;
      final current = statusByDay[day];
      if (current == null || status.index > current.index) {
        statusByDay[day] = status;
      }
    }

    final leadingBlanks = month.weekday - 1; // weeks start on Monday
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final title = DateFormat('MMMM yyyy', 'fr').format(month);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Mois précédent',
                onPressed: () =>
                    onMonthChanged(DateTime(month.year, month.month - 1)),
              ),
              Expanded(
                child: Text(
                  '${title[0].toUpperCase()}${title.substring(1)}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Mois suivant',
                onPressed: () =>
                    onMonthChanged(DateTime(month.year, month.month + 1)),
              ),
            ],
          ),
          Row(
            children: [
              for (final w in _weekdays)
                Expanded(
                  child: Text(
                    w,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView(
            // Fixed row height: square cells would fill a tablet screen.
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 48,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
              for (var d = 1; d <= daysInMonth; d++)
                _DayCell(
                  day: DateTime(month.year, month.month, d),
                  selected: selectedDay != null &&
                      DateUtils.isSameDay(selectedDay, DateTime(month.year, month.month, d)),
                  status: statusByDay[DateTime(month.year, month.month, d)],
                  onTap: onDayTap,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.status,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final HealthStatus? status;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isToday = DateUtils.isSameDay(day, DateTime.now());
    final dayStatus = status;

    // Grid cells pass tight constraints; Center lets the 42px circle keep its size.
    return Center(
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onTap(day),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? scheme.primary : null,
            border: isToday && !selected ? Border.all(color: scheme.primary) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selected ? scheme.onPrimary : null,
                ),
              ),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dayStatus == null
                      ? Colors.transparent
                      : selected
                          ? scheme.onPrimary
                          : dayStatus.statusColor(scheme),
                ),
              ),
            ],
          ),
        ),
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
    required this.onTap,
    required this.onMarkDone,
    required this.onDelete,
  });

  final Reminder reminder;
  final String? catName;
  final VoidCallback onTap;
  final VoidCallback onMarkDone;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = reminder.healthStatus;
    final statusColor = status.statusColor(scheme);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                            reminder.dueLabel,
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
                onPressed: onAdd,
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

class _ReminderSheet extends ConsumerStatefulWidget {
  const _ReminderSheet({
    required this.cats,
    this.reminder,
    this.initialDueDate,
  });

  final List<Cat> cats;

  /// Reminder being edited; null to create a new one.
  final Reminder? reminder;
  final DateTime? initialDueDate;

  @override
  ConsumerState<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends ConsumerState<_ReminderSheet> {
  late final _titleController =
      TextEditingController(text: widget.reminder?.title);
  late final _descController =
      TextEditingController(text: widget.reminder?.description);
  late int _selectedCatId = widget.reminder?.catId ?? widget.cats.first.id;
  late ReminderType _type = widget.reminder?.type ?? ReminderType.vaccin;
  late DateTime _dueDate = widget.reminder?.dueDate ??
      widget.initialDueDate ??
      DateTime.now().add(const Duration(days: 7));
  bool _saving = false;

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
    final editing = widget.reminder;
    await saveReminder(
      ref.read(databaseProvider),
      RemindersCompanion(
        id: editing == null ? const Value.absent() : Value(editing.id),
        catId: Value(_selectedCatId),
        type: Value(_type),
        dueDate: Value(_dueDate),
        title: Value(title),
        description: Value(desc.isEmpty ? null : desc),
        isDone: const Value(false),
      ),
    );

    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      // An overdue reminder being edited keeps its date selectable.
      firstDate: _dueDate.isBefore(yesterday) ? _dueDate : yesterday,
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
            Text(
              widget.reminder == null ? 'Nouveau rappel' : 'Modifier le rappel',
              style: theme.textTheme.headlineMedium,
            ),
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
              autofocus: widget.reminder == null,
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
                    : Text(widget.reminder == null ? 'Créer le rappel' : 'Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
