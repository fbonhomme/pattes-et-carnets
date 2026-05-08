import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pattes_et_carnets/features/home/home_provider.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/models/enums.dart';
import 'package:pattes_et_carnets/shared/providers/database_provider.dart';
import 'package:pattes_et_carnets/shared/services/notification_service.dart';
import 'package:pattes_et_carnets/shared/widgets/cat_card.dart';
import 'package:drift/drift.dart' show Value;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Request notification permission after the first frame so the Activity is visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.requestPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final catsAsync = ref.watch(catsStreamProvider);
    final weekCountAsync = ref.watch(weeklyReminderCountProvider);

    return Scaffold(
      appBar: _buildAppBar(context, catsAsync.valueOrNull),
      body: catsAsync.when(
        data: (cats) => cats.isEmpty
            ? _EmptyState(onAdd: () => _showAddCatSheet(context, ref))
            : _CatList(cats: cats, weekCount: weekCountAsync.valueOrNull ?? 0),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCatSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un chat'),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, List<Cat>? cats) {
    return AppBar(
      leadingWidth: 48,
      leading: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: Icon(Icons.pets),
      ),
      title: const Text('Pattes & Carnets'),
      actions: [
        IconButton(
          icon: const Icon(Icons.crisis_alert),
          tooltip: 'Mode urgence',
          onPressed: () {
            if (cats != null && cats.isNotEmpty) {
              context.push('/emergency/${cats.first.id}');
            }
          },
        ),
      ],
    );
  }

  Future<void> _showAddCatSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCatSheet(ref: ref),
    );
  }
}

// ---------------------------------------------------------------------------
// Cat list + stats
// ---------------------------------------------------------------------------

class _CatList extends ConsumerWidget {
  const _CatList({required this.cats, required this.weekCount});

  final List<Cat> cats;
  final int weekCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      children: [
        Text('Mes Félins', style: theme.textTheme.headlineLarge),
        const SizedBox(height: 4),
        Text(
          'Gérez la santé et le bien-être de vos compagnons.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        for (final cat in cats) ...[
          CatCard(
            cat: cat,
            onTap: () => context.push('/cat/${cat.id}'),
            onMoreTap: () => _showCatMenu(context, cat, ref),
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 8),
        _StatsRow(weekCount: weekCount, catCount: cats.length),
      ],
    );
  }

  void _showCatMenu(BuildContext context, Cat cat, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) {
        final scheme = Theme.of(sheetCtx).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  context.push('/cat/${cat.id}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.crisis_alert_outlined),
                title: const Text('Mode urgence'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  context.push('/emergency/${cat.id}');
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: scheme.error),
                title: Text('Supprimer', style: TextStyle(color: scheme.error)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _confirmDeleteCat(context, cat, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteCat(BuildContext context, Cat cat, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        final scheme = Theme.of(dialogCtx).colorScheme;
        return AlertDialog(
          title: Text('Supprimer ${cat.name} ?'),
          content: const Text(
            'Le profil, le journal de santé et tous les rappels seront définitivement supprimés.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    ).then((confirmed) async {
      if (confirmed == true && context.mounted) {
        await _deleteCat(cat, ref);
      }
    });
  }

  Future<void> _deleteCat(Cat cat, WidgetRef ref) async {
    final reminders =
        await ref.read(remindersDaoProvider).getPendingRemindersForCat(cat.id);
    for (final r in reminders) {
      await NotificationService.cancelReminder(r.id);
    }
    await ref.read(healthEntriesDaoProvider).deleteAllForCat(cat.id);
    await ref.read(remindersDaoProvider).deleteAllForCat(cat.id);
    await ref.read(catsDaoProvider).deleteCat(cat.id);
  }
}

// ---------------------------------------------------------------------------
// Stats row
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.weekCount, required this.catCount});

  final int weekCount;
  final int catCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.calendar_today,
            iconColor: scheme.secondary,
            value: '$weekCount',
            label: 'RDV SEMAINE',
            backgroundColor: scheme.surfaceContainer,
            valueColor: scheme.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatTile(
            icon: Icons.health_and_safety,
            iconColor: scheme.onPrimaryContainer,
            value: '$catCount',
            label: 'FÉLINS',
            backgroundColor: scheme.primaryContainer,
            valueColor: scheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.backgroundColor,
    required this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color backgroundColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              color: valueColor,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: valueColor.withAlpha(180),
              letterSpacing: 1,
            ),
          ),
        ],
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
            Icon(Icons.pets, size: 72, color: scheme.primaryContainer),
            const SizedBox(height: 24),
            Text(
              'Aucun félin pour l\'instant',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre premier chat pour commencer le suivi de santé.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un chat'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add cat bottom sheet
// ---------------------------------------------------------------------------

class _AddCatSheet extends ConsumerStatefulWidget {
  const _AddCatSheet({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_AddCatSheet> createState() => _AddCatSheetState();
}

class _AddCatSheetState extends ConsumerState<_AddCatSheet> {
  final _nameController = TextEditingController();
  CatSex _sex = CatSex.female;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    final id = await widget.ref.read(catsDaoProvider).insertCat(
          CatsCompanion(
            name: Value(name),
            sex: Value(_sex),
          ),
        );
    if (mounted) {
      Navigator.pop(context);
      context.push('/cat/$id');
    }
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
        24, 16, 24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
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
          Text('Nouveau félin', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nom du chat',
              prefixIcon: Icon(Icons.pets),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 20),
          Text('Sexe', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<CatSex>(
            segments: const [
              ButtonSegment(
                value: CatSex.female,
                label: Text('Femelle'),
                icon: Icon(Icons.female),
              ),
              ButtonSegment(
                value: CatSex.male,
                label: Text('Mâle'),
                icon: Icon(Icons.male),
              ),
            ],
            selected: {_sex},
            onSelectionChanged: (s) => setState(() => _sex = s.first),
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
                  : const Text('Créer le profil'),
            ),
          ),
        ],
      ),
    );
  }
}
