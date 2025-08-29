import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meet_christ/models/event.dart';
import 'package:uuid/uuid.dart';

class EventCommentsViewModel extends ChangeNotifier {
  final EventCommentsService eventService;
  List<EventComment> comments = [];

  late Event event;

  EventCommentsViewModel({required this.eventService}) {
    comments = [];
  }

  List<EventComment> get allComments => comments;

  String comment = "";

  void setComment(String value) {
    comment = value;
    notifyListeners();
  }

  void saveComment() {
    eventService.saveComment(
      EventCommentDto(
        id: Uuid().v4(),
        eventId: event.id,
        senderId: FirebaseAuth.instance.currentUser!.uid,
        content: comment,
      ),
    );
  }

  void clearComments() {
    comments.clear();
  }

  Future<void> loadComments() async {
    comments = await eventService.fetchComments(event.id);
    notifyListeners();
  }
}

class EventComment {
  final String id;
  final String senderId;
  final String content;
  late DateTime creationDate;
  DateTime? updatedDate;
  bool isDeleted = false;
  List<String> seenBy = [];
  EventComment({
    required this.id,
    required this.senderId,
    required this.content,
  }) {
    creationDate = DateTime.now();
  }
}

class EventCommentDto {
  final String id;
  final String senderId;
  final String content;
  late DateTime creationDate;
  DateTime? updatedDate;
  bool isDeleted = false;
  List<String> seenBy = [];
  final String eventId;

  EventCommentDto({
    required this.id,
    required this.senderId,
    required this.content,
    required this.eventId,
  }) {
    creationDate = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'creationDate': creationDate,
      'updatedDate': updatedDate,
      'isDeleted': isDeleted,
      'seenBy': seenBy,
    };
  }

  EventCommentDto fromJson(Map<String, dynamic> json) {
    return EventCommentDto(
      id: json['id'],
      senderId: json['senderId'],
      content: json['content'],
      eventId: json['eventId'],
    );
  }
}

class EventCommentsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<EventComment>> fetchComments(String eventId) async {
    var snapshot = await _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .get();

    return snapshot.docs.map((doc) {
      var data = doc.data();
      return EventComment(
        id: data['id'],
        senderId: data['senderId'],
        content: data['content'],
      );
    }).toList();
  }

  void saveComment(EventCommentDto comment) {
    _firestore
        .collection('events')
        .doc(comment.eventId)
        .collection('comments')
        .add(comment.toJson());
  }

  void updateComment(EventComment comment) {}

  void setCommentStatus(EventComment comment, bool isDeleted) {
    comment.isDeleted = isDeleted;
  }
}

class KeyManagementService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> saveEncryptionKey(SecretKey key) async {
    final keyBytes = await key.extractBytes();
    final keyString = base64Encode(keyBytes);
    await _secureStorage.write(key: 'encryption_key', value: keyString);
  }

  Future<SecretKey?> getEncryptionKey() async {
    final keyString = await _secureStorage.read(key: 'encryption_key');
    if (keyString == null) return null;
    final keyBytes = base64Decode(keyString);
    return SecretKey(keyBytes);
  }
}

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Encrypt message before sending
  Future<String> _encryptMessage(String message, SecretKey secretKey) async {
    final cipher = AesGcm.with256bits();
    final nonce = cipher.newNonce();
    final secretBox = await cipher.encrypt(
      utf8.encode(message),
      secretKey: secretKey,
      nonce: nonce,
    );
    return base64Encode([
      ...nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
  }

  ///
  /// Streams new messages from the Firestore event comments collection.
  Future<List<String>> streamNewMessagesFromEvent() async {
    var result = await _firestore
        .collection('events')
        .doc('eventId')
        .collection('comments')
        .where('isDeleted', isEqualTo: false)
        .where('seenBy', whereNotIn: [_auth.currentUser!.uid])
        .get();

    return result.docs
        .map((doc) => doc.data()['encryptedMessage'] as String)
        .toList();
  }

  Future<void> addCommentToEvent(
    String eventId,
    String message,
    SecretKey secretKey,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final encryptedMessage = await _encryptMessage(message, secretKey);

    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .add({
          'encryptedMessage': encryptedMessage,
          'creationDate': FieldValue.serverTimestamp(),
          'senderId': user.uid,
          'seenBy': [user.uid],
          'isDeleted': false,
          'updatedDate': null,
        });
  }
}

/*

  final String id;
  final String senderId;
  final String content;
  late DateTime creationDate;
  DateTime? updatedDate;
  bool isDeleted = false;
  List<String> seenBy = [];

  */
