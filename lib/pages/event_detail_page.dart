// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/view_models/event_comments_view_model.dart';
import 'package:meet_christ/view_models/event_detail_view_model.dart';
import 'package:meet_christ/widgets/event_card.dart';
import 'package:provider/provider.dart';

class EventDetailpage extends StatefulWidget {
  final Event event;
  const EventDetailpage({super.key, required this.event});

  @override
  State<EventDetailpage> createState() => _EventDetailpageState();
}

class _EventDetailpageState extends State<EventDetailpage> {
  @override
  void initState() {
    super.initState();
    Provider.of<EventDetailViewModel>(
      context,
      listen: false,
    ).setEvent(widget.event);
    Provider.of<EventCommentsViewModel>(context, listen: false).event =
        widget.event;

    Provider.of<EventCommentsViewModel>(context, listen: false).loadComments();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void show(BuildContext context) {
    // Open the BottomSheet
    final bottomSheetController = showModalBottomSheet(
      context: context,
      isDismissible: true, // Allows user to tap away to close
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.redAccent,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Schön dass du dabei bist! \n'
                      'Gott segne dich – er ist mit dir, wohin du auch gehst (Josua 1,9).',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    var timer = Timer(Duration(seconds: 3), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
    bottomSheetController.then((value) {
      timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventDetailViewModel>(
      builder: (context, model, child) {
        var eventTitle = formatDateTime(model.event.startDate, isLong: true);
        if (model.event.endDate.day != model.event.startDate.day) {
          eventTitle +=
              " - ${formatDateTime(model.event.endDate, isLong: false)}";
        }
        return Scaffold(
          appBar: AppBar(title: Text(widget.event.title)),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 200,
                        child: HeroMode(
                          enabled: false,
                          child: Image.asset(
                            "assets/images/placeholder_church.png",
                            fit: BoxFit.fill,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.event.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                            Text(model.event.description),
                            InfoSection(
                              icon: Icon(Icons.calendar_view_day_rounded),
                              title: eventTitle,
                              subTitle:
                                  '${model.event.startDate.hour.toString().padLeft(2, '0')}:${model.event.startDate.minute.toString().padLeft(2, '0')} - ${model.event.endDate.hour.toString().padLeft(2, '0')}:${model.event.endDate.minute.toString().padLeft(2, '0')}',
                            ),
                            InfoSection(
                              icon: Icon(Icons.location_on),
                              title: "LOCATION",
                              subTitle: model.event.location,
                              onTap: () => MapsLauncher.launchQuery(
                                model.event.location,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text("DESCRIPTION"),
                            ),
                            Text(
                              "Long description goes here, and so an, all infos about it",
                            ),
                            Text('People'),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Organizers'),
                                      Column(
                                        children: model.event.organizers.map((
                                          e,
                                        ) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                CircleAvatar(
                                                  radius: 24,
                                                  backgroundImage: NetworkImage(
                                                    e.photoUrl ??
                                                        'https://www.gravatar.com/avatar/placeholder',
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(e.name),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Attendees'),
                                    Column(
                                      children: model.event.attendees.map((e) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              CircleAvatar(
                                                radius: 24,
                                                backgroundImage: NetworkImage(
                                                  e.photoUrl ??
                                                      'https://www.gravatar.com/avatar/placeholder',
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(e.name),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 500, child: EventCommentSection()),
                            /*  Container(height: 16, color: Colors.grey[200]),
                            Text("Comments"),
                            TextFormField(
                              decoration: InputDecoration(
                                suffixIcon: Icon(Icons.send),
                                hintText: "Add a comment...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            Container(height: 500, color: Colors.red), */
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(80),
                          offset: Offset(
                            0,
                            -4,
                          ), // Negative Y-value for top shadow
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    width: double.infinity,
                    child: !model.isAttending
                        ? Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(child: SizedBox()),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: () async {
                                    model.setIsAttending(true);
                                    await context
                                        .read<EventDetailViewModel>()
                                        .joinEvent(model.event.id);
                                  },
                                  child: Text('Join'),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(child: SizedBox()),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  onPressed: () async {
                                    model.setIsAttending(false);
                                    final success = await context
                                        .read<EventDetailViewModel>()
                                        .joinEvent(model.event.id);
                                    if (!mounted) return;
                                    if (success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Left event successfully!',
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to leave event.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text('Cancle'),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class InfoSection extends StatelessWidget {
  final Icon icon;
  final String title;
  final String subTitle;
  final bool withArrow;
  final VoidCallback? onTap;
  const InfoSection({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.withArrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: icon,
          title: Text(title),
          subtitle: Text(subTitle),
          onTap: onTap,
          trailing: onTap != null ? Icon(Icons.arrow_forward) : null,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Divider(),
        ),
      ],
    );
  }
}

class EventCommentSection extends StatefulWidget {
  const EventCommentSection({super.key});

  @override
  State<EventCommentSection> createState() => _EventCommentSectionState();
}

class _EventCommentSectionState extends State<EventCommentSection> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    Provider.of<EventCommentsViewModel>(context, listen: false).loadComments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventCommentsViewModel>(
      builder: (context, model, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comments'),
            Expanded(
              child: Column(
                children: [
                  ...model.comments.map((comment) {
                    return ListTile(title: Text(comment.content));
                  }),
                  TextFormField(
                    controller: _textController,
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            model.setComment(_textController.text);
                            model.saveComment();
                            Provider.of<EventCommentsViewModel>(
                              context,
                              listen: false,
                            ).loadComments();
                          });
                        },
                        child: Icon(Icons.send),
                      ),
                      hintText: "Add a comment...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
/*
Usecases:
1. Event users with privilege to write comments can write a comment, so that
everyone who can read the comments will be shown in the Event Detail Page the new comment.

2. In Homescreen, users can see a summary of the event comments?

3. in Homescreen, users can see if there is a new comment, which are not read yet

*/