import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/view_models/event_detail_view_model.dart';
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
              Column(
                children: [
                  Text(model.event.description),
                  Text('Date: ${model.event.startDate}'),
                  Text('Location: ${model.event.location}'),
                  !model.isAttending
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
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              color: Colors.greenAccent,
                              child: Text('Join Event'),
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
                          child: Text('Leave Event'),
                        ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
