// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:meet_christ/models/events_filter.dart';
import 'package:meet_christ/pages/event_detail_page.dart';
import 'package:meet_christ/pages/new_event_page.dart';
import 'package:meet_christ/view_models/events_view_model.dart';
import 'package:meet_christ/widgets/event_card.dart';
import 'package:provider/provider.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  late final TabController _tabController;

  @override
  void initState() {
    if (!mounted) return;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener((){
      print("Tab Index: ${_tabController.index}");

    });
    _tabController.animation?.addStatusListener((status) {
      setState(() {
        final value = _tabController.index;
        if (value == 0) {
          Provider.of<EventsViewModel>(context, listen: false).setFilter(
            EventsFilter()
              ..startDate = DateTime.now()
              ..endDate = DateTime.now().add(Duration(days: 30)),
          );
        } else if (value == 1) {
          Provider.of<EventsViewModel>(
            context,
            listen: false,
          ).setFilter(EventsFilter()..startDate = DateTime.now());
        } else if (value == 2) {
          Provider.of<EventsViewModel>(context, listen: false).setFilter(
            EventsFilter()..startDate = DateTime.now().add(Duration(days: 1)),
          );
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            onTap: (value) => setState(() {
              if (value == 0) {
                Provider.of<EventsViewModel>(context, listen: false).setFilter(
                  EventsFilter()
                    ..startDate = DateTime.now()
                    ..endDate = DateTime.now().add(Duration(days: 30)),
                );
              } else if (value == 1) {
                Provider.of<EventsViewModel>(
                  context,
                  listen: false,
                ).setFilter(EventsFilter()..startDate = DateTime.now());
              } else if (value == 2) {
                Provider.of<EventsViewModel>(context, listen: false).setFilter(
                  EventsFilter()
                    ..startDate = DateTime.now().add(Duration(days: 1)),
                );
              }
            }),
            isScrollable: true,
            tabs: [
              Tab(text: "Upcoming"),
              Tab(text: "Today"),
              Tab(text: "Tomorrow"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            EventsList(
              filter: EventsFilter()
                ..startDate = DateTime.now()
                ..endDate = DateTime.now().add(Duration(days: 30)),
            ),
            EventsList(filter: EventsFilter()..startDate = DateTime.now()),
            EventsList(
              filter: EventsFilter()
                ..startDate = DateTime.now().add(Duration(days: 1)),
            ),
          ],
        ),
      ),
    );
  }
}

class EventsList extends StatefulWidget {
  final EventsFilter filter;
  const EventsList({super.key, required this.filter});

  @override
  State<EventsList> createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventsViewModel>(
        context,
        listen: false,
      ).loadEvents(widget.filter);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsViewModel>(
      builder: (context, model, child) {
        if (model.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            if (model.events.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: model.events.length,
                  itemBuilder: (context, index) {
                    final event = model.events[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () async {
                          Provider.of<EventsViewModel>(
                            context,
                            listen: false,
                          ).setFilter(widget.filter);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailPage(event: event),
                            ),
                          );

                          await Provider.of<EventsViewModel>(
                            context,
                            listen: false,
                          ).reload();
                        },
                        child: EventCard(event: event),
                      ),
                    );
                  },
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("No upcoming events"),
                ),
              ),
          ],
        );
      },
    );
  }
}

class EventsFeed extends StatefulWidget {
  const EventsFeed({super.key});

  @override
  State<EventsFeed> createState() => _EventsFeedState();
}

class _EventsFeedState extends State<EventsFeed> {
  bool gottesdienstSelected = false;
  int? gottesdienstId;
  final controller = GroupButtonController();
  final TabController tabController = TabController(
    length: 3,
    vsync: ScrollableState(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Provider.of<EventsViewModel>(context, listen: false).isLoading) {
        Provider.of<EventsViewModel>(
          context,
          listen: false,
        ).loadEvents(EventsFilter());
      }
      controller.selectIndex(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsViewModel>(
      builder: (context, model, child) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewEventPage()),
                    );
                  },
                  child: const Icon(Icons.add_home_rounded),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewEventPage()),
                      );
                    },
                    child: const Icon(Icons.group_add),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DefaultTabController(
                length: 3,
                child: TabBar(
                  isScrollable: true,
                  controller: tabController,
                  onTap: (value) => setState(() {
                    if (value == 0) {
                      model.setFilter(
                        EventsFilter()
                          ..startDate = DateTime.now()
                          ..endDate = DateTime.now().add(Duration(days: 30)),
                      );
                    } else if (value == 1) {
                      model.setFilter(
                        EventsFilter()..startDate = DateTime.now(),
                      );
                    } else if (value == 2) {
                      model.setFilter(
                        EventsFilter()
                          ..startDate = DateTime.now().add(Duration(days: 1)),
                      );
                    }
                  }),
                  tabs: [
                    Tab(text: "Today"),
                    Tab(text: "This Week"),
                    Tab(text: "This Month"),
                  ],
                ),
              ),
            ),
            /*Expanded(
                        child: ListView.builder(
                          itemCount: model.events.length,
                          itemBuilder: (context, index) {
                            final event = model.events[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EventDetailpage(event: event),
                                    ),
                                  );
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    Provider.of<EventsViewModel>(
                                      context,
                                      listen: false,
                                    ).loadEvents();
                                  });
                                },
          
                                child: EventCard(event: event),
                              ),
                            );
                          },
                        ),
                      ), */
          ),
        );
      },
    );
  }
}
