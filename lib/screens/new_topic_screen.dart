import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stolarczyk_app/constants.dart';
import 'package:stolarczyk_app/models/appUser.dart';
import 'package:stolarczyk_app/models/topic.dart';

import '../providers/secure_storage.dart';

class NewTopicScreen extends ConsumerStatefulWidget {
  static const routeName = '/new-topic';
  const NewTopicScreen({super.key});

  @override
  ConsumerState<NewTopicScreen> createState() => _NewTopicScreenState();
}

class _NewTopicScreenState extends ConsumerState<NewTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  int _topicPriority = 0;
  DateTime? _deadline;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shortDescriptionController =
      TextEditingController();
  final TextEditingController _longDescriptionController =
      TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  bool _isCreatingNewTopic = false;
  AppUser user = AppUser.init();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _shortDescriptionController.dispose();
    _longDescriptionController.dispose();
    _deadlineController.dispose();
  }

  // On form submit
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (user.username.isEmpty || user.uid!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Nie można pobrać nazwy użytkownika.')));
        return;
      }
      setState(() {
        _isCreatingNewTopic = true;
      });

      _formKey.currentState!.save();

      final Topic newTopic = Topic(
          name: _nameController.text,
          shortDescription: _shortDescriptionController.text,
          longDescription: _longDescriptionController.text,
          status: false,
          createdBy: user,
          dateCreated: DateTime.now(),
          deadline: _deadline!,
          progress: 0,
          priority: _topicPriority);
      final topicDbRef = FirebaseFirestore.instance.collection('topics');
      await topicDbRef.add(newTopic.toMap()).then((value) {
        setState(() {
          _isCreatingNewTopic = false;
          _topicPriority = 0;
        });
        Navigator.pop(context, true);
      }).onError((error, stackTrace) {
        Navigator.pop(context, false);
      });
    }
  }

// TODO: Wyodrebnic widget do innego pliku ???
  @override
  Widget build(BuildContext context) {
    // Get current user from appUserProvider
    user = ref.watch(appUserProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: _isCreatingNewTopic
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nowy temat",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(
                      height: 36,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nazwa'),
                          TextFormField(
                            controller: _nameController,
                            maxLength: 25,
                            decoration: InputDecoration(
                              filled: true,
                              isDense: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none),
                              hintText: 'Wpisz nazwę tematu',
                            ),
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.length < 3) {
                                return 'Wprowadź nazwę tematu';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          const Text('Skrócony opis'),
                          TextFormField(
                            controller: _shortDescriptionController,
                            maxLength: 50,
                            decoration: InputDecoration(
                              filled: true,
                              isDense: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none),
                              hintText: 'Wpisz skrócony opis zadania',
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.length < 3) {
                                return 'Wprowadź opis skrócony';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          const Text('Szczegółowy opis'),
                          TextFormField(
                            controller: _longDescriptionController,
                            maxLength: 250,
                            maxLines: 3,
                            decoration: InputDecoration(
                              filled: true,
                              isDense: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none),
                              hintText: 'Wpisz opis szczegółowy zadania',
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.length < 3) {
                                return 'Wprowadź opis szczegółowy';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Termin'),
                                    TextFormField(
                                      controller: _deadlineController,
                                      decoration: InputDecoration(
                                          filled: true,
                                          isDense: true,
                                          fillColor: Colors.grey[200],
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              borderSide: BorderSide.none),
                                          hintText: 'Wybierz datę'),
                                      readOnly: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Wybierz termin';
                                        }
                                        return null;
                                      },
                                      onTap: () async {
                                        _deadline = await showDatePicker(
                                            locale: const Locale('pl', 'PL'),
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2101));
                                        if (_deadline != null) {
                                          String formattedDate =
                                              DateFormat('dd.MM.yyyy', 'pl_PL')
                                                  .format(_deadline!);
                                          setState(() {
                                            _deadlineController.text =
                                                formattedDate;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 48,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Priorytet'),
                                    DropdownButtonFormField(
                                      value: _topicPriority,
                                      items: topicPriorities
                                          .map((key, value) {
                                            return MapEntry(
                                                key,
                                                DropdownMenuItem<int>(
                                                  value: key,
                                                  child: Text(value),
                                                ));
                                          })
                                          .values
                                          .toList(),
                                      decoration: InputDecoration(
                                        filled: true,
                                        isDense: true,
                                        fillColor: Colors.grey[200],
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: BorderSide.none),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _topicPriority = value!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _submit,
                              style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                              icon: const Icon(Icons.add),
                              label: const Text('Dodaj temat'),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )),
    );
  }
}
