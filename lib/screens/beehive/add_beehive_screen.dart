import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../models/beehive.dart';

class AddBeehiveScreen extends StatefulWidget {
  const AddBeehiveScreen({
    super.key,
  });
  @override
  State<AddBeehiveScreen> createState() => _AddBeehiveScreenState();
}

class _AddBeehiveScreenState extends State<AddBeehiveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _cameraUrlController = TextEditingController();
  bool _isSaving = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "You must be logged in.",
          ),
        ),
      );
      return;
    }

    setState(
          () => _isSaving = true,
    );
    final newBeehiveInfo = Beehive(
      id: _idController.text.trim(),
      name: _nameController.text.trim(),
      userId: currentUser.uid,
      hasCamera: true, // Assuming camera is always present when adding
      doorControlMode: 'manual',
    );
    final dbRef = FirebaseDatabase.instance.ref(
      'beehives/${newBeehiveInfo.id}',
    );

    try {
      await dbRef.child('info').set(
        newBeehiveInfo.toInfoMap(),
      );
      await dbRef.child('data').set(
        {
          'door': 'closed',
          'alert': false,
          'reason': 'Status OK',
          'weight_kg': 0.0,
          'temp': 0.0,
          'hum': 0.0,
          'lat': 0.0,
          'lng': 0.0,
          'cameraUrl': _cameraUrlController.text.trim(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Beehive added successfully!",
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to add beehive: $e",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(
              () => _isSaving = false,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _cameraUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Beehive',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Beehive Unique ID',
                  helperText: 'e.g., beehive_01 (must match hardware)',
                  prefixIcon: Icon(
                    Icons.vpn_key_outlined,
                  ),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Please enter a unique ID' : null,
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Beehive Name',
                  prefixIcon: Icon(
                    Icons.label_outline,
                  ),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _cameraUrlController,
                decoration: const InputDecoration(
                  labelText: 'Camera RTSP Stream URL',
                  prefixIcon: Icon(
                    Icons.link,
                  ),
                  helperText: 'e.g., rtsp://192.168.1.10:8554/mystream',
                ),
                validator: (v) =>
                v == null || !v.startsWith('rtsp://')
                    ? 'Please enter a valid RTSP URL'
                    : null,
              ),
              const SizedBox(
                height: 40,
              ),
              if (_isSaving)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text(
                    'ADD BEEHIVE',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}