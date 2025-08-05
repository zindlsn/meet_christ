import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meet_christ/models/community.dart';
import 'package:uuid/uuid.dart';

class CommunityService {
  final ICommunityRepository _repository;

  CommunityService(this._repository);

  Future<Community> getCommunity(String id) => _repository.getCommunity(id);

  Future<List<Community>> getUserCommunities(String userId) =>
      _repository.getUserCommunities(userId);

  Future<String> createCommunity({
    required Community community,
    Uint8List? image,
  }) async {
    final id = await _repository.createCommunity(community);

    if (image != null) {
      final imageUrl = await _repository.uploadCommunityImage(id, image);
      await _repository.updateCommunity(
        community.copyWith(id: id, profileImage: image),
      );
    }

    return id;
  }

  Stream<List<Community>> watchUserCommunities(String userId) =>
      _repository.watchUserCommunities(userId);

  Future<List<Community>> getAllCommunities() async {
    return await _repository.getAllCommunities();
  }

  // Add other business logic methods here
}

abstract class ICommunityRepository {
  Future<Community> getCommunity(String id);
  Future<List<Community>> getUserCommunities(String userId);
  Future<String> createCommunity(Community community);
  Future<void> updateCommunity(Community community);
  Future<void> deleteCommunity(String id);
  Future<String> uploadCommunityImage(String communityId, Uint8List image);
  Stream<List<Community>> watchUserCommunities(String userId);

  Future<List<Community>> getAllCommunities();
}

class FirestoreCommunityRepository implements ICommunityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  FirestoreCommunityRepository();

  @override
  Future<Community> getCommunity(String id) async {
    final doc = await _firestore.collection('communities').doc(id).get();
    if (!doc.exists) throw Exception('Community not found');
    return Community.fromDto(CommunityDto.fromMap(doc.data()!, doc.id));
  }

  @override
  Future<List<Community>> getUserCommunities(String userId) async {
    final snapshot = await _firestore
        .collection('communities')
        .where('members', arrayContains: userId)
        .get();

    return snapshot.docs
        .map(
          (doc) => Community.fromDto(CommunityDto.fromMap(doc.data(), doc.id)),
        )
        .toList();
  }

  @override
  Future<String> createCommunity(Community community) async {
    final id = _uuid.v4();
    await _firestore.collection('communities').doc(id).set({
      'name': community.name,
      'description': community.description,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return id;
  }

  @override
  Future<void> updateCommunity(Community community) async {
    await _firestore
        .collection('communities')
        .doc(community.id)
        .update(community.toDto().toMap());
  }

  @override
  Future<void> deleteCommunity(String id) async {
    await _firestore.collection('communities').doc(id).delete();
  }

  @override
  Future<String> uploadCommunityImage(
    String communityId,
    Uint8List image,
  ) async {
    final ref = _storage.ref('community_images/$communityId');
    await ref.putData(image);
    return await ref.getDownloadURL();
  }

  @override
  Stream<List<Community>> watchUserCommunities(String userId) {
    return _firestore
        .collection('communities')
        .where('members.$userId', isNotEqualTo: null)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    Community.fromDto(CommunityDto.fromMap(doc.data(), doc.id)),
              )
              .toList(),
        );
  }

  @override
  Future<List<Community>> getAllCommunities() async{
    final snapshot = await _firestore
        .collection('communities')
        .get();

    return snapshot.docs
        .map(
          (doc) => Community.fromDto(CommunityDto.fromMap(doc.data(), doc.id)),
        )
        .toList();
  }
}
