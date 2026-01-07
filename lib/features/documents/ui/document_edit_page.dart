import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/db_provider.dart';
import '../../../core/database/hive_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../model/document.dart';
import '../repository/document_repository.dart';
import '../../renewal_policy/data/default_policies.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:add_2_calendar/add_2_calendar.dart';

/// 証件追加・編集画面（製品レベルUI）
/// 証件番号は任意入力（セキュリティとUX向上）
class DocumentEditPage extends StatefulWidget {
  final int memberId;
  final Document? document;

  const DocumentEditPage({
    super.key,
    required this.memberId,
    this.document,
  });

  @override
  State<DocumentEditPage> createState() => _DocumentEditPageState();
}

class _DocumentEditPageState extends State<DocumentEditPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberController;
  late TextEditingController _notesController;
  
  String _selectedType = 'residence_card';
  DateTime? _expiryDate;
  int? _customReminderDays; // カスタムリマインダー日数
  String? _customReminderFrequency; // カスタム通知頻度
  bool _syncToCalendar = false; // カレンダー自動同期
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(
      text: widget.document?.documentNumber ?? '',
    );
    _notesController = TextEditingController(
      text: widget.document?.notes ?? '',
    );
    
    if (widget.document != null) {
      _selectedType = widget.document!.documentType;
      _expiryDate = widget.document!.expiryDate;
      _customReminderDays = widget.document!.customReminderDays;
      _customReminderFrequency = widget.document!.customReminderFrequency;
      _syncToCalendar = widget.document!.syncToCalendar;
      
      // 編集画面: nullの場合は元のドキュメントのタイプのデフォルト値を設定
      // これにより、編集画面でカードタイプを変更してもリマインダー設定は保持される
      _customReminderDays ??= _getDefaultReminderDays(widget.document!.documentType);
      _customReminderFrequency ??= _getDefaultReminderFrequency(widget.document!.documentType);
    } else {
      // 新規作成時: デフォルトポリシーの日数と頻度を設定
      _customReminderDays = _getDefaultReminderDays(_selectedType);
      _customReminderFrequency = _getDefaultReminderFrequency(_selectedType);
      _syncToCalendar = true; // 新規作成時はカレンダー自動同期をONに
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    if (kIsWeb) {
      await HiveProvider.initialize();
    } else {
      await DBProvider.database;
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _addToCalendar() async {
    if (_expiryDate == null) return;

    try {
      final l10n = AppLocalizations.of(context)!;
      final documentTypeLabel = _getDocumentTypeLabel(_selectedType);
      
      // 更新ポリシーから通知開始日を計算
      final reminderDays = _customReminderDays ?? _getDefaultReminderDays(_selectedType);
      final reminderStartDate = _expiryDate!.subtract(Duration(days: reminderDays));
      
      // カレンダーにはリマインダー開始日を登録（有効期限日ではなく）
      final Event event = Event(
        title: '$documentTypeLabel ${l10n.reminderStartDate}',
        description: '${l10n.expiryDate}: ${DateFormat('yyyy/MM/dd').format(_expiryDate!)}\n'
            '${l10n.reminderStartDate}: ${DateFormat('yyyy/MM/dd').format(reminderStartDate)}\n'
            '${_numberController.text.isNotEmpty ? '${l10n.documentNumber}: ${_numberController.text}\n' : ''}'
            '${_notesController.text.isNotEmpty ? '${l10n.notes}: ${_notesController.text}' : ''}',
        location: '',
        startDate: reminderStartDate,  // リマインダー開始日
        endDate: reminderStartDate.add(const Duration(hours: 1)),
        allDay: true,
      );

      final result = await Add2Calendar.addEvent2Cal(event);
      
      if (mounted) {
        final l10nMsg = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  result ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result 
                        ? l10nMsg.addedToCalendar 
                        : l10nMsg.failedToAddToCalendar,
                  ),
                ),
              ],
            ),
            backgroundColor: result ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10nMsg = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('${l10nMsg.error}: $e')),
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

  // 保存時にサイレントにカレンダーに追加（エラーメッセージは表示しない）
  Future<void> _addToCalendarSilently() async {
    if (_expiryDate == null) return;

    try {
      final l10n = AppLocalizations.of(context)!;
      final documentTypeLabel = _getDocumentTypeLabel(_selectedType);
      
      final reminderDays = _customReminderDays ?? _getDefaultReminderDays(_selectedType);
      final reminderStartDate = _expiryDate!.subtract(Duration(days: reminderDays));
      
      final Event event = Event(
        title: '$documentTypeLabel ${l10n.reminderStartDate}',
        description: '${l10n.expiryDate}: ${DateFormat('yyyy/MM/dd').format(_expiryDate!)}\n'
            '${l10n.reminderStartDate}: ${DateFormat('yyyy/MM/dd').format(reminderStartDate)}\n'
            '${_numberController.text.isNotEmpty ? '${l10n.documentNumber}: ${_numberController.text}\n' : ''}'
            '${_notesController.text.isNotEmpty ? '${l10n.notes}: ${_notesController.text}' : ''}',
        location: '',
        startDate: reminderStartDate,
        endDate: reminderStartDate.add(const Duration(hours: 1)),
        allDay: true,
      );

      await Add2Calendar.addEvent2Cal(event);
    } catch (e) {
      // サイレント実行のため、エラーは無視
      debugPrint('Failed to add to calendar: $e');
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

  Future<void> _save({bool addAnother = false}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_expiryDate == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.pleaseSelectExpiryDate)),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final l10n = AppLocalizations.of(context)!;
      final document = Document(
        id: widget.document?.id,
        memberId: widget.memberId,
        documentType: _selectedType,
        documentNumber: _numberController.text.trim(),
        expiryDate: _expiryDate!,
        customReminderDays: _customReminderDays,
        customReminderFrequency: _customReminderFrequency,
        syncToCalendar: _syncToCalendar,
        notes: _notesController.text.trim(),
      );

      if (widget.document == null) {
        await DocumentRepository.insert(document);
      } else {
        await DocumentRepository.update(document);
      }

      // カレンダー自動同期が有効な場合、カレンダーに追加
      if (_syncToCalendar && mounted) {
        await _addToCalendarSilently();
      }

      if (mounted) {
        if (addAnother) {
          // フォームをリセットして次の追加に備える
          setState(() {
            _isLoading = false;
            _selectedType = 'residence_card';
            _numberController.clear();
            _expiryDate = null;
            _customReminderDays = _getDefaultReminderDays('residence_card');
            _customReminderFrequency = _getDefaultReminderFrequency('residence_card');
            _syncToCalendar = false;
            _notesController.clear();
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.documentAdded)),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.document == null ? l10n.documentAdded : l10n.documentUpdated,
                    ),
                  ),
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
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('エラー: $e')),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
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
      body: CustomScrollView(
        slivers: [
          // Gradient AppBar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.document == null ? l10n.addDocument : l10n.editDocument,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Document Type Selection
                      Text(
                        l10n.documentType,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildDocumentTypeGrid(),
                      
                      const SizedBox(height: 32),
                      
                      // Expiry Date
                      Text(
                        l10n.expiryDate,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildExpiryDateCard(),
                      
                      const SizedBox(height: 24),
                      
                      // Reminder Period
                      Text(
                        l10n.reminderSettings,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.reminderPeriodQuestion,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildReminderPeriodSelector(),
                      
                      const SizedBox(height: 24),
                      
                      // Notification Frequency
                      Text(
                        l10n.notificationFrequency,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildNotificationFrequencySelector(),
                      
                      const SizedBox(height: 32),
                      
                      // Document Number (Optional)
                      Text(
                        l10n.documentNumberOptional,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.securityNotRequired,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _numberController,
                        decoration: InputDecoration(
                          hintText: '例: AB1234567',
                          prefixIcon: Icon(
                            Icons.numbers,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.3),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Notes
                      Text(
                        l10n.notesOptional,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: l10n.reminderExample,
                          prefixIcon: Icon(
                            Icons.note,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.3),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // カレンダー自動同期トグル
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.sync,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.syncToCalendar,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.syncToCalendarDescription,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Switch(
                              value: _syncToCalendar,
                              onChanged: (value) {
                                setState(() {
                                  _syncToCalendar = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _save,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.save),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.document == null ? l10n.add : l10n.save,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      // 新規追加時のみ「保存して次を追加」ボタンを表示
                      if (widget.document == null) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton.tonal(
                            onPressed: _isLoading ? null : () => _save(addAnother: true),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle_outline),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.saveAndAddAnother,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeGrid() {
    final l10n = AppLocalizations.of(context)!;
    final types = [
      {
        'type': 'residence_card',
        'label': l10n.residenceCard,
        'icon': Icons.credit_card,
        'colors': [Color(0xFF6B4EFF), Color(0xFF9D7BFF)],
      },
      {
        'type': 'passport',
        'label': l10n.passport,
        'icon': Icons.travel_explore,
        'colors': [Color(0xFF00B4DB), Color(0xFF0083B0)],
      },
      {
        'type': 'drivers_license',
        'label': l10n.driversLicense,
        'icon': Icons.directions_car,
        'colors': [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      },
      {
        'type': 'insurance_card',
        'label': l10n.insuranceCard,
        'icon': Icons.medical_services,
        'colors': [Color(0xFF4CAF50), Color(0xFF81C784)],
      },
      {
        'type': 'mynumber_card',
        'label': l10n.mynumberCard,
        'icon': Icons.badge,
        'colors': [Color(0xFFFF9800), Color(0xFFFFB74D)],
      },
      {
        'type': 'other',
        'label': l10n.otherDocument,
        'icon': Icons.description,
        'colors': [Color(0xFF9E9E9E), Color(0xFFBDBDBD)],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = _selectedType == type['type'];
        
        return InkWell(
          onTap: () {
            setState(() {
              _selectedType = type['type'] as String;
              // 新規画面: カードタイプ変更時にデフォルト値を適用
              // 編集画面: ユーザーが選択した値を保持（変更しない）
              if (widget.document == null) {
                _customReminderDays = _getDefaultReminderDays(_selectedType);
                _customReminderFrequency = _getDefaultReminderFrequency(_selectedType);
              }
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: type['colors'] as List<Color>,
                    )
                  : null,
              color: isSelected
                  ? null
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (type['colors'] as List<Color>)[0].withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type['icon'] as IconData,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  type['label'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpiryDateCard() {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => _selectExpiryDate(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _expiryDate != null
                ? [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ]
                : [
                    Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.5),
                    Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.5),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _expiryDate != null
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _expiryDate != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today,
                color: _expiryDate != null
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _expiryDate == null ? l10n.dateToSelect : l10n.selectedDate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _expiryDate != null
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _expiryDate == null
                        ? l10n.tapToSelect
                        : _formatDate(_expiryDate!),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _expiryDate != null
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: _expiryDate != null
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderPeriodSelector() {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      {'label': l10n.oneMonthBefore, 'days': 30, 'icon': Icons.looks_one},
      {'label': l10n.threeMonthsBefore, 'days': 90, 'icon': Icons.looks_3},
      {'label': l10n.sixMonthsBefore, 'days': 180, 'icon': Icons.looks_6},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = _customReminderDays == option['days'];
        return FilterChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                option['icon'] as IconData,
                size: 18,
                color: isSelected
                    ? Theme.of(context).colorScheme.onSecondaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(option['label'] as String),
            ],
          ),
          onSelected: (selected) {
            setState(() {
              _customReminderDays = option['days'] as int?;
            });
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedColor: Theme.of(context).colorScheme.secondaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.onSecondaryContainer,
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }

  /// 証件タイプに応じたデフォルトリマインダー日数を取得
  int _getDefaultReminderDays(String documentType) {
    final policy = DefaultPolicies.getByDocumentType(documentType);
    return policy.daysBeforeExpiry;
  }

  /// 証件タイプに応じたデフォルト通知頻度を取得
  String _getDefaultReminderFrequency(String documentType) {
    return DefaultPolicies.getDefaultReminderFrequency(documentType);
  }

  /// 日付を言語に応じたフォーマットで表示
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

  Widget _buildNotificationFrequencySelector() {
    final l10n = AppLocalizations.of(context)!;
    
    final frequencies = [
      {'value': 'daily', 'label': l10n.reminderFrequencyDaily},
      {'value': 'weekly', 'label': l10n.reminderFrequencyWeekly},
      {'value': 'biweekly', 'label': l10n.reminderFrequencyBiweekly},
      {'value': 'monthly', 'label': l10n.reminderFrequencyMonthly},
    ];

    // 編集画面では初期値を保持、新規画面ではnullなので現在のタイプのデフォルト値を使用
    final currentFrequency = _customReminderFrequency ?? _getDefaultReminderFrequency(_selectedType);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: frequencies.map((freq) {
        final isSelected = currentFrequency == freq['value'];
        
        return InkWell(
          onTap: () {
            setState(() {
              _customReminderFrequency = freq['value'] as String?;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              freq['label'] as String,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    final initialDate = _expiryDate ?? now.add(const Duration(days: 365));
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 20),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }
}
