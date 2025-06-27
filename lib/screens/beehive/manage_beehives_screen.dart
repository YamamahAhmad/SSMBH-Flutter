import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../models/beehive.dart';

class ManageBeehivesScreen extends StatefulWidget {
  const ManageBeehivesScreen({
    super.key,
  });
  @override
  State<ManageBeehivesScreen> createState() => _ManageBeehivesScreenState();
}

class _ManageBeehivesScreenState extends State<ManageBeehivesScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  void _deleteBeehive(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Confirm Deletion',
        ),
        content: const Text(
          'Are you sure you want to delete this beehive? This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Cancel',
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await FirebaseDatabase.instance.ref('beehives/$id').remove();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Beehive deleted',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to delete: $e',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Beehives',
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref(
          'beehives',
        )
            .orderByChild(
          'info/userId',
        )
            .equalTo(
          currentUser?.uid,
        )
            .onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'No beehives to manage.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            );
          }
          final beehives =
          Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map)
              .entries
              .map(
                (entry) => Beehive.fromRtdb(
              snapshot.data!.snapshot.child(
                entry.key,
              ),
            ),
          )
              .toList();
          return ListView.builder(
            itemCount: beehives.length,
            itemBuilder: (ctx, index) {
              final beehive = beehives[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: ListTile(
                  title: Text(
                    beehive.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'ID: ${beehive.id}',
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.shade200,
                    child: Text(
                      beehive.name.isNotEmpty ? beehive.name[0] : 'B',
                      style: const TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _deleteBeehive(
                      beehive.id,
                    ),
                    tooltip: 'Delete ${beehive.name}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}