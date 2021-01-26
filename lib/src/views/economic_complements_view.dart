import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muserpol_app/src/models/eco_com_state.dart';
import 'package:muserpol_app/src/models/economic_complement.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:muserpol_app/src/services/eco_com_state_service.dart';
import 'package:muserpol_app/src/services/economic_complement_service.dart';
import 'package:muserpol_app/src/services/media_app.dart';

class EconomicComplementsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complemento Económico',
        ),
      ),
      body: EcoComList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(Config.routes['selfie']),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[700],
      ),
    );
  }
}

class EcoComList extends StatefulWidget {
  @override
  _EcoComListState createState() => _EcoComListState();
}

class _EcoComListState extends State<EcoComList> {
  ScrollController _scrollController = ScrollController();
  List<EconomicComplement> _economicComplements = [];
  List<EcoComState> _ecoComStates = [];
  int _page = 1;
  int _lastPage = 0;
  int _totalItems = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchEcoComStates();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if ((_totalItems > _economicComplements.length || _lastPage == 0) &&
            !_loading) {
          fetchEconomicComplements();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaApp _media = MediaApp(context);

    return Center(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _economicComplements.length + 1,
        itemBuilder: (context, index) {
          if (index >= _economicComplements.length) {
            if (_totalItems > _economicComplements.length || _lastPage == 0) {
              return Container(
                margin: EdgeInsets.symmetric(
                  vertical: _media.screenHeight *
                      (_economicComplements.isEmpty ? 0.4 : 0.07),
                  horizontal: _media.screenWidth * 0.45,
                ),
                child: CircularProgressIndicator(),
              );
            } else {
              return Container();
            }
          } else {
            EconomicComplement economicComplement = _economicComplements[index];
            return EcoComCard(
              ecoComStates: _ecoComStates,
              economicComplement: economicComplement,
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
      setState(() {
        _ecoComStates = ecoComStates;
      });
      fetchEconomicComplements();
    } catch (e) {}
  }

  Future<void> fetchEconomicComplements() async {
    try {
      setState(() {
        _loading = true;
      });
      final response =
          await EconomicComplementService.getEconomicComplements(_page);
      setState(() {
        _economicComplements.addAll(response['economic_complements']);
        _lastPage = response['last_page'];
        _totalItems = response['total'];
        if (_lastPage > _page && _totalItems > _economicComplements.length) {
          _page++;
        }
        _loading = false;
      });
    } catch (e) {}
  }
}

class EcoComCard extends StatelessWidget {
  EcoComCard({
    Key key,
    @required this.ecoComStates,
    @required this.economicComplement,
  }) : super(key: key);

  final List<EcoComState> ecoComStates;
  final EconomicComplement economicComplement;

  final NumberFormat currency = NumberFormat.currency(
    locale: "es_BO",
    symbol: 'Bs',
  );
  final Map<String, Color> _colors = {
    'Pagado': Colors.lightGreen[100],
    'Enviado': Colors.yellow[100],
    'Creado': Colors.blue[100],
    'No Efectivizado': Colors.red[100]
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _colors[ecoComStates
          .where((state) => state.id == economicComplement.ecoComStateId)
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
                  ecoComStates
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
                      label: ecoComStates
                          .where((state) =>
                              state.id == economicComplement.ecoComStateId)
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
                      label: currency.format(
                          double.parse(economicComplement.totalAmountSemester)),
                    ),
                  ],
                ),
              if (economicComplement.total != null)
                TableRow(
                  children: [
                    PaddedText(label: 'Líquido: '),
                    PaddedText(
                      label: currency
                          .format(double.parse(economicComplement.total)),
                    ),
                  ],
                ),
              if (economicComplement.difference != null)
                TableRow(
                  children: [
                    PaddedText(label: 'Descuento: '),
                    PaddedText(
                      label: currency
                          .format(double.parse(economicComplement.difference)),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
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
