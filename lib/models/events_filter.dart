class EventsFilter {
  List<String> categories;
  String location;
  DateTime? startDate;
  DateTime? endDate;

  EventsFilter({
    this.categories = const [],
    this.location = "",
    this.startDate,
    this.endDate,
  });
}
