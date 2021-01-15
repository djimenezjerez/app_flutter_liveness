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
  final int _nextPageThreshold = 7;
  bool _loading;
  int _page;
  int _totalItems;

  @override
  void initState() {
    super.initState();
    _loading = true;
    _ecoComStates = [];
    _page = 1;
    _economicComplements = [];
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
      body: getBody(),
    );
  }

  Widget getBody() {
    if (_economicComplements.isNotEmpty) {
      return ListView.builder(
        itemCount: _economicComplements.isNotEmpty
            ? _economicComplements.length
            : _totalItems == null
                ? 0
                : _totalItems,
        itemBuilder: (context, index) {
          if (index == _economicComplements.length - _nextPageThreshold &&
              !_loading) {
            fetchEconomicComplements();
          }
          final EconomicComplement economicComplement =
              _economicComplements[index];
          return Center(
            child: Card(
              color: _colors[_ecoComStates
                  .where(
                      (state) => state.id == economicComplement.ecoComStateId)
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
                          economicComplement.code,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _ecoComStates
                              .where((state) =>
                                  state.id == economicComplement.ecoComStateId)
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
                                .format(economicComplement.receptionDate)
                                .toString(),
                          ),
                        ],
                      ),
                      if (economicComplement.ecoComStateId != null)
                        TableRow(
                          children: [
                            PaddedText(label: 'Estado: '),
                            PaddedText(
                              label: _ecoComStates
                                  .where((state) =>
                                      state.id ==
                                      economicComplement.ecoComStateId)
                                  .first
                                  .name,
                            ),
                          ],
                        ),
                      if (economicComplement.totalAmountSemester != null)
                        TableRow(
                          children: [
                            PaddedText(label: 'Monto total: '),
                            PaddedText(
                              label: currency.format(double.parse(
                                  economicComplement.totalAmountSemester)),
                            ),
                          ],
                        ),
                      if (economicComplement.total != null)
                        TableRow(
                          children: [
                            PaddedText(label: 'Líquido: '),
                            PaddedText(
                              label: currency.format(
                                  double.parse(economicComplement.total)),
                            ),
                          ],
                        ),
                      if (economicComplement.difference != null)
                        TableRow(
                          children: [
                            PaddedText(label: 'Descuento: '),
                            PaddedText(
                              label: currency.format(
                                  double.parse(economicComplement.difference)),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Text(
        'Aún no ha registrado ningún trámite de Complemento Económico',
      );
    }
  }

  Future<void> fetchEcoComStates() async {
    try {
      List<EcoComState> ecoComStates =
          await EcoComStateService.getEcoComStates();
      fetchEconomicComplements();
      setState(() {
        _ecoComStates = ecoComStates;
      });
    } catch (e) {}
  }

  Future<void> fetchEconomicComplements() async {
    bool fetch = true;
    if (_economicComplements.isNotEmpty) {
      if (_totalItems != null) {
        if (_totalItems == _economicComplements.length) {
          fetch = false;
        }
      }
    }
    if (fetch) {
      _loading = true;
      try {
        final response =
            await EconomicComplementService.getEconomicComplements(_page);
        setState(() {
          _totalItems = response['total'];
          _loading = false;
          _economicComplements.addAll(response['economic_complements']);
          if (response['last_page'] > _page) {
            _page++;
          }
        });
      } catch (e) {
        setState(() => _loading = false);
      }
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
