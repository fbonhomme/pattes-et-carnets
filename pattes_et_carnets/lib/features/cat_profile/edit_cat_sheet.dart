import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/models/enums.dart';
import 'package:pattes_et_carnets/shared/providers/data_providers.dart';
import 'package:pattes_et_carnets/shared/providers/database_provider.dart';
import 'package:pattes_et_carnets/shared/services/care_actions.dart';
import 'package:pattes_et_carnets/shared/widgets/photo_picker.dart';

/// Camera/gallery flow for a cat's profile photo, with user feedback.
Future<void> changeCatPhoto(BuildContext context, WidgetRef ref, int catId) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final image = await pickPhoto(context, title: 'Photo de profil');
    if (image == null) return;
    await setCatPhoto(ref.read(databaseProvider), catId, image);
    messenger.showSnackBar(
      const SnackBar(content: Text('Photo enregistrée ✓'), duration: Duration(seconds: 2)),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Erreur photo : $e')));
  }
}

// ---------------------------------------------------------------------------
// Edit cat bottom sheet
// ---------------------------------------------------------------------------

class EditCatSheet extends ConsumerStatefulWidget {
  const EditCatSheet({super.key, required this.cat});

  final Cat cat;

  @override
  ConsumerState<EditCatSheet> createState() => _EditCatSheetState();
}

class _EditCatSheetState extends ConsumerState<EditCatSheet> {
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
    final photoPath =
        ref.watch(catByIdProvider(widget.cat.id)).valueOrNull?.photoPath ??
            widget.cat.photoPath;
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
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(photoPath != null ? 'Changer la photo' : 'Ajouter une photo'),
              onPressed: () => changeCatPhoto(context, ref, widget.cat.id),
            ),
            const SizedBox(height: 14),
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
