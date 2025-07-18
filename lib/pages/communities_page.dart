import 'package:flutter/material.dart';
import 'package:meet_christ/pages/community_page.dart';
import 'package:meet_christ/pages/new_community_page.dart';
import 'package:meet_christ/view_models/community_view_model.dart';
import 'package:meet_christ/widgets/event_card.dart';
import 'package:provider/provider.dart';

class CommunitiesPage extends StatefulWidget {
  const CommunitiesPage({super.key});

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  @override
  initState() {
    super.initState();
    // Initialize the CommunityViewModel to fetch communities
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityViewModel>(
        context,
        listen: false,
      ).loadCommunities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewCommunityPage()),
          );
        },
        child: const Icon(Icons.add_home_rounded),
      ),
      body: Consumer<CommunityViewModel>(
        builder: (context, model, child) {
          return model.isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: model.communities.length,
                  itemBuilder: (context, index) {
                    final event = model.communities[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommunityPage(community: event),
                        ),
                      ),
                      child: CommunityCard(event: event),
                    );
                  },
                );
        },
      ),
    );
  }
}

/*
                    Map<String, List<Community>> communitiesByCity = {};
                    for (var community in model.communities) {
                      String city = community.address.city.toLowerCase();
                      if (!communitiesByCity.containsKey(city)) {
                        communitiesByCity[city] = [];
                      }
                      communitiesByCity[city]!.add(community);
                    }*/
