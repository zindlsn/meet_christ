import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_christ/pages/chat_list_page.dart';
import 'package:meet_christ/pages/communities/communities_page.dart';
import 'package:meet_christ/pages/event_detail_page.dart';
import 'package:meet_christ/pages/events_feed.dart';
import 'package:meet_christ/pages/home/home_page.dart';
import 'package:meet_christ/pages/my_groups_page.dart';
import 'package:meet_christ/pages/profile_page.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:meet_christ/view_models/events_view_model.dart';
import 'package:meet_christ/widgets/event_card.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final int indexTab;
  const HomePage({super.key, this.indexTab = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.indexTab;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    await Provider.of<EventsViewModel>(
      context,
      listen: false,
    ).loadAttendingEvents();
  }

  String title = "Meet Christ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: _selectedIndex == 0 ? Text(title) : null,
              actions: _selectedIndex == 0
                  ? [
                      Text("10"),
                      Icon(Icons.star),
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
                                user: GetIt.I.get<UserService>().user,
                              ),
                            ),
                          );
                        },
                      ),
                    ]
                  : null,
            )
          : null,

      drawer: _selectedIndex == 0
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text('Meet Christ'),
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
            )
          : null,
      body: SafeArea(child: _getBody()),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Prayer'),
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
      return MeetChristHomeView();
    } else if (_selectedIndex == 1) {
      return ChatListPage();
    } else if (_selectedIndex == 2) {
      return Consumer<EventsViewModel>(
        builder: (context, model, child) {
          return model.isLoading
              ? Center(child: CircularProgressIndicator())
              : EventsPage();
        },
      );
    } else if (_selectedIndex == 3) {
      return const CommunitiesPage();
    } else if (_selectedIndex == 4) {
      return PrayerHomePage();
    } else {
      return MyGroupsPage();
    }
  }
}

class PrayerHomePageViewModel extends ChangeNotifier {
  final List<PrayerPack> _prayerPacks = [
    PrayerPack(
      title: "Morgengebet",
      prayers: [
        PrayerX(title: "Vater Unser", text: vaterUnserArray.join("\n")),
        PrayerX(title: "Abendgebet", text: bonhoefferPrayer.join("\n")),
      ],
    ),
    PrayerPack(
      title: "Mittag",
      prayers: [
        PrayerX(title: "Mittagsgebet", text: bonhoefferPrayer.join("\n")),
      ],
    ),
    PrayerPack(
      title: "Abendgebet",
      prayers: [
        PrayerX(title: "Abendgebet", text: bonhoefferPrayer.join("\n")),
      ],
    ),
  ];

  bool _isLoading = false;

  List<PrayerPack> get prayerPacks => _prayerPacks;
  bool get isLoading => _isLoading;

  void loadPrayerPacks() async {
    _isLoading = true;
    notifyListeners();

    _isLoading = false;
    notifyListeners();
  }

  void markPrayerAsDone(PrayerPack pack, PrayerX prayer) {
    pack.prayers.remove(prayer);
    notifyListeners();
  }

  void setCurrentPrayerPack(int index) {
    if (index >= 0 && index < _prayerPacks.length) {
      _currentPrayerPack = index;
      notifyListeners();
    }
  }

  void setNextPrayer() {
    if (_currentPrayerIndex < (currentPack?.prayers.length ?? 0)) {
      _currentPrayerIndex++;
      notifyListeners();
    }
  }

  // current Pack
  PrayerPack? get currentPack =>
      _prayerPacks.isNotEmpty ? _prayerPacks[_currentPrayerPack] : null;

  int get currentPrayerPackIndex => _currentPrayerPack;

  // current Prayer
  PrayerX? get currentPrayer => currentPack?.prayers.isNotEmpty == true
      ? currentPack!.prayers[_currentPrayerIndex]
      : null;

  int _currentPrayerPack = 0;
  int _currentPrayerIndex = 0;

  int get currentPrayerIndex => _currentPrayerIndex;
}

class PrayerHomePage extends StatefulWidget {
  const PrayerHomePage({super.key});

  @override
  State<PrayerHomePage> createState() => _PrayerHomePageState();
}

class _PrayerHomePageState extends State<PrayerHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(
            "Morgenroutine",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          ExpandableCard2(prayerPacks: prayerPacks),
        ],
      ),
    );
  }
}

final prayerPacks = [
  PrayerPack(
    title: "Morgengebet",
    prayers: [
      PrayerX(title: "Vater Unser", text: vaterUnserArray.join("\n")),
      PrayerX(title: "Abendgebet", text: bonhoefferPrayer.join("\n")),
    ],
  ),
  PrayerPack(
    title: "Mittag",
    prayers: [
      PrayerX(title: "Mittagsgebet", text: bonhoefferPrayer.join("\n")),
    ],
  ),
  PrayerPack(
    title: "Abendgebet",
    prayers: [PrayerX(title: "Abendgebet", text: bonhoefferPrayer.join("\n"))],
  ),
];

class PrayerPack {
  String title;
  List<PrayerX> prayers = [];

  PrayerPack({required this.title, required this.prayers});
}

class PrayerX {
  final String title;
  final String text;

  PrayerX({required this.title, required this.text});
}

class ExpandableCard2 extends StatefulWidget {
  final List<PrayerPack> prayerPacks;

  const ExpandableCard2({super.key, required this.prayerPacks});

  @override
  _ExpandableCardState2 createState() => _ExpandableCardState2();
}

class _ExpandableCardState2 extends State<ExpandableCard2> {
  late List<PrayerX> _prayers;
  bool _expanded = false;
  bool _visible = true;
  int _currentIndex = 0;
  final int _currentPrayerPack = 0;

  @override
  void initState() {
    super.initState();
    _prayers = List.from(widget.prayerPacks[_currentPrayerPack].prayers);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    if (_prayers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'All prayers are done!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final currentPrayer = _prayers[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: _prayers.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                          _expanded = false;
                        });
                      },
                      itemBuilder: (context, index) {
                        final prayer = _prayers[index];
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                _expanded
                                    ? prayer.text
                                    : _truncateText(prayer.text),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _expanded = !_expanded;
                                  });
                                },
                                child: Text(
                                  _expanded
                                      ? 'weniger anzeigen'
                                      : 'mehr anzeigen',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _prayers.removeAt(_currentIndex);
                                    if (_prayers.isEmpty) {
                                      _visible =
                                          true; // Card visible but shows done message
                                    } else {
                                      if (_currentIndex >= _prayers.length) {
                                        _currentIndex = _prayers.length - 1;
                                      }
                                      _expanded = false;
                                    }
                                  });
                                },
                                child: const Text('I have read the prayer'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPageIndicator(),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: -12,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              child: Text(
                currentPrayer.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _visible = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_prayers.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 12 : 8,
          height: _currentIndex == index ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == index ? Colors.blue : Colors.grey,
          ),
        );
      }),
    );
  }

  String _truncateText(String text, {int cutoff = 100}) {
    if (text.length <= cutoff) return text;
    return '${text.substring(0, cutoff)}...';
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
    return Scaffold(
      appBar: AppBar(title: Text("Prayer List")),
      body: SafeArea(
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PrayerPage(prayer: Prayer(prayer: vaterUnserArray)),
                      ),
                    );
                    setState(() {});
                  },
                  title: Text("Vater Unser"),
                  trailing: Icon(Icons.arrow_right),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PrayerPage(prayer: Prayer(prayer: [])),
                      ),
                    );
                  },
                  title: Text("Rosenkranz"),
                  trailing: Icon(Icons.arrow_right),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GlaubensbekenntnisVorlesen(),
                      ),
                    );
                  },
                  title: Text("Großes Glaubenbekenntnis"),
                  trailing: Icon(Icons.arrow_right),
                ),
                Divider(),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrayerPage(
                          prayer: Prayer(prayer: bonhoefferPrayer),
                        ),
                      ),
                    );
                  },
                  title: Text("Abendgebete"),
                  trailing: Icon(Icons.arrow_right),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class Prayer {
  String? title = "";
  List<String> prayer = [];
  Prayer({required this.prayer, this.title});
}

class PrayerPage extends StatefulWidget {
  final Prayer prayer;
  const PrayerPage({super.key, required this.prayer});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.prayer.title ?? "Gebet")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: widget.prayer.prayer.length,
                  itemBuilder: (context, index) {
                    final line = widget.prayer.prayer[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 4),
                      child: Text(line, style: TextStyle(fontSize: 14)),
                    );
                  },
                ),
              ),
            ],
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

List<String> grossesGlaubensbekenntnis = [
  "Wir glauben an den einen Gott,",
  "den Vater, den Allmächtigen,",
  "der alles geschaffen hat, Himmel und Erde,",
  "die sichtbare und die unsichtbare Welt.",
  "",
  "Und an den einen Herrn Jesus Christus,",
  "Gottes eingeborenen Sohn,",
  "aus dem Vater geboren vor aller Zeit:",
  "Gott von Gott, Licht vom Licht,",
  "wahrer Gott vom wahren Gott,",
  "gezeugt, nicht geschaffen,",
  "eines Wesens mit dem Vater;",
  "durch ihn ist alles geschaffen.",
  "Für uns Menschen und zu unserem Heil",
  "ist er vom Himmel gekommen,",
  "",
  "hat Fleisch angenommen",
  "durch den Heiligen Geist",
  "von der Jungfrau Maria",
  "und ist Mensch geworden.",
  "",
  "Er wurde für uns gekreuzigt",
  "unter Pontius Pilatus,",
  "hat gelitten und ist begraben worden,",
  "ist am dritten Tage auferstanden nach der Schrift",
  "und aufgefahren in den Himmel.",
  "",
  "Er sitzt zur Rechten des Vaters",
  "und wird wiederkommen in Herrlichkeit,",
  "zu richten die Lebenden und die Toten;",
  "seiner Herrschaft wird kein Ende sein.",
  "",
  "Wir glauben an den Heiligen Geist,",
  "der Herr ist und lebendig macht,",
  "",
  "der aus dem Vater und dem Sohn hervorgeht,",
  "der mit dem Vater und dem Sohn",
  "angebetet und verherrlicht wird,",
  "der gesprochen hat durch die Propheten,",
  "und die eine, heilige, katholische",
  "und apostolische Kirche.",
  "Wir bekennen die eine Taufe",
  "zur Vergebung der Sünden.",
  "Wir erwarten die Auferstehung der Toten",
  "und das Leben der kommenden Welt.",
  "Amen.",
];

List<String> bonhoefferPrayer = [
  'Herr, mein Gott,',
  'ich danke dir, dass du diesen Tag zu Ende gebracht hast.',
  'Ich danke dir, dass du Leib und Seele zur Ruhe kommen lässt.',
  'Deine Hand war über mir und hat mich behütet und bewahrt.',
  'Vergib allen Kleinglauben und alles Unrecht dieses Tages',
  'und hilf, dass ich allen vergebe, die mir Unrecht getan haben.',
  'Lass mich in Frieden unter deinem Schutz schlafen',
  'und bewahre mich vor den Anfechtungen der Finsternis.',
  'Ich befehle dir die Meinen, ich befehle dir dieses Haus,',
  'ich befehle dir meinen Leib und meine Seele.',
  'Gott, dein heiliger Name sei gelobt. Amen.',
  '',
  'Dietrich Bonhoeffer',
];

class GlaubensbekenntnisVorlesen extends StatefulWidget {
  const GlaubensbekenntnisVorlesen({super.key});

  @override
  State<GlaubensbekenntnisVorlesen> createState() =>
      _GlaubensbekenntnisVorlesenState();
}

class _GlaubensbekenntnisVorlesenState
    extends State<GlaubensbekenntnisVorlesen> {
  final FlutterTts flutterTts = FlutterTts();

  bool isSpeaking = false;

  Future<void> _vorlesen() async {
    setState(() {
      isSpeaking = true;
    });
    for (var zeile in grossesGlaubensbekenntnis) {
      if (!isSpeaking) break;
      if (zeile.trim().isNotEmpty) {
        // Überspringe Leerzeilen
        await flutterTts.speak(zeile);
        // Warte bis zu Ende gesprochen.
        await _waitUntilDone();
      }
    }
    setState(() {
      isSpeaking = false;
    });
  }

  Future<void> _waitUntilDone() async {
    bool speaking = true;
    flutterTts.setCompletionHandler(() {
      speaking = false;
    });
    while (speaking) {
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  @override
  void initState() {
    flutterTts.setLanguage('de-DE'); // oder 'en-US'
    flutterTts.setSpeechRate(0.5); // langsam, z.B. 0.5
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    isSpeaking = false;
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Glaubensbekenntnis')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: grossesGlaubensbekenntnis
                      .map(
                        (line) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Text(line, style: TextStyle(fontSize: 14)),
                        ),
                      )
                      .toList(),
                ),
              ),
              ElevatedButton(
                onPressed: isSpeaking ? null : _vorlesen,
                child: Text(isSpeaking ? "Vorlesen läuft…" : "Vorlesen"),
              ),
              if (isSpeaking)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isSpeaking = false;
                    });
                    flutterTts.stop();
                  },
                  child: Text("Stop"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  @override
  void initState() {
    Provider.of<EventsViewModel>(context, listen: false).loadAttendingEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 4),
                child: Text(
                  'Going',
                  style: TextStyle(fontSize: 32, color: Colors.blueAccent),
                ),
              ),
              Consumer<EventsViewModel>(
                builder: (context, model, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      model.attendingEvents.isNotEmpty
                          ? SizedBox(
                              height: 100,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: model.attendingEvents.length,
                                itemBuilder: (context, index) {
                                  var attendees =
                                      model.attendingEvents[index].attendees;
                                  return SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 32,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await Navigator.push<bool>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EventDetailPage(
                                                  event: model
                                                      .attendingEvents[index],
                                                ),
                                          ),
                                        );
                                        // TODO: out of curisity check check
                                        Provider.of<EventsViewModel>(
                                          context,
                                          listen: false,
                                        ).loadAttendingEvents();
                                      },
                                      child: Card(
                                        elevation: 10,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                formatDateTime(
                                                  model
                                                      .attendingEvents[index]
                                                      .startDate,
                                                ),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blueGrey,
                                                ),
                                              ),
                                              Text(
                                                model
                                                    .attendingEvents[index]
                                                    .title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.check_box_rounded,
                                                      color: Colors.green,
                                                    ),
                                                    Text(
                                                      attendees.length
                                                          .toString(),
                                                    ),
                                                    Text(
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                      attendees.length == 1
                                                          ? " nimmt teil"
                                                          : attendees.length > 1
                                                          ? " nehmen teil"
                                                          : " nimmt niemand teil",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : GestureDetector(
                              onTap: () {},
                              child: Center(
                                child: Text(
                                  'Find an event for you click on 🔎 tab',
                                ),
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: MariaMessageSection(),
                      ),
                    ],
                  );
                },
              ),
              /*  Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'My Groups',
                  style: TextStyle(fontSize: 32, color: Colors.blueAccent),
                ),
              ),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: 4,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  primary: false,
                  padding: EdgeInsets.all(0),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: SizedBox(
                        height: 300,
                        width: 150,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(15.0),
                                      ),
                                      child: Image.network(
                                        "https://picsum.photos/800/200?church,pray",
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        color: Colors.black54,
                                        child: Text(
                                          'Gebetskreis',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // Handle tap
                                },
                                child: Container(
                                  height: 40,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(15.0),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Ignite',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ), */
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandableCard extends StatefulWidget {
  final String fullText;
  final String date;
  const ExpandableCard({super.key, required this.fullText, required this.date});

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: RichText(
        text: TextSpan(
          text: !isExpanded
              ? widget.fullText.length > 100
                    ? "${widget.fullText.substring(0, 100)}... "
                    : widget.fullText
              : widget.fullText,
          style: DefaultTextStyle.of(context).style,
          children: [
            if (widget.fullText.length > 100)
              TextSpan(
                text: isExpanded ? "\nWeniger anzeigen" : "Mehr anzeigen",
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
              ),
          ],
        ),
      ),
    );
  }
}

class MariaMessageSection extends StatefulWidget {
  const MariaMessageSection({super.key});

  @override
  State<MariaMessageSection> createState() => _MariaMessageSectionState();
}

class _MariaMessageSectionState extends State<MariaMessageSection> {
  bool isClosed = false;
  @override
  Widget build(BuildContext context) {
    if (!isClosed) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Maria Botschaft',
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Text(
                          "28.08.2025",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        isClosed = true;
                      });
                    },
                  ),
                ],
              ),
              ExpandableCard(
                date: "25.08.2025",
                fullText: """Liebe Kinder, meine Kinder, meine Geliebten!
Ihr seid auserwählt, weil ihr meinen Weisungen gefolgt seid, sie in die Praxis umgesetzt habt und ihr Gott über alles liebt.
Deshalb, meine lieben Kinder, betet von ganzem Herzen, damit meine Worte sich verwirklichen.
Fastet, bringt Opfer, liebt aus Liebe zu Gott, der euch erschaffen hat, und meine lieben Kinder, seid meine ausgestreckten Hände für diese Welt, die den Gott der Liebe noch nicht kennengelernt hat.
Danke, dass ihr meinem Ruf gefolgt seid""",
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
