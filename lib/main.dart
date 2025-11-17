// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

// App made by <YourName>

class LostItem {
  String id;
  String title;
  String description;
  String location;
  String contact;
  bool resolved;
  LostItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.contact,
    this.resolved = false,
  });
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'location': location,
    'contact': contact,
    'resolved': resolved,
  };
  factory LostItem.fromMap(Map<String, dynamic> m) => LostItem(
    id: m['id'],
    title: m['title'],
    description: m['description'],
    location: m['location'],
    contact: m['contact'],
    resolved: m['resolved'] ?? false,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Lost Things — <YourName>',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LostItem> items = [];
  String query = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() => loading = true);
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList('items') ?? [];
    items = list.map((s) => LostItem.fromMap(jsonDecode(s))).toList().reversed.toList();
    setState(() => loading = false);
  }

  Future<void> saveAll() async {
    final sp = await SharedPreferences.getInstance();
    final list = items.reversed.map((i) => jsonEncode(i.toMap())).toList();
    await sp.setStringList('items', list);
  }

  void addItem(LostItem it) {
    items.insert(0, it);
    saveAll();
    setState(() {});
  }

  void markResolved(String id) {
    final i = items.indexWhere((e) => e.id == id);
    if (i != -1) {
      items[i].resolved = true;
      saveAll();
      setState(() {});
    }
  }

  List<LostItem> filtered() {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((it) =>
    it.title.toLowerCase().contains(q) || it.description.toLowerCase().contains(q) || it.location.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Lost Things'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddItemScreen()));
              if (res is LostItem) addItem(res);
            },
          )
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(hintText: 'Search by title, description, or location'),
            onChanged: (v) => setState(() => query = v.trim()),
          ),
        ),
        Expanded(
          child: loading ? const Center(child: CircularProgressIndicator()) : Builder(builder: (c) {
            final list = filtered();
            if (list.isEmpty) return const Center(child: Text('No items yet'));
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, idx) {
                final it = list[idx];
                return ListTile(
                  title: Text(it.title + (it.resolved ? ' (Resolved)' : '')),
                  subtitle: Text('${it.location} • ${it.contact}'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsScreen(item: it, onResolve: markResolved))),
                );
              },
            );
          }),
        ),
      ]),
    );
  }
}

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _form = GlobalKey<FormState>();
  final tTitle = TextEditingController();
  final tDesc = TextEditingController();
  final tLoc = TextEditingController();
  final tContact = TextEditingController();
  bool saving = false;

  String idGen() => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _form,
          child: Column(children: [
            TextFormField(controller: tTitle, decoration: const InputDecoration(labelText: 'Title'), validator: (v)=> v==null||v.isEmpty?'Enter title':null),
            TextFormField(controller: tDesc, decoration: const InputDecoration(labelText: 'Description')),
            TextFormField(controller: tLoc, decoration: const InputDecoration(labelText: 'Location (text)')),
            TextFormField(controller: tContact, decoration: const InputDecoration(labelText: 'Contact (phone/email)')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: saving ? null : () {
                if (!_form.currentState!.validate()) return;
                setState(() => saving = true);
                final item = LostItem(
                  id: idGen(),
                  title: tTitle.text.trim(),
                  description: tDesc.text.trim(),
                  location: tLoc.text.trim(),
                  contact: tContact.text.trim(),
                );
                Navigator.pop(context, item);
              },
              child: saving ? const CircularProgressIndicator() : const Text('Save'),
            )
          ]),
        ),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  final LostItem item;
  final void Function(String id) onResolve;
  const DetailsScreen({super.key, required this.item, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(item.description.isEmpty ? 'No description' : item.description),
          const SizedBox(height: 8),
          Text('Location: ${item.location.isEmpty ? '-' : item.location}'),
          const SizedBox(height: 8),
          Text('Contact: ${item.contact.isEmpty ? '-' : item.contact}'),
          const SizedBox(height: 16),
          if (!item.resolved)
            ElevatedButton(
              onPressed: () {
                onResolve(item.id);
                Navigator.pop(context);
              },
              child: const Text('Mark as Resolved'),
            )
          else
            const Text('This item is resolved', style: TextStyle(color: Colors.green)),
        ]),
      ),
    );
  }
}
