import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:meet_christ/pages/event_detail_page.dart';
import 'package:meet_christ/pages/new_event_page.dart';
import 'package:meet_christ/view_models/events_view_model.dart';
import 'package:meet_christ/widgets/event_card.dart';
import 'package:provider/provider.dart';

class EventsFeed extends StatefulWidget {
  const EventsFeed({super.key});

  @override
  State<EventsFeed> createState() => _EventsFeedState();
}

class _EventsFeedState extends State<EventsFeed> {
  bool gottesdienstSelected = false;
  int? gottesdienstId;
  final controller = GroupButtonController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Provider.of<EventsViewModel>(context, listen: false).isLoaded) {
        Provider.of<EventsViewModel>(context, listen: false).loadEvents();
      }
      controller.selectIndex(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsViewModel>(
      builder: (context, model, child) {
        return Scaffold(
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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "All Events",
                  style: TextStyle(fontSize: 32, color: Colors.blueAccent),
                ),
              ),
              model.isLoading
                  ? CircularProgressIndicator()
                  : Expanded(
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
                    ),
            ],
          ),
        );
      },
    );
  }
}
