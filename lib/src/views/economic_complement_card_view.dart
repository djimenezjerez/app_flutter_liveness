import 'package:flutter/material.dart';

class EconomicComplementCardView extends StatelessWidget {
  final dynamic procedure;
  const EconomicComplementCardView({
    Key key,
    @required this.procedure,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    procedure['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    procedure['subtitle'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 5,
              ),
              child: Table(
                border: TableBorder(
                  horizontalInside: BorderSide(
                    width: 0.5,
                    color: Colors.grey,
                    style: BorderStyle.solid,
                  ),
                ),
                children: [
                  for (int i = 0; i < procedure['display'].length; i++)
                    TableRow(
                      children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.top,
                          child: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(
                              right: 10,
                              bottom: 3,
                              top: 3,
                            ),
                            child: Text(
                              procedure['display'][i]['key'] + ':',
                              style: TextStyle(
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                            verticalAlignment: TableCellVerticalAlignment.top,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: procedure['display'][i]['value']
                                          .runtimeType ==
                                      String
                                  ? Text(procedure['display'][i]['value'])
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (int j = 0;
                                            j <
                                                procedure['display'][i]['value']
                                                    .length;
                                            j++)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("• "),
                                              Expanded(
                                                child: Text(
                                                  procedure['display'][i]
                                                      ['value'][j],
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                            )),
                      ],
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
