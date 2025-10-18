// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:group_button/group_button.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/events_filter.dart';
import 'package:meet_christ/pages/event_detail_page.dart';
import 'package:meet_christ/pages/new_event_page.dart';
import 'package:meet_christ/services/event_service.dart';
import 'package:meet_christ/view_models/events_view_model.dart';
import 'package:meet_christ/widgets/event_card.dart';
import 'package:provider/provider.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  EventsBloc() : super(EventsLoading()) {
    on<LoadEvents>((event, emit) async {
      emit(EventsLoading());
      final events = await GetIt.I.get<EventService>().getEventsWithoutGroup(
        event.filter,
      );
      emit(EventsLoaded(events));
    });
    on<TabChanged>((event, emit) {
      EventsFilter filter;
      if (event.index == 0) {
        filter = EventsFilter()
          ..startDate = DateTime.now()
          ..endDate = DateTime.now().add(Duration(days: 30));
      } else if (event.index == 1) {
        filter = EventsFilter()..startDate = DateTime.now();
      } else {
        filter = EventsFilter()
          ..startDate = DateTime.now().add(Duration(days: 1));
      }
      add(LoadEvents(filter));
    });
  }
}

class EventsPage extends StatefulWidget {
  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        context.read<EventsBloc>().add(TabChanged(_tabController.index));
      }
    });
    // Initial event load
    context.read<EventsBloc>().add(TabChanged(0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Today"),
            Tab(text: "Tomorrow"),
          ],
        ),
      ),
      body: BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          if (state is EventsLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is EventsLoaded) {
            if (state.events.isEmpty) {
              return Center(child: Text("No upcoming events"));
            }
            return ListView.builder(
              itemCount: state.events.length,
              itemBuilder: (context, index) => GestureDetector(
                child: EventCard(event: state.events[index]),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EventDetailPage(event: state.events[index]),
                    ),
                  );
                },
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

abstract class EventsEvent {}

class LoadEvents extends EventsEvent {
  final EventsFilter filter;

  LoadEvents(this.filter);
}

class TabChanged extends EventsEvent {
  final int index;

  TabChanged(this.index);
}

abstract class EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<Event> events;

  EventsLoaded(this.events);
}

class EventsLoadFailure extends EventsState {
  final String error;

  EventsLoadFailure(this.error);
}

class EventsPage2 extends StatefulWidget {
  const EventsPage2({super.key});

  @override
  State<EventsPage2> createState() => _EventsPage2State();
}

class _EventsPage2State extends State<EventsPage2>
    with SingleTickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  late final TabController _tabController;

  @override
  void initState() {
    if (!mounted) return;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      print("Tab Index: ${_tabController.index}");
    });
    _tabController.animation?.addStatusListener((status) {
      setState(() {
        final value = _tabController.index;
        if (value == 0) {
          Provider.of<EventsViewModel>(context, listen: false).loadEvents(
            EventsFilter()
              ..startDate = DateTime.now()
              ..endDate = DateTime.now().add(Duration(days: 30)),
          );
        } else if (value == 1) {
          Provider.of<EventsViewModel>(
            context,
            listen: false,
          ).loadEvents(EventsFilter()..startDate = DateTime.now());
        } else if (value == 2) {
          Provider.of<EventsViewModel>(context, listen: false).loadEvents(
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
                Provider.of<EventsViewModel>(context, listen: false).loadEvents(
                  EventsFilter()
                    ..startDate = DateTime.now()
                    ..endDate = DateTime.now().add(Duration(days: 30)),
                );
              } else if (value == 1) {
                Provider.of<EventsViewModel>(
                  context,
                  listen: false,
                ).loadEvents(EventsFilter()..startDate = DateTime.now());
              } else if (value == 2) {
                Provider.of<EventsViewModel>(context, listen: false).loadEvents(
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
                      model.loadEvents(
                        EventsFilter()
                          ..startDate = DateTime.now()
                          ..endDate = DateTime.now().add(Duration(days: 30)),
                      );
                    } else if (value == 1) {
                      model.loadEvents(
                        EventsFilter()..startDate = DateTime.now(),
                      );
                    } else if (value == 2) {
                      model.loadEvents(
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
