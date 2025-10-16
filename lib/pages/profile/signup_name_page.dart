import 'package:flutter/material.dart';
import 'package:meet_christ/pages/auth/auth.dart';
import 'package:meet_christ/view_models/signup/bloc/sign_up_bloc.dart';
import 'package:provider/provider.dart';

class SetupProfileBirthdayPage extends StatefulWidget {
  const SetupProfileBirthdayPage({super.key});

  @override
  State<SetupProfileBirthdayPage> createState() =>
      _SetupProfileBirthdayPageState();
}

class _SetupProfileBirthdayPageState extends State<SetupProfileBirthdayPage> {
  var _selecteStartdDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create account")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "What is your Birthday",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 50,
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText:
                          '${_selecteStartdDate.toLocal().day}/${_selecteStartdDate.toLocal().month}/${_selecteStartdDate.toLocal().year}',
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<SignupBloc>().add(
                          SignupBirthdayUpdated(_selecteStartdDate),
                        );
                    context.read<SignupBloc>().add(SignupRequested());
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return JesusLoginScreen();
                        },
                      ),
                    );
                  },
                  child: Text("Create Account"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: "Your Birthday",
      initialDate: DateTime(
        DateTime.now().year - 18,
        DateTime.now().month,
        DateTime.now().day,
      ),
      firstDate: DateTime(
        DateTime.now().year - 100,
        DateTime.now().month,
        DateTime.now().day,
      ),
      lastDate: DateTime(2101, 12, 31),
    );
    _selecteStartdDate = picked ?? _selecteStartdDate;
  }
}
