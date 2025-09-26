import 'package:flutter/material.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/pages/auth_page.dart';
import 'package:meet_christ/view_models/profile_view_model.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final emailController = TextEditingController();

  bool? isEditing;

  @override
  void initState() {
    emailController.text = widget.user.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfilePageViewModel>(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
            actions: [
              isEditing == null
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          isEditing ??= true;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.edit),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isEditing == true) {
                            isEditing = null;
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.save),
                      ),
                    ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.user.profilePictureUrl != null
                        ? NetworkImage(widget.user.profilePictureUrl!)
                        : null,
                    child: widget.user.profilePictureUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "${widget.user.firstname} ${widget.user.lastname}",
                  style: const TextStyle(fontSize: 32, color: Colors.grey),
                ),
                TextFormField(
                  controller: emailController,
                  enabled: isEditing == true,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    await model.logout();
                    setState(() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AuthGate()),
                      );
                    });
                  },
                  child: Text('Logout'),
                ),
                // Email
              ],
            ),
          ),
        );
      },
    );
  }
}
