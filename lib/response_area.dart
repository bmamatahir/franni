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

  double vh;
  double vw;

  @override
  Widget build(BuildContext context) {
    vh = MediaQuery.of(context).size.height;
    vw = MediaQuery.of(context).size.width;
    var safePadding = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Directionality(
          textDirection: TextDirection.ltr,
          child: SafeArea(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ScrollColumnExpandable(
                  padding: const EdgeInsets.all(20.0).copyWith(top: 30),
                  children: <Widget>[
                    // counter
                    Consumer<AnswerViewModel>(
                      builder: (_, answer, child) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "${answer.currentQuestionId?.toString() + ""}.",
                              style: TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),

                    // SizedBox(height: 32),
                    Spacer(flex: 1),

                    // grid or list
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

                    // control
                    buildGrid(),

                    // not confirmed
                    Consumer<AnswerViewModel>(builder: (_, answer, child) {
                      return CheckboxListTile(
                        title: Text(translator.translate("not_confirmed")),
                        value: _confirmedAnswers(),
                        onChanged: (checked) {
                          _toggleDropDown(checked);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }),

                    // SizedBox(height: 32),
                    Spacer(flex: 1),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: IconButton(
                    icon: CircleAvatar(
                      backgroundColor: Colors.red.withOpacity(.1),
                      child: Icon(Icons.close, color: Colors.red, size: 20),
                    ),
                    onPressed: _finish,
                  ),
                ),

                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        width: 40,
                        child: RawMaterialButton(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.horizontal(left: Radius.circular(20))),
                          fillColor: Colors.grey.shade400,
                          onPressed: avm.previous,
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      Stack(
                        alignment: Alignment.centerRight,
                        overflow: Overflow.visible,
                        children: <Widget>[
                          RawMaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(20))),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            fillColor: Theme.of(context).primaryColor,
                            onPressed: avm.next,
                            child: Icon(Icons.arrow_forward, color: Colors.white),
                          ),
                          Positioned(
                            right: 6,
                            child: StreamBuilder<int>(
                              stream: avm.countDown,
                              builder: (_, snapshot) {
                                if (snapshot.hasData) {
                                  return CircleAvatar(
                                    backgroundColor: Colors.grey.shade900,
                                    radius: 10,
                                    child: Text(
                                      snapshot.data.toString().padLeft(2, "0"),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11),
                                    ),
                                  );
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
      ),
    );
  }

  Widget buildGrid() {
    return Consumer<AnswerViewModel>(builder: (_, answer, child) {
      return AspectRatio(
        aspectRatio: 1,
        child: GridView.count(
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 7,
          mainAxisSpacing: 7,
          children: List.generate(
            4,
            (index) => FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.zero,
              color: avm.selected(index + 1)
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade200,
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.display1.copyWith(
                      color: avm.selected(index + 1) ? Colors.white : null),
                ),
              ),
              onPressed: () => avm.setAnswer(index + 1),
            ),
          ),
        ),
      );
    });
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

class ScrollColumnExpandable extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final VerticalDirection verticalDirection;
  final TextDirection textDirection;
  final TextBaseline textBaseline;
  final EdgeInsetsGeometry padding;

  const ScrollColumnExpandable({
    Key key,
    this.children,
    CrossAxisAlignment crossAxisAlignment,
    MainAxisAlignment mainAxisAlignment,
    VerticalDirection verticalDirection,
    EdgeInsetsGeometry padding,
    this.textDirection,
    this.textBaseline,
  })  : crossAxisAlignment = crossAxisAlignment ?? CrossAxisAlignment.center,
        mainAxisAlignment = mainAxisAlignment ?? MainAxisAlignment.start,
        verticalDirection = verticalDirection ?? VerticalDirection.down,
        padding = padding ?? EdgeInsets.zero,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[const SizedBox(width: double.infinity)];

    if (this.children != null) children.addAll(this.children);
    return LayoutBuilder(
      builder: (context, constraint) {
        return SingleChildScrollView(
          child: Padding(
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraint.maxHeight - padding.vertical,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: crossAxisAlignment,
                  mainAxisAlignment: mainAxisAlignment,
                  mainAxisSize: MainAxisSize.max,
                  verticalDirection: verticalDirection,
                  children: children,
                  textBaseline: textBaseline,
                  textDirection: textDirection,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
