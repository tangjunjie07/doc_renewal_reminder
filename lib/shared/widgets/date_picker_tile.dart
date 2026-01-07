import 'package:flutter/material.dart';
import 'package:doc_renewal_reminder/core/localization/app_localizations.dart';

class DatePickerTile extends StatelessWidget {
  const DatePickerTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  final String title;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      title: Text(title),
      subtitle: Text(value != null
          ? '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}'
          : l10n.selectDate),
      trailing: const Icon(Icons.calendar_today),
      onTap: () => _selectDate(context),
    );
  }
}
