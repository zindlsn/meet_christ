import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meet_christ/pages/event_detail_page.dart';
import 'package:meet_christ/view_models/events_view_model.dart';
import 'package:provider/provider.dart';

class MariaBotschaftData extends ChangeNotifier {
  final String _date;
  final String _fullText;
  final int _maxCollapsedLength;
  bool _isExpanded;
  bool _isVisible;

  MariaBotschaftData({
    required String date,
    required String fullText,
    int maxCollapsedLength = 120,
  }) : _date = date,
       _fullText = fullText,
       _maxCollapsedLength = maxCollapsedLength,
       _isExpanded = false,
       _isVisible = true;

  String get date => _date;
  String get fullText => _fullText;

  /// Returns the text to display, truncated if not expanded and if longer than _maxCollapsedLength.
  String get displayText {
    if (_isExpanded || _fullText.length <= _maxCollapsedLength) {
      return _fullText;
    }
    return '${_fullText.substring(0, _maxCollapsedLength)}...';
  }

  /// True if the full text is longer than the collapsed length, meaning it can be expanded.
  bool get canExpand => _fullText.length > _maxCollapsedLength;

  /// True if the text is currently expanded to show the full message.
  bool get isExpanded => _isExpanded;

  /// True if the entire Maria Botschaft section is visible.
  bool get isVisible => _isVisible;

  /// Toggles the expansion state of the message text.
  void toggleExpanded() {
    if (canExpand) {
      _isExpanded = !_isExpanded;
      notifyListeners();
    }
  }

  /// Hides the entire Maria Botschaft section.
  void hideMessage() {
    _isVisible = false;
    notifyListeners();
  }
}

class MeetChristHomeView extends StatefulWidget {
  const MeetChristHomeView({super.key});

  @override
  State<MeetChristHomeView> createState() => _MeetChristHomeViewState();
}

class _MeetChristHomeViewState extends State<MeetChristHomeView> {
  @override
  void initState() {
    Provider.of<EventsViewModel>(context, listen: false).loadAttendingEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            "Going",
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Consumer<EventsViewModel>(
            builder: (context, model, child) {
              final events = model.attendingEvents;

              if (events.isEmpty) {
                return const Text("Du nimmst an keinen Events teil.");
              }

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];

                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 32,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      // You can format event.date as you wish
                                          "MI, OCT 8 - 18:00",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  event.title ?? "Gebetskreis im Gemeindesaal",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          const Icon(
                                            Icons.check_box,
                                            color: Colors.green,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${event.attendees.length ?? 1} nimmt teil",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EventDetailPage(event: event),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Details",
                                      style: TextStyle(color: Colors.blue),
                                    ),
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
              );
            },
          ),

          const SizedBox(height: 24),

          // Maria Botschaft Section
          ChangeNotifierProvider<MariaBotschaftData>(
            create: (BuildContext context) => MariaBotschaftData(
              date: "28.08.2025",
              fullText:
                  "Liebe Kinder, meine Kinder, meine Geliebten! Ihr seid auserwählt, weil ihr meinen Weisungen gefolgt seid und eure Herzen für die Liebe Gottes geöffnet habt. In diesen schwierigen Zeiten ist es von größter Bedeutung, dass ihr im Glauben standhaft bleibt und euch nicht von den Sorgen der Welt überwältigen lasst. Betet ohne Unterlass für den Frieden und die Einheit aller Menschen. Lasst euch von der göttlichen Gnade leiten und verbreitet die Botschaft der Hoffnung und des Trostes. Ich bin immer bei euch und wache über euch. Amen.",
            ),
            builder: (BuildContext context, Widget? child) {
              final MariaBotschaftData mariaBotschaftData = context
                  .watch<MariaBotschaftData>();

              if (!mariaBotschaftData.isVisible) {
                return const SizedBox.shrink(); // Hide the entire section if not visible
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.favorite_border, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(
                        "Maria Botschaft",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(), // Pushes the close icon to the right
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () {
                          // Hide the entire Maria Botschaft section
                          context.read<MariaBotschaftData>().hideMessage();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const MariaBotschaftMessageCard(), // New widget for the message card
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A custom widget to display the Maria Botschaft message card.
class MariaBotschaftMessageCard extends StatelessWidget {
  const MariaBotschaftMessageCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MariaBotschaftData mariaBotschaftData = context
        .watch<MariaBotschaftData>();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              mariaBotschaftData.date,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mariaBotschaftData.displayText,
              style: const TextStyle(height: 1.4),
            ),
            if (mariaBotschaftData.canExpand) ...<Widget>[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    mariaBotschaftData.toggleExpanded();
                  },
                  child: Text(
                    mariaBotschaftData.isExpanded
                        ? "Weniger anzeigen"
                        : "Mehr anzeigen",
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
