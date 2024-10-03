import 'package:flutter/material.dart';
import 'package:local_database/data/local/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List to hold all notes fetched from the database
  List<Map<String, dynamic>> allNotes = [];

  // Database reference
  DBHelper? dbRef;

  // Controllers for text input fields
  TextEditingController titleController = TextEditingController();
  TextEditingController desController = TextEditingController();

  // Key for form validation
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Initialize the database reference
    dbRef = DBHelper.getInstance;
    // Fetch notes from the database
    getNotes();
  }

  /// Fetch all notes from the database
  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {}); // Update the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Floating action button to add a new note
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return getBottomSheet(); // Show the bottom sheet for note input
            },
          );
        },
        label: const Icon(Icons.add),
      ),
      // AppBar with title
      appBar: AppBar(
        title: const Text(
          "Notes",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      // Body of the screen
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text('${index + 1}'), // Display the note number
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Edit Button
                        IconButton(
                          color: Colors.green,
                          iconSize: 20,
                          onPressed: () {
                            // Populate text controllers with existing note values
                            titleController.text =
                                allNotes[index][DBHelper.COLUMN_NOTE_TITLE];
                            desController.text = allNotes[index]
                                [DBHelper.COLUMN_NOTE_DESCRIPTION];

                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return getBottomSheet(
                                  isUpdate: true,
                                  id: allNotes[index][DBHelper.COLUMN_NOTE_SNO],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        // Delete Button
                        IconButton(
                          iconSize: 20,
                          color: Colors.red,
                          onPressed: () {
                            // Show confirmation dialog for deletion
                            showDialog(
                                context: context,
                                builder: (contes) {
                                  return SizedBox(
                                    child: AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      content: const Text(
                                        "Confirm to delete?",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            "Cancel",
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await dbRef!.deleteNote(
                                                id: allNotes[index]
                                                    [DBHelper.COLUMN_NOTE_SNO]);
                                            Navigator.pop(context);
                                            getNotes(); // Refresh the notes list
                                          },
                                          child: const Text(
                                            "Yes",
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                  title: Text(allNotes[index][DBHelper.COLUMN_NOTE_TITLE]),
                  subtitle:
                      Text(allNotes[index][DBHelper.COLUMN_NOTE_DESCRIPTION]),
                );
              },
            )
          : const Center(
              child: Text(
                  "No Notes yet"), // Display message when there are no notes
            ),
    );
  }

  /// Builds the bottom sheet for adding or updating notes
  Widget getBottomSheet({bool isUpdate = false, int id = 0}) {
    return Padding(
      padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom), // Adjust for keyboard
      child: Container(
        padding: const EdgeInsets.all(8),
        width: double.infinity,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isUpdate ? "Update Note" : "Add Note",
                style: const TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 21),
              // Title TextField
              TextFormField(
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Title is required"; // Validation for title
                  }
                  return null;
                },
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Enter Title Here",
                  label: const Text("Title*"),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),

              const SizedBox(height: 11),

              // Description TextField
              TextFormField(
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Description is required"; // Validation for description
                  }
                  return null;
                },
                maxLines: 4,
                controller: desController,
                decoration: InputDecoration(
                  label: const Text("Description*"),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),

              const SizedBox(height: 11),

              // Button Row for adding or updating a note
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          String title = titleController.text;
                          String des = desController.text;

                          // Call the appropriate database method based on whether it's an update or add
                          bool check = isUpdate
                              ? await dbRef!.updateNote(
                                  title: title, description: des, id: id)
                              : await dbRef!
                                  .addNote(mTitle: title, mDescription: des);

                          if (check) {
                            getNotes(); // Refresh the notes list after adding/updating
                          }
                          Navigator.pop(context);
                          titleController.clear(); // Clear input fields
                          desController.clear();
                        }
                      },
                      child: Text(isUpdate ? "Update Note" : "Add Note"),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close the bottom sheet
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
