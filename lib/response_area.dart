import 'dart:async';

import 'package:driving_school_controller/answers_viewmodel.dart';
import 'package:driving_school_controller/main.dart';
import 'package:driving_school_controller/result.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';

class ResponseArea extends StatefulWidget {
  @override
  _ResponseAreaState createState() => _ResponseAreaState();
}

class _ResponseAreaState extends State<ResponseArea> {
  AnswerViewModel avm;
  String designOption = "grid";

  @override
  void initState() {
    avm = Provider.of<AnswerViewModel>(context, listen: false);
    super.initState();
    avm.start();

    avm.endCallback = () {
      _finish();
    };
  }

  @override
  Widget build(BuildContext context) {
    double vh = MediaQuery.of(context).size.height;
    double vw = MediaQuery.of(context).size.width;

    bool sm = vh < 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: sm ? vw : vw * .8,
              height: sm ? vh : vh * .8,
              child: Stack(
                alignment: Alignment.topRight,
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          Consumer<AnswerViewModel>(
                            builder: (_, answer, child) {
                              return Text(
                                "${answer.currentQuestionId?.toString() + ""}.",
                                style: Theme.of(context)
                                    .textTheme
                                    .display4
                                    .copyWith(fontWeight: FontWeight.w300),
                              );
                            },
                          ),
                          Spacer(flex: 1),
                          Row(
                            textDirection: TextDirection.ltr,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.format_list_bulleted,
                                    color: designOption == "list"
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade400),
                                onPressed: () {
                                  setState(() {
                                    designOption = "list";
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.grid_on,
                                    color: designOption == "grid"
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade400),
                                onPressed: () {
                                  setState(() {
                                    designOption = "grid";
                                  });
                                },
                              ),
                            ],
                          ),
                          Consumer<AnswerViewModel>(
                              builder: (_, answer, child) {
                            return LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {

                                double w = constraints.maxWidth /
                                    (designOption == "grid" ? 2 : 1);

                                double h = (designOption == "grid" ? (sm ? w / 2 : w) : (sm ? 60 : 80));

                                return Wrap(
                                  children: List.generate(
                                    4,
                                    (index) {
                                      return SizedBox(
                                        width: w,
                                        height: h,
                                        child: MaterialButton(
                                          color: avm.selected(index + 1)
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.grey.shade200,
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .display1,
                                            ),
                                          ),
                                          onPressed: () =>
                                              avm.setAnswer(index + 1),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          }),
                          Consumer<AnswerViewModel>(
                              builder: (_, answer, child) {
                            return CheckboxListTile(
                              title:
                                  Text(translator.translate("not_confirmed")),
                              value: _confirmedAnswers(),
                              onChanged: (checked) {
                                _toggleDropDown(checked);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }),
                          Spacer(
                            flex: 2,
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 40,
                                  child: RawMaterialButton(
                                    fillColor: Colors.grey.shade400,
                                    onPressed: avm.previous,
                                    child: Icon(Icons.arrow_back,
                                        color: Colors.white),
                                  ),
                                ),
                                Stack(
                                  alignment: Alignment.centerRight,
                                  overflow: Overflow.visible,
                                  children: <Widget>[
                                    RawMaterialButton(
                                      fillColor: Theme.of(context).primaryColor,
                                      onPressed: avm.next,
                                      child: Icon(Icons.arrow_forward,
                                          color: Colors.white),
                                    ),
                                    Positioned(
                                      right: -35,
                                      child: StreamBuilder<int>(
                                        stream: avm.countDown,
                                        builder: (_, snapshot) {
                                          if (snapshot.hasData) {
                                            return Text("(" +
                                                snapshot.data
                                                    .toString()
                                                    .padLeft(2, "0") +
                                                ")");
                                          } else
                                            return SizedBox.shrink();
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red, size: 28),
                    padding: EdgeInsets.all(20.0),
                    onPressed: _finish,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _finish() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => Result()));
  }

  bool _confirmedAnswers() {
    return avm.confirmedAnswersForCurrentQA();
  }

  _toggleDropDown(bool checked) {
    avm.toggleAnswerConfirmation();
  }
}
