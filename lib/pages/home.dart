import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_christ/pages/communities_page.dart';
import 'package:meet_christ/pages/events_feed.dart';
import 'package:meet_christ/pages/my_groups_page.dart';
import 'package:meet_christ/pages/profile_page.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:meet_christ/view_models/events_view_model.dart';
import 'package:meet_christ/widgets/church_card.dart';
import 'package:meet_christ/widgets/event_card.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final int indexTab;
  const HomePage({super.key, required this.indexTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.indexTab;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    await Provider.of<EventsViewModel>(context, listen: false).loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meet Christ'),
        actions: [
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.account_circle_sharp),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    user: GetIt.I.get<UserService2>().loggedInUser!,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Meet Christ'),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                // Navigate to settings page
              },
            ),
            ListTile(title: Text('About'), onTap: () {}),
          ],
        ),
      ),
      body: SafeArea(child: _getBody()),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Prayers'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _getBody() {
    if (_selectedIndex == 0) {
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: const TabBar(
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Attending'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Consumer<EventsViewModel>(
                    builder: (context, model, child) {
                      return model.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : EventsFeed();
                    },
                  ),
                  Consumer<EventsViewModel>(
                    builder: (context, model, child) {
                      return model.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : model.getEventsAttending().isNotEmpty
                          ? ListView.builder(
                              itemCount: model.getEventsAttending().length,
                              itemBuilder: (context, index) {
                                final event = model.getEventsAttending()[index];
                                return EventCard(event: event);
                              },
                            )
                          : Center(child: Text("No events you are attending"));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (_selectedIndex == 1) {
      return const CommunitiesPage();
    } else if (_selectedIndex == 2) {
      return PrayerListPage();
    } else {
      return MyGroupsPage();
    }
  }
}

class PrayerListPage extends StatefulWidget {
  const PrayerListPage({super.key});

  @override
  State<PrayerListPage> createState() => _PrayerListPageState();
}

class _PrayerListPageState extends State<PrayerListPage> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrayerPage()),
            );
          },
          title: Text("Vater Unser"),
          trailing: Icon(Icons.arrow_right),
        );
      },
    );
  }
}

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment: CrossAxisAlignment.start, // Left align text
            mainAxisSize: MainAxisSize.min, // Only use necessary height
            children: vaterUnserArray.map((line) => Text(line)).toList(),
          ),
        ),
      ),
    );
  }
}

List<String> vaterUnserArray = [
  "Vater unser im Himmel,",
  "geheiligt werde dein Name.",
  "Dein Reich komme.",
  "Dein Wille geschehe,",
  "wie im Himmel, so auf Erden",
  "Unser tägliches Brot gib uns heute",
  "Und vergib uns unsere Schuld,",
  "wie auch wir vergeben unseren Schuldigern",
  "Und führe uns nicht in Versuchung",
  "sondern erlöse uns von dem Bösen. Amen.",
];
