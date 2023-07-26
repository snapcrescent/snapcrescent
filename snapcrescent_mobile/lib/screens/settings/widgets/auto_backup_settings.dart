import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapcrescent_mobile/screens/settings/folder_selection/folder_selection.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';
import 'package:snapcrescent_mobile/services/settings_service.dart';
import 'package:snapcrescent_mobile/style.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class AutoBackupSettingsView extends StatefulWidget {
  @override
  createState() => _AutoBackupSettingsViewState();
}

class _AutoBackupSettingsViewState extends State<AutoBackupSettingsView> {
  bool _autoBackup = false;
  String _autoBackupFolders = "None";
  String? _autoBackupFrequency = "";
  String _autoBackupFrequencyString = "";
  
  AutoBackupFrequencyType _autoBackupFrequencyType = AutoBackupFrequencyType.HOURS;
  
  final _formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.onUserInteraction;

  TextEditingController autoBackUpFrequencyController = TextEditingController();

  FutureOr onBackFromChild(dynamic value) {
    _getSettingsData();
    setState(() {});
  }

  Future<bool> _getSettingsData() async {
    await _getAutoBackupFrequency();
    
    _autoBackup = await AppConfigService()
        .getFlag(Constants.appConfigAutoBackupFlag);
    _autoBackupFolders = await SettingsService().getFolderInfo(Constants.appConfigAutoBackupFolders);
    
    return Future.value(true);
  }

  Future<void> _getAutoBackupFrequency() async {
    _autoBackupFrequency = await AppConfigService().getConfig(Constants.appConfigAutoBackupFrequency);
    

    if(_autoBackupFrequency != null) {

      _autoBackupFrequencyType = SettingsService().getReadableOfAutoBackupFrequency(_autoBackupFrequency!);

      double autoBackupFrequencyNumber = double.parse(_autoBackupFrequency!);

    switch (_autoBackupFrequencyType) {
      case AutoBackupFrequencyType.HOURS:
        autoBackupFrequencyNumber = (autoBackupFrequencyNumber / 60);
        _autoBackupFrequencyString =
            "${autoBackupFrequencyNumber.toStringAsFixed(0)} Hour${autoBackupFrequencyNumber > 1 ? "s" : ""}";
        break;
      case AutoBackupFrequencyType.DAYS:
        autoBackupFrequencyNumber = ((autoBackupFrequencyNumber / 60) / 24);
        _autoBackupFrequencyString =
            "${autoBackupFrequencyNumber.toStringAsFixed(0)} Day${autoBackupFrequencyNumber > 1 ? "s" : ""}";
        break;
      default:
    }

      autoBackUpFrequencyController.text =
          autoBackupFrequencyNumber.toStringAsFixed(0);

    }
    
  }

  _showAutoBackupFrequencyInfoDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Auto Backup Frequency'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                  height: 280,
                  child: Form(
                      key: _formKey,
                      child: Column(children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                              autovalidateMode: _autovalidateMode,
                              controller: autoBackUpFrequencyController,
                              validator: (v) {
                                if (v!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'Please enter a valid value';
                                }
                              },
                              decoration: InputDecoration(labelText: ''),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ]),
                        ),
                        Column(
                          children: <Widget>[
                            ListTile(
                              title: const Text('Hours'),
                              leading: Radio<AutoBackupFrequencyType>(
                                value: AutoBackupFrequencyType.HOURS,
                                groupValue: _autoBackupFrequencyType,
                                onChanged: (AutoBackupFrequencyType? value) {
                                  setState(() {
                                    _autoBackupFrequencyType = value!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text('Days'),
                              leading: Radio<AutoBackupFrequencyType>(
                                value: AutoBackupFrequencyType.DAYS,
                                groupValue: _autoBackupFrequencyType,
                                onChanged: (AutoBackupFrequencyType? value) {
                                  setState(() {
                                    _autoBackupFrequencyType = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                      ])));
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                _saveAutoBackupFrequency();
                 Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  _saveAutoBackupFrequency() async {
    int selectedValue = int.parse(autoBackUpFrequencyController.text);
    int minutes = 0;
    switch (_autoBackupFrequencyType) {
      case AutoBackupFrequencyType.HOURS:
        minutes = selectedValue * 60;
        break;
      case AutoBackupFrequencyType.DAYS:
        minutes = selectedValue * 60 * 24;
        break;
      default:
    }
    _autoBackupFrequency = minutes.toStringAsFixed(0);

    await AppConfigService().updateConfig(Constants.appConfigAutoBackupFrequency, _autoBackupFrequency!);
    await _getAutoBackupFrequency();
    setState(() {});
  }

  _updateAutoBackupFlag(bool value) async {
    _autoBackup = value;
    await AppConfigService()
        .updateFlag(Constants.appConfigAutoBackupFlag, value);
    setState(() {});
    if (_autoBackup) {
      _autoBackupFolders = await SettingsService().getFolderInfo(Constants.appConfigAutoBackupFolders);

      if (_autoBackupFolders.isEmpty) {
        
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FolderSelectionScreen(
                    Constants.appConfigAutoBackupFolders))).then(onBackFromChild);
      }
    }
  }

  _settingsList(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero, children: <Widget>[
      ListTile(
          title: Text("Backup Settings"),
      ),
      ListTile(
          title: Text("Auto Backup", style: titleTextStyle),
          subtitle: Text(
              "Automatically backup your photos and videos to your snap-crescent server"),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.cloud_upload, color: Colors.teal),
          ),
          trailing: Switch(
              value: _autoBackup,
              onChanged: (bool value) {
                _updateAutoBackupFlag(value);
              }),
        ),
      if (_autoBackup)
        ListTile(
          title: Text("Auto Backup Frequency ", style: titleTextStyle),
          subtitle: Text(_autoBackupFrequencyString),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.sync, color: Colors.teal),
          ),
          onTap: () {
            _showAutoBackupFrequencyInfoDialog();
          },
        ),
      if (_autoBackup)
        ListTile(
          title: Text("Backup Folders", style: titleTextStyle),
          subtitle:
              Text(_autoBackupFolders.isNotEmpty ? _autoBackupFolders : "None"),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.folder, color: Colors.teal),
          ),
          onTap: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FolderSelectionScreen(
                            Constants.appConfigAutoBackupFolders)))
                .then(onBackFromChild);
          },
        ),
    ]);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _getSettingsData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: const CircularProgressIndicator(),
              ),
            );
          } else {
            return _settingsList(context);
          }
        });
  }
}
