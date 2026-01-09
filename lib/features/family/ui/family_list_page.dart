import 'package:flutter/material.dart';
import '../../../core/database/db_provider.dart';
import '../../../core/database/hive_provider.dart';
import '../repository/family_repository.dart';
import '../model/family_member.dart';
import 'family_edit_page.dart';
import '../../documents/repository/document_repository.dart';
import '../../reminder/service/reminder_scheduler.dart';
import '../../../core/logger.dart';
import '../../documents/ui/document_list_page.dart';
import '../../documents/ui/document_edit_page.dart';
import '../../../core/localization/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// 家族メンバー一覧画面（製品レベルUI）
class FamilyListPage extends StatefulWidget {
  const FamilyListPage({super.key});

  @override
  State<FamilyListPage> createState() => _FamilyListPageState();
}

class _FamilyListPageState extends State<FamilyListPage>
    with SingleTickerProviderStateMixin {
  List<FamilyMember> _members = [];
  Map<int, int> _documentCounts = {}; // メンバーIDごとの証件数
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initRepository();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initRepository() async {
    if (kIsWeb) {
      await HiveProvider.initialize();
    } else {
      await DBProvider.database;
    }
    await _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final members = await FamilyRepository.getAll();
      // 各メンバーの証件数を取得
      final counts = <int, int>{};
      for (final member in members) {
        final docs = await DocumentRepository.getByMemberId(member.id!);
        counts[member.id!] = docs.length;
      }
      setState(() {
        _members = members;
        _documentCounts = counts;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('${l10n.loadMembersFailed}: $e')),
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

  Future<void> _navigateToEdit([FamilyMember? member]) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyEditPage(member: member),
      ),
    );

    if (result != null) {
      _animationController.reset();
      await _loadMembers();

      // If FamilyEditPage returned a memberId (int) because user chose "Save & Add Document",
      // open DocumentEditPage for that member. Run in next frame to avoid Navigator lock.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (result is int) {
          _openDocumentEditorAndRefresh(result);
        }
      });
    }
  }

  Future<void> _openDocumentEditorAndRefresh(int memberId) async {
    if (!mounted) return;
    await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentEditPage(memberId: memberId),
      ),
    );

    // After returning from DocumentEditPage, refresh member list to update document counts
    if (!mounted) return;
    _animationController.reset();
    await _loadMembers();
  }

  void _navigateToDocumentList(FamilyMember member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentListPage(member: member),
      ),
    ).then((_) => _loadMembers());
  }

  Future<void> _deleteAllDocuments(FamilyMember member) async {
    final l10n = AppLocalizations.of(context)!;
    final docCount = _documentCounts[member.id] ?? 0;
    if (docCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text(l10n.noDocumentsToDelete),
            ],
          ),
          backgroundColor: Colors.blue.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(l10n.deleteAllDocuments),
          ],
        ),
        content: Text(
          l10n.deleteAllDocumentsConfirm(member.name, docCount.toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: Text(l10n.deleteAll),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final documents = await DocumentRepository.getByMemberId(member.id!);
        final scheduler = ReminderScheduler();
        for (final doc in documents) {
          try {
            await scheduler.cancelForDocument(doc.id!);
          } catch (e) {
            AppLogger.error('Failed to cancel notifications for document ${doc.id}: $e');
          }
          await DocumentRepository.delete(doc.id!);
        }
        _animationController.reset();
        await _loadMembers();
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(l10n.documentsDeleted(member.name, docCount.toString())),
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
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${l10n.deleteFailed}: $e')),
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
  }

  Future<void> _deleteMember(FamilyMember member) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(l10n.deleteMember),
          ],
        ),
        content: Text(l10n.deleteMemberConfirm(member.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FamilyRepository.delete(member.id!);
        _animationController.reset();
        await _loadMembers();
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(l10n.memberDeleted(member.name)),
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
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${l10n.deleteFailed}: $e')),
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.familyMembers,
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
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    l10n.loading,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            )
          : _members.isEmpty
              ? _buildEmptyState()
              : _buildMemberList(),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'family_list_fab',
        onPressed: () => _navigateToEdit(),
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addMember),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withAlpha((0.3 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.noFamilyMembersYet,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noFamilyMembersDesc,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: () => _navigateToEdit(),
              icon: const Icon(Icons.person_add),
              label: Text(l10n.addFirstMember),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index * 0.1,
                1.0,
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.3, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  index * 0.1,
                  1.0,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMemberCard(
                _members[index],
                _documentCounts[_members[index].id] ?? 0,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberCard(FamilyMember member, int docCount) {
    final l10n = AppLocalizations.of(context)!;
    final isSelf = member.relationship == 'self';
    final hasDocuments = docCount > 0;
    
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isSelf
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.5,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _navigateToDocumentList(member),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // アバター
              Hero(
                tag: 'member_${member.id}',
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelf
                          ? [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.tertiary,
                            ]
                          : [
                              Theme.of(context).colorScheme.secondary,
                              Theme.of(context).colorScheme.secondaryContainer,
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isSelf
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary)
                            .withAlpha((0.3 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isSelf ? Icons.star : Icons.person,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // メンバー情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            member.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelf) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.tertiary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha((0.3 * 255).round()),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              '本人',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          _getRelationshipIcon(member.relationship),
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getRelationshipLabel(member.relationship),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    if (member.dateOfBirth != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.cake_outlined,
                            size: 14,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(member.dateOfBirth!),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card,
                          size: 14,
                          color: hasDocuments
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.documentCount(docCount.toString()),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: hasDocuments
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.outline,
                                    fontWeight: hasDocuments
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // アクションボタン
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => _navigateToEdit(member),
                    tooltip: l10n.edit,
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withAlpha((0.5 * 255).round()),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasDocuments)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep),
                      color: Colors.orange.shade700,
                      onPressed: () => _deleteAllDocuments(member),
                      tooltip: l10n.deleteDocumentsTooltip,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Colors.orange.shade50.withAlpha((0.8 * 255).round()),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red.shade700,
                      onPressed: () => _deleteMember(member),
                      tooltip: l10n.deleteMemberTooltip,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Colors.red.shade50.withAlpha((0.8 * 255).round()),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRelationshipIcon(String relationship) {
    switch (relationship) {
      case 'self':
        return Icons.star;
      case 'spouse':
        return Icons.favorite;
      case 'child':
        return Icons.child_care;
      case 'parent':
        return Icons.elderly;
      case 'sibling':
        return Icons.people;
      default:
        return Icons.person;
    }
  }

  String _getRelationshipLabel(String relationship) {
    final l10n = AppLocalizations.of(context)!;
    switch (relationship) {
      case 'self':
        return l10n.self;
      case 'spouse':
        return l10n.spouse;
      case 'child':
        return l10n.child;
      case 'parent':
        return l10n.parent;
      case 'sibling':
        return l10n.sibling;
      case 'other':
        return l10n.other;
      default:
        return relationship;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
