import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/view_models/new_event_view_model.dart';
import 'package:provider/provider.dart';

class NewEventPage extends StatefulWidget {
  final Community? community;
  const NewEventPage({super.key, this.community});

  @override
  State<NewEventPage> createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  final ImagePicker picker = ImagePicker();
  String text = "";
  DateTime _selecteStartdDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedStartTime = TimeOfDay(hour: 18, minute: 0);
  DateTime _selecteEnddDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedEndTime = TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    Provider.of<NewEventViewModel>(
      context,
      listen: false,
    ).initCommunity(widget.community);

    Provider.of<NewEventViewModel>(
      context,
      listen: false,
    ).setSelectedStartDate(_selecteStartdDate);
    Provider.of<NewEventViewModel>(
      context,
      listen: false,
    ).setSelectedStartTime(_selectedStartTime);
    Provider.of<NewEventViewModel>(
      context,
      listen: false,
    ).setSelectedEndDate(_selecteEnddDate);
    Provider.of<NewEventViewModel>(
      context,
      listen: false,
    ).setSelectedEndTime(_selectedEndTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Event"), actions: [
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                        initialSelection: model.selectedCommunity,
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

                    /*  model.selectedCommunity != null
                        ? Padding(
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
                          )
                        : Container(),*/
                    Form(
                      child: Column(
                        children: [
                          CustomTextfield(),
                          Row(
                            children: [
                              SizedBox(
                                height: 50,
                                width: 25,
                                child: Icon(Icons.location_on),
                              ),
                              SizedBox(
                                height: 50,
                                width: MediaQuery.of(context).size.width - 100,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: TextFormField(
                                    initialValue: text,
                                    decoration: InputDecoration(
                                      labelText: 'Location',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      model.setLocation(location: value);
                                    },
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
                                          labelText:
                                              '${_selecteStartdDate.toLocal().day}/${_selecteStartdDate.toLocal().month}/${_selecteStartdDate.toLocal().year}',
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
                                    onTap: () => _selectStartTime(context),
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          labelText:
                                              '${_selectedStartTime.hour}:${_selectedStartTime.minute.toString().padLeft(2, '0')}',
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
                                    onTap: () => _selectEndDate(context),
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          labelText:
                                              '${_selecteEnddDate.toLocal().day}/${_selecteEnddDate.toLocal().month}/${_selecteEnddDate.toLocal().year}',
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
                                    onTap: () => _selectEndTime(context),
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          labelText:
                                              '${_selectedEndTime.hour}:${_selectedEndTime.minute.toString().padLeft(2, '0')}',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
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
                              model.saveNewEvent();
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
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: "Select Start Date",
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      lastDate: DateTime(2101, 12, 31),
    );
    if (picked != null && picked != _selecteStartdDate) {
      setState(() {
        _selecteStartdDate = picked;
        Provider.of<NewEventViewModel>(
          context,
          listen: false,
        ).setSelectedStartDate(picked);
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      helpText: "Select Start Time",
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() {
        _selectedStartTime = picked;
        Provider.of<NewEventViewModel>(
          context,
          listen: false,
        ).setSelectedStartTime(picked);
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: "Select End Time",
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() {
        _selectedEndTime = picked;
        Provider.of<NewEventViewModel>(
          context,
          listen: false,
        ).setSelectedEndTime(picked);
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

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: "Select End Date",
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      lastDate: DateTime(2101, 12, 31),
    );
    if (picked != null && picked != _selecteEnddDate) {
      setState(() {
        _selecteEnddDate = picked;
        Provider.of<NewEventViewModel>(
          context,
          listen: false,
        ).setSelectedEndDate(picked);
      });
    }
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
        SizedBox(height: 50, width: 25, child: Icon(Icons.topic)),
        SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width - 100,
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
