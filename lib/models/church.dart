import 'package:meet_christ/models/event.dart';

class Church {
  final String id;
  final String name;
  final String description;
  final String address;
  final String contactNumber;
  final String email;
  final String website;

  List<Event> events = [];

  Church({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.contactNumber,
    required this.email,
    required this.website,
  });

  @override
  String toString() {
    return 'Church{id: $id, name: $name, description: $description, address: $address, contactNumber: $contactNumber, email: $email, website: $website}';
  }
}