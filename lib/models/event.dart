import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:meet_christ/models/group.dart';
import 'package:meet_christ/models/user.dart';

class EventDto {
  final String title;
  final String uid;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String? type;
  String? imageUrl;
  int? pricePerPerson;
  List<User> attendees = [];
  List<User> organizers = [];
  final int? repeatEveryWeeks;
  final DateTime? repeatEndDate;
  final CommunityGroup? group;

  EventDto({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.uid,
    this.repeatEveryWeeks,
    this.type,
    this.repeatEndDate,
    this.group,
    this.imageUrl,
    this.pricePerPerson,
    List<User>? attendees,
    List<User>? organizers,
  }) {
    if (attendees != null) this.attendees = attendees;
    if (organizers != null) this.organizers = organizers;
  }

  // Deserialize from Firestore data map (existing)
  static EventDto fromMap(Map<String, dynamic> data, String id) {
    return EventDto(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startDate: data['startDate'] as DateTime,
      endDate: data['endDate'] as DateTime,
      location: data['location'] ?? '',
      uid: id,
      type: data['type'],
      imageUrl: data['imageUrl'],
      pricePerPerson: data['pricePerPerson'] != null
          ? data['pricePerPerson'] as int
          : null,
      repeatEveryWeeks: data['repeatEveryWeeks'] != null
          ? data['repeatEveryWeeks'] as int
          : null,
      repeatEndDate: data['repeatEndDate'] != null
          ? (data['repeatEndDate']).toDate()
          : null,
      attendees: data['attendees'] != null
          ? (data['attendees'] as List<dynamic>)
              .map((u) => User.fromMap(u as Map<String, dynamic>, ''))
              .toList()
          : [],
      organizers: data['organizers'] != null
          ? (data['organizers'] as List<dynamic>)
              .map((u) => User.fromMap(u as Map<String, dynamic>, ''))
              .toList()
          : [],
    );
  }

  // Serialize to Firestore map (existing)
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
      'attendees': attendees.map((u) => u.toMap()).toList(),
      'organizers': organizers.map((u) => u.toMap()).toList(),
    };
  }

  // === New: Create DTO from Entity ===
  factory EventDto.fromEntity(Event event) {
    return EventDto(
      title: event.title,
      description: event.description,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      uid: event.id,
      repeatEveryWeeks: event.repeatEveryWeeks,
      type: event.type,
      repeatEndDate: event.repeatEndDate,
      group: event.group,
      imageUrl: null, // no direct mapping from Uint8List image to url here
      pricePerPerson: event.pricePerPerson,
      attendees: event.attendees,
      organizers: event.organizers,
    );
  }

  // === New: Convert back to Entity ===
  Event toEntity({Uint8List? image}) {
    return Event(
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      location: location,
      id: uid,
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
  List<User> attendees = [];
  List<User> organizers = [];
  final int? repeatEveryWeeks;
  final DateTime? repeatEndDate;
  final CommunityGroup? group;

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
    List<User>? attendees,
    List<User>? organizers,
  }) {
    if (attendees != null) this.attendees = attendees;
    if (organizers != null) this.organizers = organizers;
  }

  // Optional: You can also put a fromDto helper here if you like:
  factory Event.fromDto(EventDto dto, {Uint8List? image}) {
    return Event(
      title: dto.title,
      description: dto.description,
      startDate: dto.startDate,
      endDate: dto.endDate,
      location: dto.location,
      id: dto.uid,
      repeatEveryWeeks: dto.repeatEveryWeeks,
      type: dto.type,
      repeatEndDate: dto.repeatEndDate,
      group: dto.group,
      image: image,
      pricePerPerson: dto.pricePerPerson,
      attendees: dto.attendees,
      organizers: dto.organizers,
    );
  }

  EventDto toDto() {
    return EventDto.fromEntity(this);
  }
}
