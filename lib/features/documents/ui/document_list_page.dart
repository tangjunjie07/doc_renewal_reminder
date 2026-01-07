import 'package:flutter/material.dart';
import '../../../core/database/db_provider.dart';
import '../../../core/database/hive_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../repository/document_repository.dart';
import '../model/document.dart';
import '../../../features/family/model/family_member.dart';
import '../../../features/family/repository/family_repository.dart';
import 'document_edit_page.dart';
import 'document_action_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// 証件一覧画面（メンバー別）- 製品レベルUI
class DocumentListPage extends StatefulWidget {
  final FamilyMember member;

  const DocumentListPage({super.key, required this.member});

  @override
  State<DocumentListPage> createState() => _DocumentListPageState();
}

class _DocumentListPageState extends State<DocumentListPage>
    with SingleTickerProviderStateMixin {
  late DocumentRepository _repository;
  List<Document> _documents = [];
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
    _repository = DocumentRepository();
    await _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    try {
      final docs = await DocumentRepository.getByMemberId(widget.member.id!);
      setState(() {
        _documents = docs;
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

  Future<void> _navigateToEdit([Document? document]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentEditPage(
          memberId: widget.member.id!,
          document: document,
        ),
      ),
    );
    if (result == true) {
      _animationController.reset();
      await _loadDocuments();
    }
  }

  Future<void> _showDocumentActionDialog(Document document) async {
    await showDialog(
      context: context,
      builder: (context) => DocumentActionDialog(
        document: document,
        memberName: widget.member.name,
        onUpdate: () {
          _animationController.reset();
          _loadDocuments();
        },
      ),
    );
  }

  Future<void> _showContextMenu(BuildContext context, Document document) async {
    final l10n = AppLocalizations.of(context)!;
    
    // 画面の中央に表示
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
      await _showDocumentActionDialog(document);
    } else if (result == 'edit') {
      await _navigateToEdit(document);
    } else if (result == 'delete') {
      await _deleteDocument(document);
    }
  }

  Future<void> _deleteDocument(Document document) async {
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
            Text(l10n.deleteDocument),
          ],
        ),
        content: Text(
          l10n.deleteDocumentConfirm(_getDocumentTypeLabel(document.documentType)),
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
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final l10n = AppLocalizations.of(context)!;
        await FamilyRepository.delete(document.id!);
        _animationController.reset();
        await _loadDocuments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(l10n.documentDeleted(_getDocumentTypeLabel(document.documentType))),
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
        title: Column(
          children: [
            Text(
              l10n.documentsFor(widget.member.name),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              l10n.documentsCount(_documents.length),
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
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    l10n.loadingDocuments,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            )
          : _documents.isEmpty
              ? _buildEmptyState()
              : _buildDocumentList(),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'document_list_fab',
        onPressed: () => _navigateToEdit(),
        icon: const Icon(Icons.add),
        label: Text(l10n.documentAdding),
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
              l10n.documentsNotYetFor,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.addDocumentsPrompt(widget.member.name),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: () => _navigateToEdit(),
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

  Widget _buildDocumentList() {
    // 期限順にソート
    final sortedDocs = List<Document>.from(_documents)
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDocs.length,
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
              child: _buildDocumentCard(sortedDocs[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentCard(Document document) {
    final daysUntilExpiry = document.expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysUntilExpiry <= 90;
    final isExpired = daysUntilExpiry < 0;

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
        onTap: () => _showDocumentActionDialog(document),
        onLongPress: () => _navigateToEdit(document), // iOS/Android: 長押しで編集
        onSecondaryTap: () => _showContextMenu(context, document), // macOS: 右クリックでメニュー
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  // 証件タイプアイコン
                  Hero(
                    tag: 'document_${document.id}',
                    child: Container(
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
                  ),
                  const SizedBox(width: 16),
                  // 証件情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDocumentTypeLabel(document.documentType),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${l10n.expiryLabel}: ${_formatDate(document.expiryDate)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        if (document.documentNumber != null &&
                            document.documentNumber!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.numbers,
                                size: 14,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${l10n.documentNumberLabel}: ${document.documentNumber}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.outline,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ステータスバッジ
              _buildStatusBadge(daysUntilExpiry, isExpired, isExpiringSoon),
            ],
          ),
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
      message = l10n.expired(days.abs());
    } else if (isExpiringSoon) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade900;
      icon = Icons.warning;
      message = l10n.expiringSoon(days);
    } else {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade900;
      icon = Icons.check_circle;
      message = l10n.daysLeft(days);
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
        return l10n.residenceCard;
      case 'passport':
        return l10n.passport;
      case 'drivers_license':
        return l10n.driversLicense;
      case 'mynumber_card':
        return l10n.mynumberCard;
      case 'health_insurance':
      case 'insurance_card':
        return l10n.insuranceCard;
      case 'other':
        return l10n.otherDocument;
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
