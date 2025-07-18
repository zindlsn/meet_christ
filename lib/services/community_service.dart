import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/group.dart';
import 'package:meet_christ/repositories/events_repository.dart';
import 'package:meet_christ/repositories/file_repository.dart';

class CommunityService {
  final DatabaseService2<String, CommunityDto> adapter;
  final FileRepository fileRepository;
  CommunityService({required this.adapter, required this.fileRepository});

  Future<Community> create(Community data) async {
    CommunityDto dto = data.toDto();

    var imagePath = await fileRepository.uploadImage(data.profileImage);
    dto.profileImageUrls = imagePath;
    CommunityDto createdDto = await adapter.create(dto);

    Community createdEntity = Community.fromDto(createdDto);
    return createdEntity;
  }

  Future<List<Community>?> getAllById(String id) async {
    var result = await adapter.getAllById(id);
    if (result != null) {
      return result.map((dto) => Community.fromDto(dto)).toList();
    }
    return null;
  }

  Future<bool> update(Community data) async {
    CommunityDto dto = data.toDto();
    bool isUpdated = await adapter.update(dto);
    return isUpdated;
  }

  Future<List<Community>> createAll(List<Community> allData) async {
    List<CommunityDto> createdDto = await adapter.createAll(
      allData.map((data) => data.toDto()).toList(),
    );
    var savedData = createdDto.map((dto) => Community.fromDto(dto)).toList();
    return savedData;
  }

  Future<List<Community>> getAll() async {
    var retrieved = await adapter.getAll();
    return retrieved.map((dto) => Community.fromDto(dto)).toList();
  }

  Future<Community?> getById(String id) async {
    var result = await adapter.getById(id);
    if (result != null) {
      return Community.fromDto(result);
    }
    return null;
  }
}

class CommunityRepository implements DatabaseService2<String, CommunityDto> {
  final DatabaseService2<String, CommunityDto> adapter;

  CommunityRepository({required this.adapter});

  @override
  Future<CommunityDto> create(CommunityDto data) async {
    return await adapter.create(data);
  }

  @override
  Future<List<CommunityDto>?> getAllById(String id) async {
    return await adapter.getAllById(id);
  }

  @override
  Future<bool> update(CommunityDto data) async {
    return await adapter.update(data);
  }

  @override
  Future<List<CommunityDto>> createAll(List<CommunityDto> allData) async {
    return await adapter.createAll(allData);
  }

  @override
  Future<List<CommunityDto>> getAll() async {
    return await adapter.getAll();
  }

  @override
  Future<CommunityDto?> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }
}

class CommunityDataSource implements DatabaseService2<String, CommunityDto> {
  final CollectionReference col = FirebaseFirestore.instance.collection(
    "communities",
  );

  @override
  Future<List<CommunityDto>> createAll(List<CommunityDto> allData) {
    throw UnimplementedError();
  }

  @override
  Future<List<CommunityDto>> getAll() async {
    final QuerySnapshot snapshot = await col.get();
    var result = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return CommunityDto(
        id: doc.id,
        uid: data['uid'] ?? '',
        name: data['name'] ?? '',
        description: data['description'] ?? '',
      );
    }).toList();

    for (CommunityDto c in result) {
      var eventsSaved = await getEventsForCommunity(c.id);
      c.copyWith(events: eventsSaved);
    }

    return result;
  }

  @override
  Future<List<CommunityDto>?> getAllById(String id) async {
    final doc = await col.doc(id).get();
    if (!doc.exists) return null;
  }

  @override
  Future<bool> update(CommunityDto data) {
    col.doc(data.id).update(data.toMap());
    updateEventsForCommunity(data.id, data.events);
    if (data.communityGroups != null) {
      updateCommunityGroupsForCommunity(data.id, data.communityGroups!);
    }
    return Future.value(true);
  }

  Future<List<EventDto>> getEventsForCommunity(String communityId) async {
    final col = FirebaseFirestore.instance.collection('communities');

    final snapshot = await col.doc(communityId).collection('events').get();
    List<EventDto> result = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> element in snapshot.docs) {
      result.add(EventDto.fromMap(element.data(), element.id));
    }

    return result;
  }

  Future<List<CommunityDto>> getCommunityGroupsForCommunity(
    String communityId,
  ) async {
    final col = FirebaseFirestore.instance.collection('communities');

    final snapshot = await col
        .doc(communityId)
        .collection('communitygroups')
        .get();
    List<CommunityDto> result = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> element in snapshot.docs) {
      result.add(CommunityDto.fromMap(element.data(), element.id));
    }

    return result;
  }

  Future<void> updateCommunityGroupsForCommunity(
    String communityId,
    List<CommunityGroupDto> communityGroups,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final communityGroupsCollection = firestore
        .collection('communities')
        .doc(communityId)
        .collection('communitygroups');

    for (var eventDto in communityGroups) {
      final docRef = communityGroupsCollection.doc(eventDto.id);
      batch.set(docRef, eventDto.toMap(), SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> updateEventsForCommunity(
    String communityId,
    List<EventDto> eventDtos,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final eventsCollection = firestore
        .collection('communities')
        .doc(communityId)
        .collection('events');

    for (var eventDto in eventDtos) {
      final docRef = eventsCollection.doc(eventDto.uid);
      try {
        batch.update(docRef, eventDto.toMap());
      } catch (ex) {
        await eventsCollection.add(eventDto.toMap());
      }
    }

    await batch.commit();
  }

  @override
  Future<CommunityDto?> getById(String id) async {
    final doc = await col.doc(id).get();
    if (!doc.exists) return null;
    var data = doc.data() as Map<String, dynamic>;
    CommunityDto.fromMap(data, doc.id);
  }

  @override
  Future<CommunityDto> create(CommunityDto data) async {
    final docRef = col.doc();
    await docRef.set(data.toMap());
    return data;
  }
}

abstract class FirestoreModel<K, T> {
  Map<String, dynamic> toMap();

  T fromMap(Map<String, dynamic> map);

  String get id;
}

class DataServiceGeneric<K, T> implements DatabaseService2<K, T> {
  final DatabaseService2<K, T> adapter;

  DataServiceGeneric({required this.adapter});

  @override
  Future<T> create(T data) async {
    return await adapter.create(data);
  }

  @override
  Future<List<T>?> getAllById(K id) async {
    return await adapter.getAllById(id);
  }

  @override
  Future<bool> update(T data) async {
    return await adapter.update(data);
  }

  @override
  Future<List<T>> createAll(List<T> allData) async {
    return await adapter.createAll(allData);
  }

  @override
  Future<List<T>> getAll() async {
    return await adapter.getAll();
  }

  @override
  Future<T?> getById(K id) {
    // TODO: implement getById
    throw UnimplementedError();
  }
}

class CommunityGroupService
    implements DatabaseService2<String, CommunityGroup> {
  final DatabaseService2<String, CommunityGroup> adapter;

  CommunityGroupService({
    required this.adapter,
    required FileRepository fileRepository,
  });

  @override
  Future<CommunityGroup> create(CommunityGroup data) async {
    return await adapter.create(data);
  }

  @override
  Future<List<CommunityGroup>?> getAllById(String id) async {
    return await adapter.getAllById(id);
  }

  @override
  Future<bool> update(CommunityGroup data) async {
    return await adapter.update(data);
  }

  @override
  Future<List<CommunityGroup>> createAll(List<CommunityGroup> allData) async {
    return await adapter.createAll(allData);
  }

  @override
  Future<List<CommunityGroup>> getAll() async {
    return await adapter.getAll();
  }

  @override
  Future<CommunityGroup?> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }
}


/*
class FirestoreCommunityGroupAdapterGeneric<K, T extends FirestoreModel>
    implements DatabaseService2<K, T> {
  late CollectionReference col;

  final String collection;

  FirestoreCommunityGroupAdapterGeneric({required this.collection}) {
    col = FirebaseFirestore.instance.collection(collection);
  }
  @override
  Future<T> create(T data) async {
    final docRef = col.doc();
    await docRef.set(data.toMap());
    return data;
  }

  @override
  Future<List<T>> createAll(List<T> allData) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final item in allData) {
      final docRef = col.doc();
      batch.set(docRef, item.toMap());
    }

    await batch.commit();
    return allData;
  }

  @override
  Future<List<T>> getAll() async {
    QuerySnapshot snapshot = await col.get();
    List<T> result =
        snapshot.docs
                .map(
                  (doc) => CommunityGroup.fromMap(
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList()
            as List<T>;

    return result;
  }

  @override
  Future<List<T>?> getAllById(K id) async {
    final snapshot = await col.where('id', isEqualTo: id).get();
    if (snapshot.docs.isEmpty) return null;

    return snapshot.docs
            .map(
              (doc) =>
                  CommunityGroup.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList()
        as List<T>;
  }

  @override
  Future<bool> update(T data) async {
    try {
      await col.doc(data.id).update(data.toMap());
      return true;
    } catch (e) {
      print("Firestore update error: $e");
      return false;
    }
  }
}

class FirestoreCommunityGroupAdapter2
    implements DatabaseService2<String, CommunityGroup> {
  final CollectionReference col = FirebaseFirestore.instance.collection(
    "communityGroups",
  );

  @override
  Future<CommunityGroup> create(CommunityGroup data) async {
    final docRef = col.doc();
    final dataWithId = data.copyWith(id: docRef.id);
    await docRef.set(dataWithId.toMap());
    return dataWithId;
  }

  @override
  Future<List<CommunityGroup>> createAll(List<CommunityGroup> allData) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final item in allData) {
      final docRef = col.doc();
      final newItem = item.copyWith(id: docRef.id);
      batch.set(docRef, newItem.toMap());
    }

    await batch.commit();
    return allData;
  }

  @override
  Future<List<CommunityGroup>> getAll() async {
    QuerySnapshot snapshot = await col.get();
    List<CommunityGroup> result =
        snapshot.docs
                .map(
                  (doc) => CommunityGroup.fromMap(
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList()
            as List<CommunityGroup>;

    return result;
  }

  @override
  Future<List<CommunityGroup>?> getAllById(String id) async {
    final snapshot = await col.where('id', isEqualTo: id).get();
    if (snapshot.docs.isEmpty) return null;

    return snapshot.docs
            .map(
              (doc) =>
                  CommunityGroup.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList()
        as List<CommunityGroup>;
  }

  @override
  Future<bool> update(CommunityGroup data) async {
    try {
      await col.doc(data.id).update(data.toMap());
      return true;
    } catch (e) {
      print("Firestore update error: $e");
      return false;
    }
  }
}
*/