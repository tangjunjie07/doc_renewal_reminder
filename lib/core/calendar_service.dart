import 'package:add_2_calendar/add_2_calendar.dart';
import 'logger.dart';

/// Helper service to add events to calendar with consistent boolean result.
class CalendarService {
  /// Tries to add [event] to the device calendar and returns true on success.
  static Future<bool> addEvent(Event event) async {
    try {
      final res = await Add2Calendar.addEvent2Cal(event);
      if (res == true) return true;
      if (res is Map) {
        final map = res as Map;
        return (map['result'] == true) || (map['success'] == true);
      }
      return false;
    } catch (e, st) {
      AppLogger.error('CalendarService.addEvent error: $e');
      AppLogger.error(st.toString());
      return false;
    }
  }
}
