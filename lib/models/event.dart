import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_christ/models/group.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/services/user_service.dart';

class EventDto {
  final String title;
  final String id;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String? type;
  String? imageUrl;
  int? pricePerPerson;
  List<String> attendeeIds = []; // Changed from User to String IDs
  List<String> organizerIds = []; // Changed from User to String IDs
  final int? repeatEveryWeeks;
  final DateTime? repeatEndDate;
  final Group? group;

  EventDto({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.id,
    this.repeatEveryWeeks,
    this.type,
    this.repeatEndDate,
    this.group,
    this.imageUrl,
    this.pricePerPerson,
    List<String>? attendeeIds,
    List<String>? organizerIds,
  }) {
    if (attendeeIds != null) this.attendeeIds = attendeeIds;
    if (organizerIds != null) this.organizerIds = organizerIds;
  }

  // Deserialize from Firestore data map
  static EventDto fromMap(Map<String, dynamic> data, String id) {
    var event =  EventDto(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startDate: data['startDate']?.toDate() ?? DateTime.now(),
      endDate: data['endDate']?.toDate() ?? DateTime.now(),
      location: data['location'] ?? '',
      id: id,
      type: data['type'],
      imageUrl: data['imageUrl'],
      pricePerPerson: data['pricePerPerson'] as int?,
      repeatEveryWeeks: data['repeatEveryWeeks'] as int?,
      repeatEndDate: data['repeatEndDate']?.toDate(),
      attendeeIds: data['attendeeIds'] != null
          ? List<String>.from(data['attendeeIds'])
          : [],
      organizerIds: data['organizerIds'] != null
          ? List<String>.from(data['organizerIds'])
          : [],
    );

    return event;
  }

  // Serialize to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'location': location,
      if (type != null) 'type': type,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (pricePerPerson != null) 'pricePerPerson': pricePerPerson,
      if (repeatEveryWeeks != null) 'repeatEveryWeeks': repeatEveryWeeks,
      if (repeatEndDate != null) 'repeatEndDate': repeatEndDate,
      'attendeeIds': attendeeIds,
      'organizerIds': organizerIds,
      if (group != null) 'groupId': group!.id,
    };
  }

  // Create DTO from Entity
  factory EventDto.fromEntity(Event event) {
    return EventDto(
      title: event.title,
      description: event.description,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      id: event.id,
      repeatEveryWeeks: event.repeatEveryWeeks,
      type: event.type,
      repeatEndDate: event.repeatEndDate,
      group: event.group,
      imageUrl: null, // no direct mapping from Uint8List image to url here
      pricePerPerson: event.pricePerPerson,
      attendeeIds: event.attendees.map((u) => u.userId).toList(),
      organizerIds: event.organizers.map((u) => u.userId).toList(),
    );
  }

  // Convert back to Entity (requires fetching User objects separately)
  Event toEntity({
    Uint8List? image,
    required List<EventUser> attendees,
    required List<EventUser> organizers,
  }) {
    return Event(
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      location: location,
      id: id,
      repeatEveryWeeks: repeatEveryWeeks,
      type: type,
      repeatEndDate: repeatEndDate,
      group: group,
      image: image,
      pricePerPerson: pricePerPerson,
      attendees: attendees,
      organizers: organizers,
    );
  }
}

class Event {
  final String title;
  final String id;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String? type;
  Uint8List? image;
  int? pricePerPerson;
  List<EventUser> attendees = [];
  List<EventUser> organizers = [];
  bool meAttending = false;
  final int? repeatEveryWeeks;
  final DateTime? repeatEndDate;
  final Group? group;

  Event({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.id,
    this.repeatEveryWeeks,
    this.type,
    this.repeatEndDate,
    this.group,
    this.image,
    this.pricePerPerson,
    List<EventUser>? attendees,
    List<EventUser>? organizers,
    this.meAttending = false,
  }) {
    if (attendees != null) this.attendees = attendees;
    if (organizers != null) this.organizers = organizers;
  }

  factory Event.fromDto(
    EventDto dto, {
    Uint8List? image,
    required List<EventUser> attendees,
    required List<EventUser> organizers,
  }) {
    return Event(
      title: dto.title,
      description: dto.description,
      startDate: dto.startDate,
      endDate: dto.endDate,
      location: dto.location,
      id: dto.id,
      repeatEveryWeeks: dto.repeatEveryWeeks,
      type: dto.type,
      repeatEndDate: dto.repeatEndDate,
      group: dto.group,
      image: image,
      pricePerPerson: dto.pricePerPerson,
      attendees: attendees,
      organizers: organizers,
      meAttending: attendees.any(
        (attendee) => attendee.userId == GetIt.I.get<UserService>().user.id,
      ),
    );
  }

  void addAttendees(List<EventUser> newAttendees) {
    for (var attendee in newAttendees) {
      if (!attendees.any((a) => a.userId == attendee.userId)) {
        attendees.add(attendee);
      }
    }
  }

  void addAttendee(EventUser attendee) {
    if (!attendees.any((a) => a.userId == attendee.userId)) {
      attendees.add(attendee);
    }
  }

  EventDto toDto() {
    return EventDto.fromEntity(this);
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? type,
    Uint8List? image,
    int? pricePerPerson,
    List<EventUser>? attendees,
    List<EventUser>? organizers,
    int? repeatEveryWeeks,
    DateTime? repeatEndDate,
    Group? group,
    bool clearImage = false,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      type: type ?? this.type,
      image: clearImage ? null : (image ?? this.image),
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      attendees: attendees ?? List<EventUser>.from(this.attendees),
      organizers: organizers ?? List<EventUser>.from(this.organizers),
      repeatEveryWeeks: repeatEveryWeeks ?? this.repeatEveryWeeks,
      repeatEndDate: repeatEndDate ?? this.repeatEndDate,
      group: group ?? this.group,
    );
  }
}
