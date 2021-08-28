import 'package:flutter/material.dart';
import 'package:franni/main.dart';
import 'package:franni/qa_model.dart';
import 'package:provider/provider.dart';

import './enums.dart';
import 'answers_viewmodel.dart';

class Result extends StatefulWidget {
  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  AnswerViewModel avm;

  @override
  void initState() {
    super.initState();
    avm = Provider.of<AnswerViewModel>(context, listen: false);
  }

  List<int> wrongAnswers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => MyHomePage()),
              (Route<dynamic> route) => false);
          avm.reset();
        },
        tooltip: 'Restart',
        child: Icon(Icons.refresh),
      ),
      body: SafeArea(
        child: GridView.count(
          crossAxisCount: 5,
          children: List.generate(
            avm.drivingLicenceType.questionNumbers,
            (index) {
              return SizedBox(
                height: MediaQuery.of(context).size.height /
                    (avm.drivingLicenceType.questionNumbers / 5).floor(),
                child: MaterialButton(
                  padding: EdgeInsets.all(0),
                  color: emptyQuestion(index + 1)
                      ? Colors.white10
                      : isWrong(index + 1)
                          ? Colors.red
                          : Colors.black12,
                  child: Stack(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${index + 1}',
                            style: Theme.of(context).textTheme.body2,
                          ),
                          const Divider(
                            color: Colors.black12,
                            thickness: 1,
                          ),
                          getAnswers(index + 1),
                        ],
                      ),
                      if (_confirmedAnswers(index + 1))
                        Positioned(
                          top: 2,
                          right: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.yellowAccent.withOpacity(.3),
                            ),
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              '?',
                              style: Theme.of(context).textTheme.body2.copyWith(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () => markAnswerAsWrong(index + 1),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Text getAnswers(qId) {
    QuestionAnswers qa = avm.getQA(qId);

    if (qa == null || qa.isEmpty()) return Text("---");

    return Text(
      qa.printAnswers(),
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
    );
  }

  bool emptyQuestion(qId) {
    QuestionAnswers qa = avm.getQA(qId);
    if (qa == null) return false;
    return avm.getQA(qId).isEmpty();
  }

  bool isWrong(qId) {
    return wrongAnswers.contains(qId);
  }

  markAnswerAsWrong(qId) {
    if (wrongAnswers.contains(qId)) {
      setState(() {
        wrongAnswers.remove(qId);
      });
    } else
      setState(() {
        wrongAnswers.add(qId);
      });
  }

  bool _confirmedAnswers(qId) {
    bool r = avm.confirmedAnswer(qId);
    return r;
  }
}
