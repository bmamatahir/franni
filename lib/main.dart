import 'package:driving_school_controller/answers_viewmodel.dart';
import 'package:driving_school_controller/response_area.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'hive/hivedb.dart';
import './enums.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HiveDB hiveDB = HiveDB();
  await hiveDB.connect();

  DrivingLicenceType drivingLicenceType = EnumToString.fromString(
      DrivingLicenceType.values,
      hiveDB.getPreferencesBox().get(hdrivingLicenceType) ?? "B");

  int autoNextDuration = hiveDB.getPreferencesBox().get(
      hquestionAutoNextDuration) ?? 15;

  runApp(
    MultiProvider(
      providers: [
        Provider<HiveDB>.value(value: hiveDB),
        ChangeNotifierProvider<AnswerViewModel>.value(
            value: AnswerViewModel(drivingLicenceType: drivingLicenceType,
                autoNextSec: autoNextDuration)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driving Training',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title = "Driving School Controller"})
      : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  HiveDB _hiveDB;
  int defaultNQuestions = 40;

  TextEditingController andc = TextEditingController();
  AnswerViewModel avm;

  Map<DrivingLicenceType, String> _drivingLicenceTypes = {
    DrivingLicenceType.J: 'J',
    DrivingLicenceType.A: 'A',
    DrivingLicenceType.B: 'B',
    DrivingLicenceType.C: 'C',
    DrivingLicenceType.D: 'D',
    DrivingLicenceType.EB: 'EB',
    DrivingLicenceType.EC: 'EC',
    DrivingLicenceType.ED: 'ED',
  };

  DrivingLicenceType _selectedDrivingLicenceType;

  @override
  void dispose() {
    super.dispose();
    andc.dispose();
  }

  @override
  void initState() {
    super.initState();

    _hiveDB = Provider.of<HiveDB>(context, listen: false);
    avm = Provider.of<AnswerViewModel>(context, listen: false);

    _selectedDrivingLicenceType = EnumToString.fromString(
        DrivingLicenceType.values,
        _hiveDB.getPreferencesBox().get(hdrivingLicenceType) ?? "B");

    andc.text =
        _hiveDB.getPreferencesBox().get(hquestionAutoNextDuration)
            .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                child: Text(
                  'Select Driver Licence Type',
                  style:
                  Theme
                      .of(context)
                      .textTheme
                      .caption
                      .copyWith(height: 2),
                ),
              ),
              DropdownButton<DrivingLicenceType>(
                value: _selectedDrivingLicenceType,
                items: _drivingLicenceTypes.keys
                    .map((k) =>
                    DropdownMenuItem(
                      child: Text(_drivingLicenceTypes[k]),
                      value: k,
                    ))
                    .toList(),
                onChanged: (DrivingLicenceType dlt) {
                  setState(() {
                    _selectedDrivingLicenceType = dlt;
                    andc.text = dlt.questionNumbers.toString();

                    avm.drivingLicenceType = dlt;

                    _hiveDB
                        .getPreferencesBox()
                        .put(hdrivingLicenceType, EnumToString.parse(dlt));
                  });
                },
              ),
              SizedBox(
                child: TextField(
                  controller: andc,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Auto Next Duration",
                  ),
                  onChanged: (String v) {
                    if (v.isNotEmpty)
                      _hiveDB
                          .getPreferencesBox()
                          .put(hquestionAutoNextDuration, int.tryParse(v));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => ResponseArea())),
        tooltip: 'Start Training',
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
