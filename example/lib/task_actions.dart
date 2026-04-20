// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:device_admin_manager/device_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

DeviceAdminManager get dam => DeviceAdminManager.instance;

class TaskAction {
  final String label;
  final FutureOr<dynamic> Function(BuildContext context) task;
  void Function()? didPressed;

  TaskAction({
    required this.label,
    required this.task,
    this.didPressed,
  });

  ElevatedButton button(BuildContext context) => ElevatedButton(
        onPressed: () async {
          await task(context);
          didPressed?.call();
        },
        child: Text(label),
      );
}

void _showSuccessDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Success"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

void _showErrorDialog(BuildContext context, dynamic error) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Error"),
      content: Text(
          error is PlatformException ? error.message ?? error.toString() : error.toString()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

const toggleScreenAwakeLabel = "Toggle Screen Awake ⚡";
final taskActions = <TaskAction>[
  TaskAction(
    label: "Requests admin privileges if needed.",
    task: (context) {
      dam.requestAdminPrivilegesIfNeeded().then(
        (isGranted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Requests admin privileges"),
                content: isGranted
                    ? const Text("Admin privileges is granted.")
                    : const Text("Admin privileges have not been granted.\n"
                        "Either the user has declined the request or This app is not a Device Policy Controller (dam)."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  ),
  TaskAction(
    label: "Checks if admin privileges are active",
    task: (context) {
      dam.isAdminActive().then((isAdmin) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Admin Privileges"),
              content: isAdmin
                  ? const Text("The app has admin privileges.")
                  : const Text("The app does not have admin privileges."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      });
    },
  ),
  TaskAction(
    label: "Locks the app in kiosk mode",
    task: (_) {
      dam.lockApp();
    },
  ),
  TaskAction(
    label: "Unlocks the app",
    task: (_) {
      dam.unlockApp();
    },
  ),
  TaskAction(
    label: toggleScreenAwakeLabel,
    task: (_) async {
      await dam.setKeepScreenAwake(!(await dam.isScreenAwake()));
    },
  ),
  TaskAction(
    label: "Gets device information",
    task: (context) {
      dam.getDeviceInfo().then((Map<String, dynamic>? info) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Device Information"),
              content: info != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: info.entries.map((i) => Text("${i.key}: ${i.value}")).toList(),
                    )
                  : const Text("Unable to retrieve device information."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      });
    },
  ),
  TaskAction(
    label: "Set As Launcher",
    task: (context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Set As Launcher'),
          content: const Text("Do you want to set the current app as the device's launcher."),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Disable'),
              onPressed: () {
                dam.setAsLauncher(enable: false);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () {
                dam.setAsLauncher(enable: true);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  ),
  TaskAction(
    label: "Clear Device Owner App",
    task: (context) async {
      try {
        await dam.clearDeviceOwnerApp();
        _showSuccessDialog(context, "Device Owner cleared.");
      } catch (e) {
        _showErrorDialog(context, e);
      }
    },
  ),
  TaskAction(
    label: "Set Camera",
    task: (context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Set Camera'),
          content: const Text('Do you want to disable the camera?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Disable'),
              onPressed: () async {
                try {
                  await dam.setCameraDisabled(disabled: true);
                  Navigator.pop(context);
                  _showSuccessDialog(context, "Camera disabled.");
                } catch (e) {
                  Navigator.pop(context);
                  _showErrorDialog(context, e);
                }
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () async {
                try {
                  await dam.setCameraDisabled(disabled: false);
                  Navigator.pop(context);
                  _showSuccessDialog(context, "Camera enabled.");
                } catch (e) {
                  Navigator.pop(context);
                  _showErrorDialog(context, e);
                }
              },
            ),
          ],
        ),
      );
    },
  ),
  TaskAction(
    label: "Set screen capture",
    task: (context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Set Screen Capture'),
          content: const Text('Do you want to disable the Screen Capture?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Disable'),
              onPressed: () async {
                try {
                  await dam.setScreenCaptureDisabled(disabled: true);
                  Navigator.pop(context);
                  _showSuccessDialog(context, "Screen capture disabled.");
                } catch (e) {
                  Navigator.pop(context);
                  _showErrorDialog(context, e);
                }
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () async {
                try {
                  await dam.setScreenCaptureDisabled(disabled: false);
                  Navigator.pop(context);
                  _showSuccessDialog(context, "Screen capture enabled.");
                } catch (e) {
                  Navigator.pop(context);
                  _showErrorDialog(context, e);
                }
              },
            ),
          ],
        ),
      );
    },
  ),
  TaskAction(
    label: "Set Keyguard",
    task: (context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Set Keyguard'),
          content: const Text('Do you want to disable the keyguard?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Disable'),
              onPressed: () async {
                try {
                  await dam.setKeyguardDisabled(disabled: true);
                  Navigator.pop(context);
                  _showSuccessDialog(context, "Keyguard disabled.");
                } catch (e) {
                  Navigator.pop(context);
                  _showErrorDialog(context, e);
                }
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () async {
                try {
                  await dam.setKeyguardDisabled(disabled: false);
                  Navigator.pop(context);
                  _showSuccessDialog(context, "Keyguard enabled.");
                } catch (e) {
                  Navigator.pop(context);
                  _showErrorDialog(context, e);
                }
              },
            ),
          ],
        ),
      );
    },
  ),
  TaskAction(
    label: "Wipe Data",
    task: (context) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm Wipe Data'),
            content: const Text(
              'Are you sure you want to wipe all device data?\n'
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await dam.wipeData();
                    Navigator.pop(context);
                    _showSuccessDialog(context, "Wipe data initiated.");
                  } catch (e) {
                    Navigator.pop(context);
                    _showErrorDialog(context, e);
                  }
                },
                child: const Text(
                  'Wipe',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  ),
];
