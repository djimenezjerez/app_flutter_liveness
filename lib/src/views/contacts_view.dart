import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:muserpol_app/src/models/contact.dart';
import 'package:muserpol_app/src/services/contact_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Contactos a nivel nacional',
          ),
        ),
        body: ContactList(),
      ),
    );
  }
}

class ContactList extends StatefulWidget {
  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  bool _loading = true;
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    if (_contacts.length > 0) {
      return ListView.builder(
        itemCount: _contacts.length + 1,
        itemBuilder: (context, index) {
          if (index >= _contacts.length) {
            return SizedBox(
              height: 15,
            );
          }
          Contact contact = _contacts[index];
          return ContactCard(contact: contact);
        },
      );
    } else {
      if (_loading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return Center(
          child: Text(
            'Error de conexión',
          ),
        );
      }
    }
  }

  void fetchContacts() async {
    try {
      List<Contact> contacts = await ContactService.getContacts();
      setState(() {
        _contacts = contacts;
      });
    } catch (e) {}
    setState(() {
      _loading = false;
    });
  }
}

class ContactCard extends StatelessWidget {
  const ContactCard({
    Key key,
    @required this.contact,
  }) : super(key: key);

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      elevation: 5,
      color: Colors.lightGreen[100],
      margin: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 15,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(
          15,
        ),
        title: Container(
          margin: const EdgeInsets.only(
            bottom: 7,
          ),
          child: Text(
            contact.name.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        subtitle: Table(
          columnWidths: {
            0: const FixedColumnWidth(80),
            1: FlexColumnWidth(),
          },
          children: [
            TableRow(
              children: [
                PaddedText(label: 'Dirección: '),
                TextButton.icon(
                  icon: Icon(
                    Icons.location_pin,
                    color: Colors.red[300],
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                  ),
                  onPressed: () {
                    if (contact.latitude != null && contact.longitude != null) {
                      MapsLauncher.launchCoordinates(contact.latitude,
                          contact.longitude, contact.companyAddress.toString());
                    }
                  },
                  label: Flexible(
                    child: Text(
                      contact.companyAddress,
                    ),
                  ),
                ),
              ],
            ),
            if (contact.companyPhones.length > 0)
              TableRow(
                children: [
                  PaddedText(label: 'Teléfonos: '),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: contact.companyPhones.map((phone) {
                        int prefix = contact.phonePrefix;
                        return TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: () => _makePhoneCall(
                              prefix.toString() + phone.toString()),
                          child: PaddedText(label: '($prefix) $phone'),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            if (contact.companyCellphones.length > 0)
              TableRow(
                children: [
                  PaddedText(label: 'Celulares: '),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: contact.companyCellphones.map((phone) {
                        return TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: () => _makePhoneCall(phone.toString()),
                          child: PaddedText(label: '$phone'),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    String url = 'tel:$phone';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}

class PaddedText extends StatelessWidget {
  const PaddedText({
    Key key,
    @required this.label,
  }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
