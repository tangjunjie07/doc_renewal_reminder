import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';

/// 証件タイプ関連のユーティリティ
class DocumentTypeUtils {
  /// 証件タイプの表示名を取得（多言語対応）
  static String getDocumentTypeName(BuildContext context, String documentType) {
    final localizations = AppLocalizations.of(context)!;
    
    switch (documentType) {
      case 'residence_card':
        return localizations.documentTypeResidenceCard;
      case 'passport':
        return localizations.documentTypePassport;
      case 'drivers_license':
        return localizations.documentTypeDriversLicense;
      case 'health_insurance':
        return localizations.documentTypeHealthInsurance;
      case 'my_number':
        return localizations.documentTypeMyNumber;
      case 'other':
        return localizations.documentTypeOther;
      default:
        return documentType;
    }
  }
  
  /// 証件タイプのアイコンを取得
  static IconData getDocumentTypeIcon(String documentType) {
    switch (documentType) {
      case 'residence_card':
        return Icons.badge;
      case 'passport':
        return Icons.travel_explore;
      case 'drivers_license':
        return Icons.directions_car;
      case 'health_insurance':
        return Icons.local_hospital;
      case 'my_number':
        return Icons.credit_card;
      case 'other':
        return Icons.description;
      default:
        return Icons.description;
    }
  }
  
  /// 証件タイプの色を取得
  static Color getDocumentTypeColor(String documentType) {
    switch (documentType) {
      case 'residence_card':
        return Colors.blue;
      case 'passport':
        return Colors.purple;
      case 'drivers_license':
        return Colors.orange;
      case 'health_insurance':
        return Colors.green;
      case 'my_number':
        return Colors.teal;
      case 'other':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
