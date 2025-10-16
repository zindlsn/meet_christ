import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meet_christ/main.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/pages/auth/auth.dart';
import 'package:meet_christ/pages/profile/change_mailaddress_page.dart';
import 'package:meet_christ/view_models/profile/bloc/profile_bloc.dart';
import 'package:meet_christ/view_models/profile_view_model.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
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
    context.read<ProfilePageBloc>().add(LoadProfile());
    return BlocConsumer<ProfilePageBloc, ProfileState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Consumer<ProfilePageViewModel>(
          builder: (context, model, child) {
            return state is ProfileLoaded
                ? Scaffold(
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
                              backgroundImage:
                                  widget.user.profilePictureUrl != null
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
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: TextFormField(
                                    controller: emailController,
                                    enabled: false,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.mail_outline),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  setState(() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChangeMailAddressPage(
                                              currentEmail: widget.user.email,
                                            ),
                                      ),
                                    );
                                  });
                                },
                                child: Text('Change'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () async {
                              await model.logout();
                              setState(() {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JesusLoginScreen(),
                                  ),
                                );
                              });
                            },
                            child: Text('Logout'),
                          ),
                        ],
                      ),
                    ),
                  )
                : CircularProgressIndicator();
          },
        );
      },
    );
  }
}
