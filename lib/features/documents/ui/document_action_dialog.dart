import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/notification_service.dart';
import '../model/document.dart';
import '../../reminder/model/reminder_state.dart';
import '../../reminder/repository/reminder_state_repository.dart';
import '../../reminder/service/reminder_engine.dart';
import '../../reminder/service/reminder_scheduler.dart';
import '../../family/repository/family_repository.dart';
import 'package:doc_renewal_reminder/core/logger.dart';

/// 証件アクションダイアログ
/// 通知の一時停止・再開・完了を管理
class DocumentActionDialog extends StatefulWidget {
  final Document document;
  final String memberName;
  final VoidCallback onUpdate;

  const DocumentActionDialog({
    super.key,
    required this.document,
    required this.memberName,
    required this.onUpdate,
  });

  @override
  State<DocumentActionDialog> createState() => _DocumentActionDialogState();
}

class _DocumentActionDialogState extends State<DocumentActionDialog> {
  ReminderState? _reminderState;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminderState();
  }

  Future<void> _loadReminderState() async {
    final state = await ReminderStateRepository.getByDocumentId(widget.document.id!);
    setState(() {
      _reminderState = state;
      _isLoading = false;
    });
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
      case 'health_insurance':
        return l10n.documentTypeHealthInsurance;
      case 'mynumber_card':
        return l10n.mynumberCard;
      case 'other':
        return l10n.otherDocument;
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    switch (locale) {
      case 'ja':
        return DateFormat('yyyy年MM月dd日').format(date);
      case 'zh':
        return DateFormat('yyyy年MM月dd日').format(date);
      case 'en':
      default:
        return DateFormat('MMM d, yyyy').format(date);
    }
  }

  int _daysUntilExpiry() {
    final now = DateTime.now();
    final expiry = widget.document.expiryDate;
    return expiry.difference(now).inDays;
  }

  Future<void> _startRenewal() async {
    final l10n = AppLocalizations.of(context)!;
    
    // 確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmRenewalStart),
        content: Text(l10n.renewalStartDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      setState(() => _isLoading = true);
      
      final engine = ReminderEngine();
      await engine.confirmRenewalStarted(
        documentId: widget.document.id!,
        expectedFinishDate: widget.document.expiryDate,
      );
      
      // 既存の通知をキャンセル
      final scheduler = ReminderScheduler();
      await scheduler.cancelForDocument(widget.document.id!);
      
      // 有効期限日に最終警告通知をスケジュール
      await _scheduleExpiryDateNotification();
      
      await _loadReminderState();
      widget.onUpdate();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.renewalStarted),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.error}: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeRenewal() async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmRenewalComplete),
        content: Text(l10n.renewalCompleteDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      setState(() => _isLoading = true);
      
      final engine = ReminderEngine();
      await engine.confirmRenewalCompleted(widget.document.id!);
      
      // 通知をキャンセル
      final scheduler = ReminderScheduler();
      await scheduler.cancelForDocument(widget.document.id!);
      
      await _loadReminderState();
      widget.onUpdate();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.renewalCompleted),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.error}: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final daysLeft = _daysUntilExpiry();
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.credit_card,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDocumentTypeLabel(widget.document.documentType),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        widget.memberName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // 証件情報
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: l10n.expiryDate,
              value: _formatDate(widget.document.expiryDate),
              color: daysLeft <= 30 ? Colors.red : null,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.timer,
              label: l10n.daysRemaining,
              value: '$daysLeft ${l10n.days}',
              color: daysLeft <= 30 ? Colors.red : Colors.green,
            ),
            
            if (_reminderState != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.notifications,
                label: l10n.notificationStatus,
                value: _getStatusText(_reminderState!.status),
                color: _getStatusColor(_reminderState!.status),
              ),
            ],
            
            if (widget.document.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.note,
                label: l10n.notes,
                value: widget.document.notes!,
              ),
            ],
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // アクションボタン
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              if (_reminderState?.status == ReminderStatus.reminding) ...[
                // 通知中：更新開始ボタンを表示
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _startRenewal,
                    icon: const Icon(Icons.pause_circle_outline),
                    label: Text(l10n.startRenewal),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ] else if (_reminderState?.status == ReminderStatus.paused) ...[
                // 一時停止中：更新完了ボタンを表示
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _completeRenewal,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(l10n.completeRenewal),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // 閉じるボタン
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.close),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 有効期限日に最終警告通知をスケジュール
  Future<void> _scheduleExpiryDateNotification() async {
    final expiryDate = widget.document.expiryDate;
    final now = DateTime.now();
    
    // 有効期限日の午前9時に通知を設定
    final notificationDate = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
      9, // 午前9時
      0,
      0,
    );
    
    // 有効期限日が未来の場合のみスケジュール
    if (notificationDate.isAfter(now)) {
      // 家族メンバー情報を取得
      final member = await FamilyRepository.getById(widget.document.memberId);
      final memberName = member?.name ?? '';
      
      // 通知ID: documentId * 1000 + 999 (有効期限日用の特別な通知)
      final notificationId = widget.document.id! * 1000 + 999;
      
      final title = _getExpiryNotificationTitle();
      final body = _getExpiryNotificationBody(memberName);
      
      await NotificationService.instance.scheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: notificationDate,
        payload: 'document:${widget.document.id}',
      );
      
      AppLogger.log('[DocumentActionDialog] Scheduled expiry notification for ${widget.document.id} at $notificationDate');
    }
  }

  String _getExpiryNotificationTitle() {
    final l10n = AppLocalizations.of(context)!;
    final type = widget.document.documentType;
    
    switch (type) {
      case 'residence_card':
        return '⚠️ ${l10n.residenceCard}の有効期限が本日です！';
      case 'passport':
        return '⚠️ ${l10n.passport}の有効期限が本日です！';
      case 'drivers_license':
        return '⚠️ ${l10n.driversLicense}の有効期限が本日です！';
      case 'health_insurance':
        return '⚠️ ${l10n.insuranceCard}の有効期限が本日です！';
      case 'mynumber_card':
        return '⚠️ ${l10n.mynumberCard}の有効期限が本日です！';
      default:
        return '⚠️ 証件の有効期限が本日です！';
    }
  }

  String _getExpiryNotificationBody(String memberName) {
    final type = _getDocumentTypeLabel(widget.document.documentType);
    return '$memberNameさんの$typeは本日が有効期限です。更新をお忘れなく！';
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText(ReminderStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case ReminderStatus.normal:
        return l10n.statusNormal;
      case ReminderStatus.reminding:
        return l10n.statusReminding;
      case ReminderStatus.paused:
        return l10n.statusPaused;
    }
  }

  Color _getStatusColor(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.normal:
        return Colors.grey;
      case ReminderStatus.reminding:
        return Colors.orange;
      case ReminderStatus.paused:
        return Colors.blue;
    }
  }
}
