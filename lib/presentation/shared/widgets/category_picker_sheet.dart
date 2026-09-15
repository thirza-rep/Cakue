import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../di/providers.dart';

/// Bottom sheet untuk memilih kategori
class CategoryPickerSheet extends ConsumerStatefulWidget {
  final String type; // 'income' | 'expense' | 'transfer'
  final void Function(String uuid, String name, String? icon) onSelected;

  const CategoryPickerSheet({
    super.key,
    required this.type,
    required this.onSelected,
  });

  @override
  ConsumerState<CategoryPickerSheet> createState() =>
      _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<CategoryPickerSheet> {
  String? _selectedParentUuid;
  String? _selectedParentName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider(widget.type));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  if (_selectedParentUuid != null) ...[
                    IconButton(
                      onPressed: () => setState(() {
                        _selectedParentUuid = null;
                        _selectedParentName = null;
                      }),
                      icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
                    ),
                  ],
                  Text(
                    _selectedParentUuid == null
                        ? 'Pilih Kategori'
                        : _selectedParentName ?? 'Sub-kategori',
                    style: AppTextStyles.h5.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
            ),
            Expanded(
              child: categoriesAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (categories) {
                  final filtered = _selectedParentUuid == null
                      ? categories.where((c) => c.parentUuid == null).toList()
                      : categories
                          .where((c) => c.parentUuid == _selectedParentUuid)
                          .toList();

                  return GridView.builder(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final cat = filtered[i];
                      final hasChildren = categories
                          .any((c) => c.parentUuid == cat.uuid);

                      return GestureDetector(
                        onTap: () {
                          if (hasChildren) {
                            setState(() {
                              _selectedParentUuid = cat.uuid;
                              _selectedParentName = cat.name;
                            });
                          } else {
                            widget.onSelected(
                                cat.uuid, cat.name, cat.icon);
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                cat.icon ?? '📦',
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat.name,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (hasChildren) ...[
                                const SizedBox(height: 2),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
