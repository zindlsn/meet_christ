import 'package:flutter/foundation.dart';
import 'package:meet_christ/models/address.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/services/community_service.dart';
import 'package:uuid/uuid.dart';

class NewCommunityViewModel extends ChangeNotifier {
  CommunityService communitiesRepository;

  NewCommunityViewModel({required this.communitiesRepository});

  List<Community> communities = [];

  void saveCommunity() async{
    final newCommunity = Community(
      id: "",
      name: name,
      description: description,
      address: address,
      profileImage: imageAsBytes,
      events: [],
    );

    await communitiesRepository.createCommunity(community: newCommunity);
    notifyListeners();
  }

  Future<void> loadCommunities() async {
    var saved = await communitiesRepository.getUserCommunities("");
    communities = saved;
    notifyListeners();
  }

  Uint8List? imageAsBytes;

  void setImage(Uint8List? image) {
    imageAsBytes = image;
    notifyListeners();
  }

  String name = "";
  void setTitle({required String name}) {
    this.name = name;
    notifyListeners();
  }

  String description = "";
  void setDescription({required String description}) {
    this.description = description;
    notifyListeners();
  }

  Address? address;

  void setAddress({required Address address}) {
    this.address = address;
    notifyListeners();
  }

  void clear() {
    address = null;
    name = "";
    imageAsBytes = null;
  }
}
