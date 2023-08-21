import 'package:flutter/material.dart';
import 'package:stolarczyk_app/providers/db.dart';

import '../models/task.dart';

class NewTask extends StatefulWidget {
  const NewTask({super.key, required this.topicUid});
  final String? topicUid;

  @override
  State<NewTask> createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _isCreatingNewTask = false;

  // On submit validate data and try to add new task to topic
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCreatingNewTask = true;
      });
      Task task = Task(
        name: _nameController.text,
        description: '',
        status: false,
      );
      DbProvider.addNewTask(widget.topicUid, task).then((task) {
        _isCreatingNewTask = false;
        Navigator.pop(context, task);
      });
      DbProvider.incrementTotalTasksCount(widget.topicUid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Text(
          "Nowe zadanie",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(
          height: 24,
        ),
        Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                hintText: 'Wpisz nazwę zadania',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 3) {
                  return 'Wprowadź nazwę zadania';
                }
                return null;
              },
            ),
            _isCreatingNewTask
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      icon: const Icon(Icons.add),
                      label: const Text('Dodaj zadanie'),
                    ),
                  ),
          ]),
        ),
      ]),
    );
  }
}
