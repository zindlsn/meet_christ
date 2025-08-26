import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:meet_christ/models/event.dart';
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
        return Scaffold(
          appBar: AppBar(title: Text(widget.event.title)),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                child: Hero(
                  tag: 'dash1001251',
                  child: Image.asset(
                    "assets/images/placeholder_church.png",
                    fit: BoxFit.fill,
                    width: double.infinity,
                  ),
                ),
              ),
              Expanded(
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
                      subTitle:
                          '${model.event.startDate.hour.toString().padLeft(2, '0')}:${model.event.startDate.minute.toString().padLeft(2, '0')}${model.event.endDate.hour.toString().padLeft(2, '0')}:${model.event.endDate.minute.toString().padLeft(2, '0')}',
                      title:
                          "${formatDateTime(model.event.startDate, isLong: true)} - ${formatDateTime(model.event.endDate, isLong: true)}",
                    ),
                    InfoSection(
                      icon: Icon(Icons.location_on),
                      title: "Location",
                      subTitle: model.event.location,
                      onTap: () =>
                          MapsLauncher.launchQuery(model.event.location),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text("Description"),
                    ),
                    Text(
                      "Long description goes here, and so an, all infos about it",
                    ),
                    Container(height: 16, color: Colors.grey[200]),
                    Text("Comments"),
                  ],
                ),
              ),
              Container(
                color: Colors.redAccent,
                height: 100,
                width: double.infinity,
                child: Card(
                  color: Colors.blue,
                  child: !model.isAttending
                      ? InkWell(
                          onTap: () async {
                            model.setIsAttending(true);
                            final success = await model.joinEvent(
                              model.event.id,
                            );
                            if (success) {
                              show(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to join event.'),
                                ),
                              );
                            }
                          },
                          child: SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.zero, // no rounded corners
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                              onPressed: () async {
                                model.setIsAttending(true);
                                final success = await context
                                    .read<EventDetailViewModel>()
                                    .joinEvent(model.event.id);
                              },
                              child: Text('Join'),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            model.setIsAttending(false);
                            final success = await context
                                .read<EventDetailViewModel>()
                                .joinEvent(model.event.id);
                            if (!mounted) return;
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Left event successfully!'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to leave event.'),
                                ),
                              );
                            }
                          },
                          child: Text('Cancle'),
                        ),
                ),
              ),
            ],
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
        Padding(padding: const EdgeInsets.all(8.0), child: Divider()),
      ],
    );
  }
}
