import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../../core/database/db_provider.dart';
import '../../../core/database/hive_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../repository/document_repository.dart';
import 'document_edit_page.dart';
import 'document_action_dialog.dart';
import '../../navigation/member_selector_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// 全メンバーの証件一覧画面（製品レベルUI）
/// 証件管理の中心画面
class DocumentAllListPage extends StatefulWidget {
  const DocumentAllListPage({super.key});

  @override
  State<DocumentAllListPage> createState() => _DocumentAllListPageState();
}

class _DocumentAllListPageState extends State<DocumentAllListPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<DocumentWithMember> _documentsWithMembers = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  String _filterMode = 'all'; // 'self', 'all', or memberId - デフォルトは全員表示

  @override
  bool get wantKeepAlive => false; // 毎回リロード

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initAndLoad();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initAndLoad() async {
    if (kIsWeb) {
      await HiveProvider.initialize();
    } else {
      await DBProvider.database;
    }
    await _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    try {
      final docs = await DocumentRepository.getAllWithMemberInfo();
      setState(() {
        _documentsWithMembers = docs;
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
                Expanded(child: Text('${l10n.loadDocumentsFailed}: $e')),
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

  List<DocumentWithMember> _getFilteredDocuments() {
    if (_filterMode == 'all') {
      return _documentsWithMembers;
    } else if (_filterMode == 'self') {
      return _documentsWithMembers
          .where((d) => d.member.relationship == 'self')
          .toList();
    }
    return _documentsWithMembers;
  }

  List<DocumentWithMember> _getSortedDocuments(
      List<DocumentWithMember> docs) {
    final now = DateTime.now();
    final alertDocs = <DocumentWithMember>[];
    final normalDocs = <DocumentWithMember>[];

    for (final doc in docs) {
      final daysUntilExpiry =
          doc.document.expiryDate.difference(now).inDays;
      if (daysUntilExpiry <= 90) {
        alertDocs.add(doc);
      } else {
        normalDocs.add(doc);
      }
    }

    // アラート期間内: 期限が近い順
    alertDocs.sort((a, b) =>
        a.document.expiryDate.compareTo(b.document.expiryDate));

    // アラート期間外: 本人→家族の順
    normalDocs.sort((a, b) {
      if (a.member.relationship == 'self' &&
          b.member.relationship != 'self') {
        return -1;
      } else if (a.member.relationship != 'self' &&
          b.member.relationship == 'self') {
        return 1;
      }
      return a.document.expiryDate.compareTo(b.document.expiryDate);
    });

    return [...alertDocs, ...normalDocs];
  }

  Future<void> _addDocument() async {
    final memberId = await showDialog<int>(
      context: context,
      builder: (context) => const MemberSelectorDialog(),
    );

    if (memberId != null && mounted) {
      final result = await Navigator.push<dynamic>(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentEditPage(memberId: memberId),
        ),
      );
      if (result != null) {
        _animationController.reset();
        await _loadDocuments();
        
        // カレンダーデータが返されている場合、カレンダーに追加
        if (result is Map<String, dynamic> && mounted) {
          await _addToCalendar(result);
        }
      }
    }
  }

  Future<void> _addToCalendar(Map<String, dynamic> data) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final documentTypeLabel = _getDocumentTypeLabel(data['documentType'] as String);
      final expiryDate = data['expiryDate'] as DateTime;
      final reminderStartDate = data['reminderStartDate'] as DateTime;
      final documentNumber = data['documentNumber'] as String;
      final notes = data['notes'] as String;
      
      final Event event = Event(
        title: '$documentTypeLabel ${l10n.reminderStartDate}',
        description: '${l10n.expiryDate}: ${DateFormat('yyyy/MM/dd').format(expiryDate)}\n'
            '${l10n.reminderStartDate}: ${DateFormat('yyyy/MM/dd').format(reminderStartDate)}\n'
            '${documentNumber.isNotEmpty ? '${l10n.documentNumber}: $documentNumber\n' : ''}'
            '${notes.isNotEmpty ? '${l10n.notes}: $notes' : ''}',
        location: '',
        startDate: reminderStartDate,
        endDate: reminderStartDate.add(const Duration(hours: 1)),
        allDay: true,
      );

      await Add2Calendar.addEvent2Cal(event);
    } catch (e) {
      debugPrint('Failed to add to calendar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredDocs = _getFilteredDocuments();
    final sortedDocs = _getSortedDocuments(filteredDocs);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              l10n.allDocuments,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              l10n.documentItemCount(sortedDocs.length.toString()),
              style: const TextStyle(fontSize: 12),
            ),
          ],
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
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              _filterMode == 'all' ? Icons.filter_list : Icons.filter_list_off,
              color: Colors.white,
            ),
            tooltip: l10n.filterTooltip,
            onSelected: (value) {
              setState(() => _filterMode = value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'self',
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: _filterMode == 'self'
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.filterSelfOnly,
                      style: TextStyle(
                        fontWeight: _filterMode == 'self'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: _filterMode == 'all'
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.filterAll,
                      style: TextStyle(
                        fontWeight: _filterMode == 'all'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
          : sortedDocs.isEmpty
              ? _buildEmptyState()
              : _buildDocumentList(sortedDocs),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'document_all_list_fab',
        onPressed: _addDocument,
        icon: const Icon(Icons.add),
        label: Text(l10n.addDocumentButton),
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
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _filterMode == 'self' ? l10n.noOwnDocumentsYet : l10n.noDocumentsYet,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noDocumentsDesc,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: _addDocument,
              icon: const Icon(Icons.add),
              label: Text(l10n.addFirstDocument),
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

  Widget _buildDocumentList(List<DocumentWithMember> docs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index * 0.05,
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
                  index * 0.05,
                  1.0,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDocumentCard(docs[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentCard(DocumentWithMember docWithMember) {
    final l10n = AppLocalizations.of(context)!;
    final document = docWithMember.document;
    final member = docWithMember.member;
    final daysUntilExpiry =
        document.expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysUntilExpiry <= 90;
    final isExpired = daysUntilExpiry < 0;
    final isSelf = member.relationship == 'self';

    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isExpired
            ? BorderSide(color: Colors.red.shade700, width: 2.5)
            : isExpiringSoon
                ? BorderSide(color: Colors.orange.shade700, width: 2.5)
                : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showDocumentActionDialog(docWithMember),
        onSecondaryTap: () => _showContextMenu(context, docWithMember),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
            children: [
              Row(
                children: [
                  // 証件タイプアイコン
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getDocumentTypeColors(document.documentType),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getDocumentTypeColors(document.documentType)[0]
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getDocumentTypeIcon(document.documentType),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 証件情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _getDocumentTypeLabel(document.documentType),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isSelf) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.tertiary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  l10n.self,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              member.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.expiryDateLabel(_formatDate(document.expiryDate)),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ],
                        ),
                        // 備考表示
                        if (document.notes != null && document.notes!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.note_outlined,
                                size: 14,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  document.notes!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context).colorScheme.outline,
                                        fontStyle: FontStyle.italic,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                        onPressed: () => _navigateToEdit(docWithMember),
                        tooltip: l10n.edit,
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red.shade700,
                        onPressed: () => _confirmDelete(docWithMember),
                        tooltip: l10n.delete,
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.red.shade50.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ステータスバッジ
              _buildStatusBadge(daysUntilExpiry, isExpired, isExpiringSoon),
            ],
          ),
        ),
      ],
    ),
  ),
);
  }

  Widget _buildStatusBadge(int days, bool isExpired, bool isExpiringSoon) {
    final l10n = AppLocalizations.of(context)!;
    Color bgColor;
    Color textColor;
    IconData icon;
    String message;

    if (isExpired) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade900;
      icon = Icons.error;
      message = l10n.expired(days.abs().toString());
    } else if (isExpiringSoon) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade900;
      icon = Icons.warning;
      message = l10n.expiringSoon(days.toString());
    } else {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade900;
      icon = Icons.check_circle;
      message = l10n.daysLeft(days.toString());
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentTypeIcon(String type) {
    switch (type) {
      case 'residence_card':
        return Icons.badge;
      case 'passport':
        return Icons.flight;
      case 'drivers_license':
        return Icons.directions_car;
      case 'mynumber_card':
        return Icons.credit_card;
      case 'health_insurance':
        return Icons.local_hospital;
      default:
        return Icons.description;
    }
  }

  List<Color> _getDocumentTypeColors(String type) {
    switch (type) {
      case 'residence_card':
        return [Colors.blue.shade600, Colors.blue.shade400];
      case 'passport':
        return [Colors.purple.shade600, Colors.purple.shade400];
      case 'drivers_license':
        return [Colors.green.shade600, Colors.green.shade400];
      case 'mynumber_card':
        return [Colors.orange.shade600, Colors.orange.shade400];
      case 'health_insurance':
        return [Colors.red.shade600, Colors.red.shade400];
      default:
        return [Colors.grey.shade600, Colors.grey.shade400];
    }
  }

  String _getDocumentTypeLabel(String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'residence_card':
        return l10n.documentTypeResidenceCard;
      case 'passport':
        return l10n.documentTypePassport;
      case 'drivers_license':
        return l10n.documentTypeDriversLicense;
      case 'mynumber_card':
        return l10n.documentTypeMyNumber;
      case 'health_insurance':
      case 'insurance_card':
        return l10n.documentTypeHealthInsurance;
      case 'other':
        return l10n.documentTypeOther;
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    // シンプルな日付フォーマット（YYYY/MM/DD）
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmDelete(DocumentWithMember docWithMember) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDocument),
        content: Text(l10n.deleteDocumentConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteDocument(docWithMember);
    }
  }

  Future<void> _showDocumentActionDialog(DocumentWithMember docWithMember) async {
    await showDialog(
      context: context,
      builder: (context) => DocumentActionDialog(
        document: docWithMember.document,
        memberName: docWithMember.member.name,
        onUpdate: () {
          _animationController.reset();
          _loadDocuments();
        },
      ),
    );
  }

  Future<void> _navigateToEdit(DocumentWithMember docWithMember) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentEditPage(
          memberId: docWithMember.member.id!,
          document: docWithMember.document,
        ),
      ),
    );
    if (result == true) {
      _animationController.reset();
      await _loadDocuments();
    }
  }

  Future<void> _showContextMenu(BuildContext context, DocumentWithMember docWithMember) async {
    final l10n = AppLocalizations.of(context)!;
    
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width / 2 - 100,
        overlay.size.height / 2,
        overlay.size.width / 2 + 100,
        overlay.size.height / 2,
      ),
      items: [
        PopupMenuItem(
          value: 'action',
          child: Row(
            children: [
              const Icon(Icons.notifications_active),
              const SizedBox(width: 12),
              Text(l10n.notificationStatus),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit),
              const SizedBox(width: 12),
              Text(l10n.edit),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete, color: Colors.red),
              const SizedBox(width: 12),
              Text(l10n.delete, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );

    if (result == 'action') {
      await _showDocumentActionDialog(docWithMember);
    } else if (result == 'edit') {
      await _navigateToEdit(docWithMember);
    } else if (result == 'delete') {
      await _confirmDelete(docWithMember);
    }
  }

  Future<void> _deleteDocument(DocumentWithMember docWithMember) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      await DocumentRepository.delete(docWithMember.document.id!);
      
      _animationController.reset();
      await _loadDocuments();
      
      if (mounted) {
        final documentTypeLabel = _getDocumentTypeLabel(docWithMember.document.documentType);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.documentDeleted(documentTypeLabel))),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('削除エラー: $e')),
              ],
            ),
            backgroundColor: Colors.red,
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
