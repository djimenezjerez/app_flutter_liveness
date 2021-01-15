import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muserpol_app/src/models/eco_com_state.dart';
import 'package:muserpol_app/src/models/economic_complement.dart';
import 'package:muserpol_app/src/services/eco_com_state_service.dart';
import 'package:muserpol_app/src/services/economic_complement_service.dart';

class EconomicComplementsView extends StatefulWidget {
  @override
  _EconomicComplementsViewState createState() =>
      _EconomicComplementsViewState();
}

class _EconomicComplementsViewState extends State<EconomicComplementsView> {
  NumberFormat currency = NumberFormat.currency(
    locale: "es_BO",
    symbol: 'Bs',
  );
  Map<String, Color> _colors = {
    'Pagado': Colors.lightGreen[100],
    'Enviado': Colors.yellow[100],
    'Creado': Colors.blue[100],
    'No Efectivizado': Colors.red[100]
  };
  List<EcoComState> _ecoComStates;
  List<EconomicComplement> _economicComplements;
  bool _loading;
  int _page;
  int _lastPage;

  @override
  void initState() {
    super.initState();
    _loading = true;
    _ecoComStates = [];
    _page = 1;
    _lastPage = 1;
    fetchEcoComStates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complemento Económico',
        ),
      ),
      body: ListView.builder(
        itemCount:
            _economicComplements == null ? 0 : _economicComplements.length,
        itemBuilder: (context, index) {
          if (_economicComplements.length > 0) {
            return Center(
              child: Card(
                color: _colors[_ecoComStates
                    .where((state) =>
                        state.id == _economicComplements[index].ecoComStateId)
                    .first
                    .ecoComStateType
                    .name],
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                elevation: 5,
                child: InkWell(
                  onTap: () {},
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _economicComplements[index].code,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _ecoComStates
                                .where((state) =>
                                    state.id ==
                                    _economicComplements[index].ecoComStateId)
                                .first
                                .ecoComStateType
                                .name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Table(
                      columnWidths: {
                        0: FixedColumnWidth(140),
                        1: FlexColumnWidth(),
                      },
                      children: [
                        TableRow(
                          children: [
                            PaddedText(label: 'Fecha de recepción: '),
                            PaddedText(
                              label: DateFormat.yMMMMd('es_BO')
                                  .format(
                                      _economicComplements[index].receptionDate)
                                  .toString(),
                            ),
                          ],
                        ),
                        if (_economicComplements[index].ecoComStateId != null)
                          TableRow(
                            children: [
                              PaddedText(label: 'Estado: '),
                              PaddedText(
                                label: _ecoComStates
                                    .where((state) =>
                                        state.id ==
                                        _economicComplements[index]
                                            .ecoComStateId)
                                    .first
                                    .name,
                              ),
                            ],
                          ),
                        if (_economicComplements[index].totalAmountSemester !=
                            null)
                          TableRow(
                            children: [
                              PaddedText(label: 'Monto total: '),
                              PaddedText(
                                label: currency.format(double.parse(
                                    _economicComplements[index]
                                        .totalAmountSemester)),
                              ),
                            ],
                          ),
                        if (_economicComplements[index].total != null)
                          TableRow(
                            children: [
                              PaddedText(label: 'Líquido: '),
                              PaddedText(
                                label: currency.format(double.parse(
                                    _economicComplements[index].total)),
                              ),
                            ],
                          ),
                        if (_economicComplements[index].difference != null)
                          TableRow(
                            children: [
                              PaddedText(label: 'Descuento: '),
                              PaddedText(
                                label: currency.format(double.parse(
                                    _economicComplements[index].difference)),
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<void> fetchEcoComStates() async {
    try {
      List<EcoComState> ecoComStates =
          await EcoComStateService.getEcoComStates();
      fetchEconomicComplements();
      setState(() {
        _loading = true;
        _ecoComStates = ecoComStates;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> fetchEconomicComplements() async {
    try {
      final response =
          await EconomicComplementService.getEconomicComplements(_page);
      List<EconomicComplement> economicComplements =
          response['economic_complements'];
      setState(() {
        _loading = false;
        _economicComplements = economicComplements;
        _page = response['current_page'];
        _lastPage = response['last_page'];
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }
}

class PaddedText extends StatelessWidget {
  const PaddedText({
    Key key,
    @required this.label,
    this.padding = 3,
  }) : super(key: key);

  final String label;
  final int padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
