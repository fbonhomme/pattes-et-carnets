import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pattes_et_carnets/app/theme.dart';
import 'package:pattes_et_carnets/features/home/home_provider.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/models/reminder_extensions.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key, required this.catId});

  final String catId;

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(catId);
    if (id == null) {
      return const Scaffold(body: Center(child: Text('ID invalide')));
    }
    return _EmergencyView(catId: id);
  }
}

// ---------------------------------------------------------------------------
// Main view
// ---------------------------------------------------------------------------

class _EmergencyView extends ConsumerWidget {
  const _EmergencyView({required this.catId});

  final int catId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catAsync = ref.watch(catByIdProvider(catId));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return catAsync.when(
      data: (cat) {
        if (cat == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mode Urgence')),
            body: const Center(child: Text('Chat introuvable')),
          );
        }
        return _EmergencyContent(cat: cat);
      },
      loading: () => Scaffold(
        backgroundColor: scheme.errorContainer,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Mode Urgence')),
        body: Center(child: Text('Erreur: $e')),
      ),
    );
  }
}

class _EmergencyContent extends ConsumerWidget {
  const _EmergencyContent({required this.cat});

  final Cat cat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vetAsync = cat.vetId != null
        ? ref.watch(vetByIdProvider(cat.vetId!))
        : const AsyncData<Vet?>(null);
    final vet = vetAsync.valueOrNull;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.errorContainer,
      appBar: AppBar(
        backgroundColor: scheme.error,
        foregroundColor: scheme.onError,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, size: 22),
            const SizedBox(width: 8),
            const Text('Mode Urgence'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Quitter le mode urgence',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Cat identity card
          _SectionCard(
            child: Row(
              children: [
                _CatAvatar(cat: cat, size: 72),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                      if (cat.birthDate != null)
                        Text(
                          'Âge : ${cat.ageLabel}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      if (cat.weightKg != null)
                        Text(
                          'Poids : ${cat.weightKg!.toStringAsFixed(1)} kg',
                          style: theme.textTheme.bodyMedium,
                        ),
                      if (cat.breed != null)
                        Text(cat.breed!, style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Health & alerts card
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  icon: Icons.medical_services_outlined,
                  label: 'Santé & Alertes',
                  scheme: scheme,
                  theme: theme,
                ),
                const SizedBox(height: 16),

                // Blood type
                _InfoRow(
                  label: 'Groupe sanguin',
                  value: cat.bloodType?.isNotEmpty == true
                      ? cat.bloodType!
                      : 'Non renseigné',
                  valueStyle: cat.bloodType?.isNotEmpty == true
                      ? theme.textTheme.titleMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        )
                      : null,
                ),
                const SizedBox(height: 12),

                // Allergies
                const Text('Allergies critiques'),
                const SizedBox(height: 6),
                if (cat.allergies.isEmpty)
                  Text(
                    'Aucune allergie connue',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: cat.allergies
                        .map(
                          (a) => Chip(
                            avatar: Icon(
                              Icons.no_food_outlined,
                              size: 16,
                              color: scheme.error,
                            ),
                            label: Text(a),
                            backgroundColor: scheme.errorContainer,
                            labelStyle: TextStyle(color: scheme.onErrorContainer),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 12),

                // Chip number
                if (cat.chipNumber != null) ...[
                  _InfoRow(
                    label: 'N° puce',
                    value: cat.chipNumber!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Vet contact card
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  icon: Icons.local_hospital_outlined,
                  label: vet?.clinic ?? 'Vétérinaire référent',
                  scheme: scheme,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                if (vet != null) ...[
                  Text(
                    vet.name,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _callVet(vet.phone),
                      icon: const Icon(Icons.call),
                      label: Text('APPELER ${vet.clinic ?? vet.name}'.toUpperCase()),
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Aucun vétérinaire associé à ce chat.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick actions
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  icon: Icons.flash_on_outlined,
                  label: 'Actions rapides',
                  scheme: scheme,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Quitter le mode urgence'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _callVet(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

// ---------------------------------------------------------------------------
// Reusable sub-widgets
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.scheme,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(color: scheme.primary),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$label : ',
          style: theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: valueStyle ?? theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CatAvatar extends StatelessWidget {
  const _CatAvatar({required this.cat, required this.size});

  final Cat cat;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasPhoto = cat.photoPath != null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primaryContainer,
        image: hasPhoto
            ? DecorationImage(
                image: FileImage(File(cat.photoPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasPhoto
          ? null
          : Center(
              child: Text(
                cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimaryContainer,
                  fontFamily: 'Quicksand',
                ),
              ),
            ),
    );
  }
}
