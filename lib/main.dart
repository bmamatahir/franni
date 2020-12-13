import 'package:driving_school_controller/answers_viewmodel.dart';
import 'package:driving_school_controller/response_area.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
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

  int autoNextDuration =
      hiveDB.getPreferencesBox().get(hquestionAutoNextDuration) ?? 15;

  LIST_OF_LANGS = ['ar', 'en', 'fr'];
  LANGS_DIR = 'assets/i18n/';

  await translator.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<HiveDB>.value(value: hiveDB),
        ChangeNotifierProvider<AnswerViewModel>.value(
            value: AnswerViewModel(
                drivingLicenceType: drivingLicenceType,
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
      debugShowCheckedModeBanner: false,
      title: 'Driving Training',
      theme: ThemeData(
        primaryColor: Colors.blueGrey,
        accentColor: Colors.blueGrey,
      ),
      home: MyHomePage(),
      localizationsDelegates: translator.delegates,
      locale: translator.locale,
      supportedLocales: translator.locals(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

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
  String _lang;

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

    andc.text = avm.autoNextSec.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(translator.translate("appTitle")),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0).copyWith(top: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InputDecorator(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language, color: Theme.of(context).primaryColor),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  labelText: translator.translate("select_language"),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _lang ?? translator.currentLanguage,
                    items: LIST_OF_LANGS
                        .map((v) => DropdownMenuItem(
                              child: Text(v),
                              value: v,
                            ))
                        .toList(),
                    onChanged: (String lang) {
                      setState(() {
                        _lang = lang;
                        translator.setNewLanguage(context,
                            newLanguage: lang, remember: true, restart: true);
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 25),
              InputDecorator(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.car_repair, color: Theme.of(context).primaryColor),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  labelText: translator.translate("driver_license_type"),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<DrivingLicenceType>(
                    value: _selectedDrivingLicenceType,
                    items: _drivingLicenceTypes.keys
                        .map((k) => DropdownMenuItem(
                              child: Text(_drivingLicenceTypes[k]),
                              value: k,
                            ))
                        .toList(),
                    onChanged: (DrivingLicenceType dlt) {
                      setState(() {
                        _selectedDrivingLicenceType = dlt;
                        avm.drivingLicenceType = dlt;

                        _hiveDB
                            .getPreferencesBox()
                            .put(hdrivingLicenceType, EnumToString.parse(dlt));
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 25),
              InputDecorator(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer, color: Theme.of(context).primaryColor),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  labelText: translator.translate("auto_next_duration"),
                ),
                child: TextField(
                  decoration: InputDecoration.collapsed(
                    border: InputBorder.none,
                    hintText: null,
                  ),
                  controller: andc,
                  keyboardType: TextInputType.number,
                  onChanged: (String v) {
                    if (v.isNotEmpty) {
                      _hiveDB
                          .getPreferencesBox()
                          .put(hquestionAutoNextDuration, int.tryParse(v));
                      avm.autoNextSec = int.tryParse(v);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ResponseArea())),
        tooltip: 'Start Training',
        icon: Icon(Icons.play_arrow),
        label: Text(translator.translate("start")),
      ),
    );
  }
}
