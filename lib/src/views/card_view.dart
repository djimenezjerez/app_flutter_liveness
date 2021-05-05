import 'package:flutter/material.dart';
import 'package:muserpol_app/src/services/utils.dart';

class CardView extends StatelessWidget {
  final dynamic data;
  final Color color;
  final Function setLoading;

  const CardView({
    Key key,
    @required this.data,
    @required this.setLoading,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
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
        padding: const EdgeInsets.only(
          top: 8,
          left: 15,
          right: 15,
          bottom: 2,
        ),
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: (data['subtitle'] != '')
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  Text(
                    data['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (data['subtitle'] != '')
                    Text(
                      data['subtitle'],
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
                  for (int i = 0; i < data['display'].length; i++)
                    TableRow(
                      children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.top,
                          child: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(
                              right: 10,
                              bottom: 2,
                              top: 3,
                            ),
                            child: Text(
                              data['display'][i]['key'] + ':',
                              style: TextStyle(
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.top,
                          child: Container(
                            padding: const EdgeInsets.only(
                              bottom: 2,
                              top: 3,
                            ),
                            child: data['display'][i]['value'].runtimeType ==
                                    String
                                ? Text(data['display'][i]['value'])
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (int j = 0;
                                          j <
                                              data['display'][i]['value']
                                                  .length;
                                          j++)
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("• "),
                                            Expanded(
                                              child: Text(
                                                data['display'][i]['value'][j],
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ),
            if (data['link'] != '' && data['link'] != null)
              Container(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  onPressed: () async {
                    setLoading(true);
                    await Utils.openFile(
                        data['link'],
                        data['title']
                                .toString()
                                .replaceAll(' ', '_')
                                .replaceAll('/', '_')
                                .toLowerCase() +
                            '.pdf');
                    setLoading(false);
                  },
                  icon: Icon(Icons.print),
                ),
              )
          ],
        ),
      ),
    );
  }
}
