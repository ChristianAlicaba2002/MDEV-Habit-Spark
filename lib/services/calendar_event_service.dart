import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_spark/models/calendar_event.dart';

class CalendarEventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'calendar_events';

  // Create event
  Future<String> addEvent(CalendarEvent event) async {
    try {
      final docRef = await _firestore.collection(_collection).add(event.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add event: $e');
    }
  }

  // Read events for a specific date
  Stream<List<CalendarEvent>> getEventsForDate(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CalendarEvent.fromMap(doc.data()))
          .toList();
    });
  }

  // Read all events for a month
  Stream<List<CalendarEvent>> getEventsForMonth(String userId, DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CalendarEvent.fromMap(doc.data()))
          .where((event) =>
              event.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              event.date.isBefore(endOfMonth.add(const Duration(days: 1))))
          .toList();
    });
  }

  // Update event
  Future<void> updateEvent(String eventId, CalendarEvent event) async {
    try {
      final updatedEvent = event.copyWith(updatedAt: DateTime.now());
      final eventMap = updatedEvent.toMap();
      eventMap.remove('id'); // Remove id from update to avoid conflicts
      await _firestore
          .collection(_collection)
          .doc(eventId)
          .update(eventMap);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Get single event
  Future<CalendarEvent?> getEvent(String eventId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(eventId).get();
      if (doc.exists) {
        return CalendarEvent.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }
}
