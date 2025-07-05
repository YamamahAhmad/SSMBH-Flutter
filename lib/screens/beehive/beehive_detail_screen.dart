import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../models/beehive.dart';
import '../../utils/app_constants.dart';
import 'camera_view_screen.dart';

class BeehiveDetailScreen extends StatelessWidget {
  final Beehive beehive;
  const BeehiveDetailScreen({
    super.key,
    required this.beehive,
  });

  Future<void> _toggleDoor(String hiveId, bool currentIsDoorOpen) async {
    final dbRef = FirebaseDatabase.instance.ref(
      'beehives/$hiveId/info/doorRequested',
    );
    await dbRef.set(currentIsDoorOpen ? 'closed' : 'open');
  }

  Future<void> _setDoorControlMode(String hiveId, String mode) async {
    final dbRef = FirebaseDatabase.instance.ref(
      'beehives/$hiveId/info',
    );
    await dbRef.update(
      {
        'doorControlMode': mode,
      },
    );
  }

  // NEW: Function to update the camera URL in Firebase
  Future<void> _updateCameraUrl(String hiveId, String newUrl) async {
    final dbRef = FirebaseDatabase.instance.ref('beehives/$hiveId/info');
    try {
      await dbRef.update({'cameraUrl': newUrl});
    } catch (e) {
      // Handle potential errors, e.g., permission denied
      print('Error updating camera URL: $e');
    }
  }

  // NEW: Function to show a dialog for editing the camera URL
  Future<void> _showEditCameraUrlDialog(
      BuildContext context, String hiveId, String currentUrl) async {
    final urlController = TextEditingController(text: currentUrl);
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Camera Stream URL'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'New URL',
                hintText: 'http://your-stream-url',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'URL cannot be empty';
                }
                if (!Uri.parse(value.trim()).isAbsolute) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newUrl = urlController.text.trim();
                  await _updateCameraUrl(hiveId, newUrl);

                  // Close the dialog
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();

                  // Show a confirmation message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Camera URL updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }


  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.8) ??
                buttonOrange,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor ??
                    Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
      FirebaseDatabase.instance.ref('beehives/${beehive.id}').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(beehive.name),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final updatedBeehive = Beehive.fromRtdb(
          snapshot.data!.snapshot,
        );
        double percentage =
        (updatedBeehive.currentWeight / updatedBeehive.maxWeightCapacity)
            .clamp(0.0, 1.0);
        final alertColor =
        updatedBeehive.alert ? Colors.red.shade400 : Colors.orange;

        final bool isManualControl =
            updatedBeehive.doorControlMode == 'manual';

        return Scaffold(
          appBar: AppBar(
            title: Text(
              updatedBeehive.name,
            ),
            actions: [
              // NEW: Edit Camera URL Button
              if (updatedBeehive.hasCamera)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Camera URL',
                  onPressed: () {
                    _showEditCameraUrlDialog(
                      context,
                      updatedBeehive.id,
                      updatedBeehive.cameraUrl,
                    );
                  },
                ),
              // Existing Open Camera Button
              if (updatedBeehive.hasCamera)
                IconButton(
                  icon: const Icon(
                    Icons.videocam_outlined,
                  ),
                  tooltip: 'Open Camera',
                  onPressed: () {
                    if (updatedBeehive.cameraUrl.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Camera URL is not set for this beehive.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraViewScreen(
                          cameraUrl: updatedBeehive.cameraUrl,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(
              16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: CircularPercentIndicator(
                    radius: 85.0,
                    lineWidth: 13.0,
                    animation: true,
                    percent: percentage,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          updatedBeehive.currentWeight.toStringAsFixed(
                            1,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 34.0,
                          ),
                        ),
                        Text(
                          "Kilograms",
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[600],
                          ),
                        )
                      ],
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: alertColor,
                    backgroundColor: Colors.grey[300]!,
                    footer: Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                      ),
                      child: Text(
                        'Capacity: ${updatedBeehive.maxWeightCapacity.toStringAsFixed(1)} Kg',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Door Controls',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ToggleButtons(
                            isSelected: [
                              isManualControl, // Manual
                              !isManualControl, // Auto
                            ],
                            onPressed: (index) {
                              final newMode = index == 0 ? 'manual' : 'auto';
                              _setDoorControlMode(
                                updatedBeehive.id,
                                newMode,
                              );
                            },
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ),
                            selectedBorderColor: buttonOrange,
                            selectedColor: Colors.white,
                            fillColor: buttonOrange,
                            color: buttonOrange,
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Text(
                                  'MANUAL',
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Text(
                                  'AUTO',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        SwitchListTile(
                          title: const Text(
                            'Door',
                          ),
                          subtitle: Text(
                            isManualControl
                                ? 'Tap to open/close'
                                : 'Auto mode is active',
                          ),
                          value: updatedBeehive.isDoorOpen,
                          onChanged: isManualControl
                              ? (value) => _toggleDoor(
                            updatedBeehive.id,
                            updatedBeehive.isDoorOpen,
                          )
                              : null,
                          secondary: Icon(
                            updatedBeehive.isDoorOpen
                                ? Icons.meeting_room
                                : Icons.door_front_door,
                          ),
                          activeColor:
                          Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      16.0,
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          Icons.thermostat_outlined,
                          'Temperature',
                          '${updatedBeehive.temperature.toStringAsFixed(1)}°C',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          context,
                          Icons.opacity_outlined,
                          'Humidity',
                          '${updatedBeehive.humidity.toStringAsFixed(1)} %',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          context,
                          Icons.location_on_outlined,
                          'Location',
                          '${updatedBeehive.latitude.toStringAsFixed(4)}, ${updatedBeehive.longitude.toStringAsFixed(4)}',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          context,
                          updatedBeehive.isDoorOpen
                              ? Icons.meeting_room_outlined
                              : Icons.door_front_door_outlined,
                          'Door Status',
                          updatedBeehive.isDoorOpen ? 'Open' : 'Closed',
                          valueColor: updatedBeehive.isDoorOpen
                              ? Colors.green[700]
                              : Colors.red[700],
                        ),
                        const Divider(),
                        _buildInfoRow(
                          context,
                          Icons.warning_amber_rounded,
                          'Alert Reason',
                          updatedBeehive.reason,
                          valueColor: updatedBeehive.alert
                              ? Colors.red[700]
                              : Colors.green[700],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}