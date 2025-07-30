import 'package:dotted_border/dotted_border.dart';
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
  Story? selectedStory;
  final controller = GroupButtonController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
   // Provider.of<EventsViewModel>(context, listen: false).setIsLoaded(false);
    var isLoaded = Provider.of<EventsViewModel>(
      context,
      listen: false,
    ).isLoaded;
    if (!isLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<EventsViewModel>(context, listen: false).loadEvents();
        controller.selectIndex(0);
      });
    }
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
              /*Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      // Add padding around the search bar
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      // Use a Material design search bar
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          // Add a clear button to the search bar
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          ),
                          // Add a search icon or button to the search bar
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              // Perform the search here
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: GroupButton(
                      isRadio: true,
                      maxSelected: 1,
                      controller: controller,
                      onSelected: (value, index, isSelected) {
                        print(value);
                      },
                      buttons: ['Kommende', 'Heute', 'Morgen', 'Diese Woche'],
                      options: GroupButtonOptions(
                        direction: Axis.horizontal,
                        groupingType: GroupingType.row,
                        unselectedColor: Colors.grey[200],
                        selectedColor: Colors.blueAccent,
                        spacing: 5,
                        runSpacing: 5,
                      ),
                    ),
                  ),
                  /* ToggleButtons(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    onPressed: (index) => {
                      if (index == 0)
                        {
                          model.filters.clear(),
                          if (model.filters.contains("all"))
                            {model.filters.remove("all")}
                          else
                            {model.filters.add("all")},
                        }
                      else if (index == 1)
                        {
                          if (model.filters.contains(EventTypes.worshipService))
                            {
                              model.filters.remove(EventTypes.worshipService),
                              if (model.filters.isEmpty)
                                {model.filters.add("all")},
                            }
                          else
                            {
                              model.filters.add(EventTypes.worshipService),
                              model.filters.remove("all"),
                            },
                        }
                      else if (index == 2)
                        {
                          if (model.filters.contains("Lobpreis"))
                            {
                              model.filters.remove("Lobpreis"),
                              if (model.filters.isEmpty)
                                {model.filters.add("all")},
                            }
                          else
                            {
                              model.filters.add("Lobpreis"),
                              model.filters.remove("all"),
                            },
                        },
                      model.loadEvents(),
                    },
                    isSelected: [
                      model.filters.contains("all"),
                      model.filters.contains(EventTypes.worshipService),
                      model.filters.contains("Lobpreis"),
                    ],
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("All"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Gottesdienst"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Lobpreis"),
                      ),
                    ],
                  ), */
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          model.timeFilter.clear();
                          model.loadEvents();
                        },
                        icon: Icon(Icons.clear),
                      ),

                      /*ToggleButtons(
                        onPressed: (index) => {
                          if (index == 0)
                            {
                              if (model.timeFilter.contains("today"))
                                {model.timeFilter.remove("today")}
                              else
                                {
                                  model.timeFilter.clear(),

                                  model.timeFilter.add("today"),
                                },
                            }
                          else if (index == 1)
                            {
                              if (model.timeFilter.contains("thisweek"))
                                {model.timeFilter.remove("thisweek")}
                              else
                                {
                                  model.timeFilter.clear(),

                                  model.timeFilter.add("thisweek"),
                                },
                            },
                          model.loadEvents(),
                        },
                        isSelected: [
                          model.timeFilter.contains("today"),
                          model.timeFilter.contains("thisweek"),
                        ],
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Heute"),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Diese Woche"),
                          ),
                        ],
                      ),*/
                    ],
                  ),
                ],
              ),*/
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "All Events",
                  style: TextStyle(fontSize: 32, color: Colors.blueAccent),
                ),
              ),

              /* gottesdienstSelected == false
                  ? Expanded(
                      child: ListView(
                        children: <Widget>[_buildStoryListView()],
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            dashPattern: [10, 5],
                            strokeWidth: 2,
                            radius: Radius.circular(2),
                            color: Colors.indigo,
                            padding: EdgeInsets.all(2),
                          ),
                          child: Container(
                            color: Colors.grey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: CircleAvatar(radius: 14.0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    selectedStory!.name,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "Teilnehmen",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                if (gottesdienstSelected == true) {
                                  gottesdienstSelected = false;
                                  selectedStory = null;
                                } else {
                                  gottesdienstSelected = true;
                                  selectedStory = _stories[0];
                                }
                              });
                            },
                            child: Text("Teilnehmen"),
                          ),
                        ),
                      ],
                    ),*/
              Expanded(
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
                          WidgetsBinding.instance.addPostFrameCallback((_) {
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

  final _stories = <Story>[
    Story(
      name: 'Community',
      storyUrl: 'https://wallpaperaccess.com/full/1079198.jpg',
      email: 'waleedarshad@gmail.com',
    ),
    Story(
      name: 'Google',
      storyUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdx5NkTqe7sjEU1vNXBl-X_v8t5cBM21L-vOs_z6qwVu5JLHjKhw&s',
      email: 'flutter.khi@gmail.com',
    ),
    Story(
      name: 'Dart',
      storyUrl:
          'https://images.unsplash.com/photo-1535370976884-f4376736ab06?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
      email: 'flutterkarachi@gmail.com',
    ),
    Story(
      name: 'Dart',
      storyUrl: 'https://wallpaperplay.com/walls/full/7/c/f/34782.jpg',
      email: 'helloworld@gmail.com',
    ),
    Story(
      name: 'Dart',
      storyUrl:
          'https://pbs.twimg.com/profile_images/779305023507271681/GJJhYpD2_400x400.jpg',
      email: 'google@google.com',
    ),
    Story(
      name: 'Dart',
      storyUrl:
          'https://d33wubrfki0l68.cloudfront.net/495c5afa46922a41983f6442f54491c862bdb275/67c35/static/images/wallpapers/playground-07.png',
      email: 'gmail@google.com',
    ),
  ];

  Widget _buildStoryListView() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _stories.length,
        itemExtent: 150.0,
        primary: false,
        itemBuilder: (context, index) {
          var item = _stories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              children: [
                DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    dashPattern: [10, 5],
                    strokeWidth: 2,
                    radius: Radius.circular(2),
                    color: Colors.indigo,
                    padding: EdgeInsets.all(2),
                  ),
                  child: Container(
                    color: Colors.grey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(radius: 14.0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item.name,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Teilnehmen",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        setState(() {
                          if (gottesdienstSelected == true) {
                            gottesdienstSelected = false;
                            selectedStory = null;
                          } else {
                            gottesdienstSelected = true;
                            selectedStory = _stories[index];
                          }
                        });
                      });
                    },
                    child: Text("Teilnehmen"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Story {
  final String name;
  final String email;
  final String storyUrl;

  Story({required this.name, required this.storyUrl, required this.email});
}
