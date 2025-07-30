import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/models/group.dart';
import 'package:meet_christ/view_models/new_event_view_model.dart';
import 'package:provider/provider.dart';

class NewEventPage extends StatefulWidget {
  const NewEventPage({super.key});

  @override
  State<NewEventPage> createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  final ImagePicker picker = ImagePicker();
  String text = "";
  DateTime? _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    Provider.of<NewEventViewModel>(context, listen: false).loadMyCommunities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Provider.of<NewEventViewModel>(
                context,
                listen: false,
              ).saveNewEvent();
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
                          child: IconButton(
                            icon: const Icon(Icons.add_a_photo),
                            onPressed: () async {
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                final bytes = await image.readAsBytes();
                                model.setImage(bytes);
                                text = await getImageToText(image.path);
                              }
                            },
                          ),
                        )
                      : Image.memory(
                          height: 200,
                          fit: BoxFit.cover,
                          model.imageAsBytes!,
                        ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DropdownMenu<Community>(
                      width: double.infinity,
                      label: const Text('Select Community'),
                      dropdownMenuEntries: model.communities
                          .map((commnity) {
                            return DropdownMenuEntry<Community>(
                              value: commnity,
                              label: commnity.name,
                            );
                          })
                          .toList(growable: false),
                      onSelected: (value) {
                        // Handle selection
                      },
                    ),
                  ),
                 model.selectedCommunity != null ? Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DropdownMenu<Group>(
                      width: double.infinity,
                      label: const Text('Select Group'),
                      dropdownMenuEntries: model.selectedCommunity!.groups
                          .map((commnity) {
                            return DropdownMenuEntry<Group>(
                              value: commnity,
                              label: commnity.name,
                            );
                          })
                          .toList(growable: false),
                      onSelected: (value) {
                        // Handle selection
                      },
                    ),
                  ) : Container(),
                  

                  Form(
                    child: Column(
                      children: [
                        CustomTextfield(),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: _selectedDate == null
                                            ? 'Select Date'
                                            : '${_selectedDate!.toLocal().day+1}/${_selectedDate!.toLocal().month}/${_selectedDate!.toLocal().year}',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: GestureDetector(
                                  onTap: () => _selectTime(context),
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: _selectedDate == null
                                            ? 'Select Date'
                                            : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: _selectedDate == null
                                            ? 'Select Date'
                                            : '${_selectedDate!.toLocal().day}/${_selectedDate!.toLocal().month}/${_selectedDate!.toLocal().year}',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: GestureDetector(
                                  onTap: () => _selectTime(context),
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: _selectedDate == null
                                            ? 'Select Date'
                                            : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            minLines: 3,
                            maxLines: 10,
                            decoration: InputDecoration(
                              labelText: 'Beschreibung',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              // Handle location change
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            model.saveEvent();
                            Navigator.pop(context);
                          },
                          child: Text("Create Event"),
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
