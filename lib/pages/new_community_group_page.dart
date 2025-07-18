import 'package:flutter/material.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/view_models/new_community_group_view_model.dart';
import 'package:provider/provider.dart';

class NewCommunityGroupPage extends StatefulWidget {
  final Community community;
  const NewCommunityGroupPage({super.key, required this.community});

  @override
  State<NewCommunityGroupPage> createState() => _NewCommunityGroupPageState();
}

class _NewCommunityGroupPageState extends State<NewCommunityGroupPage> {
  @override
  void initState() {
    Provider.of<NewCommunityGroupPageViewModel>(
      context,
      listen: false,
    ).setCommunity(widget.community);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.community.name),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () async {
                Provider.of<NewCommunityGroupPageViewModel>(
                  context,
                  listen: false,
                ).saveConnumityGroup();
                Navigator.pop(context);
              },
              child: Icon(Icons.save),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              CircleAvatar(child: Icon(Icons.add_a_photo)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Consumer<NewCommunityGroupPageViewModel>(
                    builder: (context, model, child) {
                      return TextFormField(
                        onChanged: (text) {
                          model.setName(text);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
