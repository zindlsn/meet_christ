import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meet_christ/models/address.dart';
import 'package:meet_christ/pages/home.dart';
import 'package:meet_christ/view_models/new_community_view_model.dart';
import 'package:meet_christ/view_models/new_event_view_model.dart';
import 'package:provider/provider.dart';

class NewGroupPage extends StatefulWidget {
  const NewGroupPage({super.key});

  @override
  State<NewGroupPage> createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
  final ImagePicker picker = ImagePicker();
  String text = "";
  DateTime? _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    //Provider.of<NewCommunityViewModel>(context, listen: false).loadMyCommunities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Group"),
        leading: IconButton(
          onPressed: () {
            Provider.of<NewCommunityViewModel>(context, listen: false).clear();
            Navigator.pop(context);
          },
          icon: Icon(Icons.cancel_outlined),
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size(64, 64)), // Square size
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // No rounded corners
                ),
              ),
            ),
            child: Text('Save', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Provider.of<NewCommunityViewModel>(
                context,
                listen: false,
              ).saveCommunity();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage(indexTab: 1)),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer(
          builder: (context, NewEventViewModel model, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  model.imageAsBytes == null
                      ? SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: Center(
                            child: GestureDetector(
                              onTap: () async {
                                final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (image != null) {
                                  final bytes = await image.readAsBytes();
                                  model.setImage(bytes);
                                  text = await getImageToText(image.path);
                                }
                              },
                              child: CircleAvatar(
                                radius: 80, // Adjust the radius as needed
                                backgroundColor: Colors.grey[300],
                                backgroundImage: model.imageAsBytes != null
                                    ? MemoryImage(model.imageAsBytes!)
                                    : null,
                                child: model.imageAsBytes == null
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.add_a_photo,
                                          size: 40,
                                        ),
                                        onPressed: () async {
                                          final XFile? image = await picker
                                              .pickImage(
                                                source: ImageSource.gallery,
                                              );
                                          if (image != null) {
                                            final bytes = await image
                                                .readAsBytes();
                                            model.setImage(bytes);
                                            text = await getImageToText(
                                              image.path,
                                            );
                                          }
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        )
                      : Image.memory(
                          height: 200,
                          fit: BoxFit.cover,
                          model.imageAsBytes!,
                        ),
                  Form(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              Provider.of<NewCommunityViewModel>(
                                context,
                                listen: false,
                              ).setTitle(name: value);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              Provider.of<NewCommunityViewModel>(
                                context,
                                listen: false,
                              ).setAddress(
                                address: Address(title: value, city: ""),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            minLines: 4,
                            maxLines: 10,
                            decoration: InputDecoration(
                              labelText: 'Beschreibung',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              Provider.of<NewCommunityViewModel>(
                                context,
                                listen: false,
                              ).setDescription(description: value);
                            },
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text("Groups"),
                            Spacer(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NewGroupPage(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.add),
                              ),
                            ),
                          ],
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: model.groups.length,
                          itemBuilder: (context, index) {
                            final group = model.groups[index];
                            return ListTile(
                              title: Text(group.name),
                              trailing: Icon(Icons.check),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        Provider.of<NewEventViewModel>(
          context,
          listen: false,
        ).setSelectedStartDate(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        Provider.of<NewEventViewModel>(
          context,
          listen: false,
        ).setSelectedStartTime(picked);
      });
    }
  }

  Future getImageToText(final imagePath) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(
      InputImage.fromFilePath(imagePath),
    );
    String text = recognizedText.text.toString();
    return text;
  }
}

class CustomTextfield extends StatefulWidget {
  const CustomTextfield({super.key});

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(height: 50, width: 25, child: Icon(Icons.title)),
        SizedBox(
          height: 50,
          width: 300,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                Provider.of<NewEventViewModel>(
                  context,
                  listen: false,
                ).setTitle(title: value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
