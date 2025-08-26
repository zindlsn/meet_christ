class EventsFilter {
  List<String> categories;
  List<String> locations;
  DateTime? startDate;
  DateTime? endDate;

  EventsFilter({
    this.categories = const [],
    this.locations = const [],
    this.startDate,
    this.endDate,
  });
}