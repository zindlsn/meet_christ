import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/events_filter.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/repositories/events_repository.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:uuid/uuid.dart';

class EventService {
  final IEventRepository _repository;
  final UserService _userService;

  EventService(this._repository, this._userService);

  Future<Event> getEvent(String id) => _repository.getEvent(id);

  Future<List<Event>> getGroupEvents(String groupId) =>
      _repository.getEventsByGroup(groupId);

  Future<List<Event>> getUserEvents(String userId) =>
      _repository.getUserEvents(userId);

  Future<String> createEvent({required Event event}) async {
    final id = await _repository.createEvent(event);

    if (event.image != null) {
      await _repository.uploadEventImage(id, event.image!);
      await _repository.updateEvent(
        event.copyWith(id: id, image: event.image!),
      );
    }

    return id;
  }

  Stream<List<Event>> watchGroupEvents(String groupId) =>
      _repository.watchGroupEvents(groupId);

  Future<void> rsvpToEvent(String eventId, String userId, bool attending) =>
      _repository.rsvpToEvent(eventId, userId, attending);

  Future<List<Event>> getEventsWithoutGroup(EventsFilter filter) async {
    var events = await _repository.getEventsWithoutGroup(filter);
    for (var event in events) {
      if (event.attendees.any((item) => item.userId == _userService.user.id)) {
        event.meAttending = true;
      } else {
        event.meAttending = false;
      }
    }
    return events;
  }

  void updateEvent(Event event) {
    _repository.updateEvent(event);
  }

  // Add other business logic methods here
}

abstract class IEventRepository {
  Future<Event> getEvent(String id);
  Future<List<Event>> getEventsByGroup(String groupId);
  Future<List<Event>> getUserEvents(String userId);
  Future<String> createEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String id);
  Future<String> uploadEventImage(String eventId, Uint8List image);
  Stream<List<Event>> watchGroupEvents(String groupId);
  Future<void> rsvpToEvent(String eventId, String userId, bool attending);

  Future<List<Event>> getEventsWithoutGroup(EventsFilter filter);
}

class FirestoreEventRepository implements IEventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DatabaseService2<String, User> _userRepository;
  FirestoreEventRepository(this._userRepository);
  final _uuid = const Uuid();

  @override
  Future<Event> getEvent(String id) async {
    final doc = await _firestore.collection('events').doc(id).get();
    if (!doc.exists) throw Exception('Event not found');
    return Event.fromDto(
      attendees: [],
      organizers: [],
      EventDto.fromMap(doc.data()!, doc.id),
    );
  }

  @override
  Future<List<Event>> getEventsByGroup(String groupId) async {
    final snapshot = await _firestore
        .collection('events')
        .where('groupId', isEqualTo: groupId)
        .orderBy('startDate')
        .get();

    return snapshot.docs
        .map(
          (doc) => Event.fromDto(
            attendees: [],
            organizers: [],
            EventDto.fromMap(doc.data(), doc.id),
          ),
        )
        .toList();
  }

  @override
  Future<List<Event>> getUserEvents(String userId) async {
    final snapshot = await _firestore
        .collection('events')
        .where('attendeeIds', arrayContains: userId)
        .where(
          'endDate',
          isGreaterThanOrEqualTo: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        )
        .get();
    final events = <Event>[];
    for (var dataElement in snapshot.docs) {
      var data = dataElement.data();
      var attendees = await _userRepository.getAllByUserIds(
        (data["attendeeIds"] as List<dynamic>)
            .map((item) => item.toString())
            .toList(),
      );
      var organizers = await _userRepository.getAllByUserIds(
        (data["attendeeIds"] as List<dynamic>)
            .map((item) => item.toString())
            .toList(),
      );
      var eventUsers = attendees
          .map((user) => EventUser.attendee(user.id, dataElement.id))
          .toList();
      var event = Event.fromDto(
        attendees: eventUsers,
        organizers: organizers
            .map((user) => EventUser.host(user.id, dataElement.id))
            .toList(),
        EventDto.fromMap(data, dataElement.id),
      );

      events.add(event);
    }
    return Future.value(events);
  }

  @override
  Future<String> createEvent(Event event) async {
    final id = _uuid.v4();
    final dto = event.toDto();

    await _firestore.collection('events').doc(id).set({
      ...dto.toMap(),
      'groupId': event.group?.id,
      'attendeeIds': event.attendees.map((u) => u.userId).toList(),
      'organizerIds': event.organizers.map((u) => u.userId).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return id;
  }

  @override
  Future<void> updateEvent(Event event) async {
    final dto = event.toDto();
    await _firestore.collection('events').doc(event.id).update({
      ...dto.toMap(),
      'groupId': event.group?.id,
      'attendeeIds': event.attendees.map((u) => u.userId).toList(),
      'organizerIds': event.organizers.map((u) => u.userId).toList(),
    });
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _firestore.collection('events').doc(id).delete();
  }

  @override
  Future<String> uploadEventImage(String eventId, Uint8List image) async {
    final ref = _storage.ref('event_images/$eventId');
    await ref.putData(image);
    return await ref.getDownloadURL();
  }

  @override
  Stream<List<Event>> watchGroupEvents(String groupId) {
    return _firestore
        .collection('events')
        .where('groupId', isEqualTo: groupId)
        .orderBy('startDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Event.fromDto(
                  attendees: [],
                  organizers: [],
                  EventDto.fromMap(doc.data(), doc.id),
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> rsvpToEvent(
    String eventId,
    String userId,
    bool attending,
  ) async {
    final docRef = _firestore.collection('events').doc(eventId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      final attendeeIds = List<String>.from(doc['attendeeIds'] ?? []);

      if (attending) {
        if (!attendeeIds.contains(userId)) {
          attendeeIds.add(userId);
        }
      } else {
        attendeeIds.remove(userId);
      }

      transaction.update(docRef, {'attendeeIds': attendeeIds});
    });
  }

  @override
  Future<List<Event>> getEventsWithoutGroup(EventsFilter filter) async {
    DateTime? start;
    DateTime? endDate;
    if (filter.startDate != null) {
      start = DateTime(
        filter.startDate!.year,
        filter.startDate!.month,
        filter.startDate!.day,
      );
      endDate = start.add(Duration(days: 1));
    }

    if (filter.endDate != null) {
      endDate = DateTime(
        filter.endDate!.year,
        filter.endDate!.month,
        filter.endDate!.day,
      ).add(const Duration(days: 1));
    }

    final snapshot = await _firestore
        .collection('events')
        .where('groupId', isEqualTo: null)
        .where("startDate", isGreaterThanOrEqualTo: start)
        .where("startDate", isLessThanOrEqualTo: endDate)
        .get();

    final eventFutures = snapshot.docs
        .map((doc) => _mapDocumentToEvent(doc))
        .toList();

    return Future.wait(eventFutures);
  }

  Future<Event> _mapDocumentToEvent(DocumentSnapshot doc) async {
    // Fetch all attendees in parallel
    final attendeeIds = List<String>.from(doc['attendeeIds'] ?? []);
    final attendees = await Future.wait(
      attendeeIds.map((id) => _userRepository.getById(id)),
    );

    // Fetch all organizers in parallel
    final organizerIds = List<String>.from(doc['organizerIds'] ?? []);
    final organizers = await Future.wait(
      organizerIds.map((id) => _userRepository.getById(id)),
    );

    return Event.fromDto(
      EventDto.fromMap(doc.data()! as Map<String, dynamic>, doc.id),
      attendees: attendees
          .map((item) => EventUser.attendee(item!.id, doc.id))
          .toList(),
      organizers: organizers.whereType<EventUser>().toList(),
    );
  }
}
