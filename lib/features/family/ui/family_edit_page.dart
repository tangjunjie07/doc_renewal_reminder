import 'package:flutter/material.dart';
import '../../../core/database/db_provider.dart';
import '../../../core/database/hive_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../repository/family_repository.dart';
import '../model/family_member.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// 家族メンバー追加/編集画面（製品レベルUI）
class FamilyEditPage extends StatefulWidget {
  final FamilyMember? member;

  const FamilyEditPage({super.key, this.member});

  @override
  State<FamilyEditPage> createState() => _FamilyEditPageState();
}

class _FamilyEditPageState extends State<FamilyEditPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late AnimationController _animationController;

  String _relationship = 'self';
  DateTime? _dateOfBirth;
  bool _isSaving = false;

  List<Map<String, dynamic>> _getRelationships(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {'value': 'self', 'label': l10n.self, 'icon': Icons.star},
      {'value': 'spouse', 'label': l10n.spouse, 'icon': Icons.favorite},
      {'value': 'child', 'label': l10n.child, 'icon': Icons.child_care},
      {'value': 'parent', 'label': l10n.parent, 'icon': Icons.elderly},
      {'value': 'sibling', 'label': l10n.sibling, 'icon': Icons.people},
      {'value': 'other', 'label': l10n.other, 'icon': Icons.person_outline},
    ];
  }

  bool get _isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
    _initRepository();
    if (_isEditing) {
      _nameController.text = widget.member!.name;
      _relationship = widget.member!.relationship;
      _dateOfBirth = widget.member!.dateOfBirth;
    } else {
      // 新規作成時: 本人が既に登録されていればデフォルトを配偶者に設定
      _checkAndSetDefaultRelationship();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initRepository() async {
    if (kIsWeb) {
      await HiveProvider.initialize();
    } else {
      await DBProvider.database;
    }
  }

  Future<void> _checkAndSetDefaultRelationship() async {
    try {
      final members = await FamilyRepository.getAll();
      // 本人が既に登録されているかチェック
      final hasSelf = members.any((m) => m.relationship == 'self');
      if (hasSelf) {
        setState(() {
          _relationship = 'spouse'; // デフォルトを配偶者に設定
        });
      }
    } catch (e) {
      // エラーは無視（デフォルトのままにする）
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _save({bool addDocument = false}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final l10n = AppLocalizations.of(context)!;
      final member = FamilyMember(
        id: widget.member?.id,
        name: _nameController.text.trim(),
        relationship: _relationship,
        dateOfBirth: _dateOfBirth,
      );

      int? memberId;
      if (_isEditing) {
        await FamilyRepository.update(member);
        memberId = member.id;
      } else {
        memberId = await FamilyRepository.insert(member);
      }

      if (mounted) {
        if (addDocument && memberId != null) {
          // 証件追加画面に遷移するため、メンバーIDを返してダイアログを閉じる
          // DocumentEditPageは呼び出し元（document_all_list_page）で開く
          setState(() => _isSaving = false);
          Navigator.pop(context, memberId);
        } else {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(_isEditing ? l10n.memberInfoUpdated : l10n.memberAdded),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('${l10n.saveFailed}: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.editMember : l10n.addMember,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 名前入力
                    _buildSectionTitle(l10n.fullName, Icons.person),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: l10n.nameExample,
                        prefixIcon: Icon(
                          Icons.badge,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.pleaseEnterName;
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 28),

                    // 続柄選択
                    _buildSectionTitle(l10n.relationshipType, Icons.family_restroom),
                    const SizedBox(height: 12),
                    _buildRelationshipSelector(),
                    const SizedBox(height: 28),

                    // 生年月日選択
                    _buildSectionTitle(l10n.birthdayOptional, Icons.cake),
                    const SizedBox(height: 12),
                    _buildDateSelector(),
                    const SizedBox(height: 40),

                    // ヒント
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.birthdayUsageHint,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton.extended(
              heroTag: 'family_edit_fab',
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_isSaving ? l10n.saving : l10n.save),
              elevation: 4,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'family_edit_save_fab',
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(_isSaving ? l10n.saving : l10n.save),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  elevation: 4,
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  heroTag: 'family_edit_save_add_fab',
                  onPressed: _isSaving ? null : () => _save(addDocument: true),
                  icon: const Icon(Icons.post_add),
                  label: Text(l10n.saveAndAddDocument),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 6,
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }

  Widget _buildRelationshipSelector() {
    final relationships = _getRelationships(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: relationships.map((rel) {
        final isSelected = _relationship == rel['value'];
        return FilterChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                rel['icon'] as IconData,
                size: 18,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(rel['label'] as String),
            ],
          ),
          onSelected: (selected) {
            setState(() => _relationship = rel['value'] as String);
          },
          selectedColor: Theme.of(context).colorScheme.primary,
          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSelector() {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceVariant
              .withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _dateOfBirth != null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: _dateOfBirth != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _dateOfBirth != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _dateOfBirth != null
                    ? '${_dateOfBirth!.year}年${_dateOfBirth!.month}月${_dateOfBirth!.day}日'
                    : l10n.selectBirthdayOptional,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _dateOfBirth != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: _dateOfBirth != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
              ),
            ),
            if (_dateOfBirth != null)
              IconButton(
                icon: const Icon(Icons.clear),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                onPressed: () => setState(() => _dateOfBirth = null),
                tooltip: l10n.clear,
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
