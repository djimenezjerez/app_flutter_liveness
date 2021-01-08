import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:muserpol_app/src/models/contact.dart';
import 'package:muserpol_app/src/services/contact_service.dart';
import 'package:muserpol_app/src/services/media_app.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsView extends StatefulWidget {
  @override
  _ContactsViewState createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  List<Contact> _contacts = [];
  bool _loading;

  @override
  void initState() {
    super.initState();
    _loading = true;
    ContactService.getContacts().then((contacts) {
      setState(() {
        _contacts = contacts;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaApp _media = MediaApp(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contactos',
        ),
      ),
      body: Container(
        margin: _media.isPortrait
            ? const EdgeInsets.all(10)
            : EdgeInsets.symmetric(
                horizontal: _media.screenWidth * 0.3,
              ),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        child: ListView.builder(
          itemCount: _contacts.length == 0 ? 0 : _contacts.length,
          itemBuilder: (BuildContext context, int index) {
            Contact contact = _contacts[index];
            return contactCard(contact);
          },
        ),
      ),
    );
  }

  Card contactCard(Contact contact) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          15,
        ),
      ),
      elevation: 5,
      color: Colors.lightGreen[100],
      margin: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(
          15,
        ),
        title: Container(
          margin: const EdgeInsets.only(
            bottom: 5,
          ),
          child: Text(
            contact.city.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(
                bottom: 5,
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      right: 8,
                    ),
                    child: Text(
                      'Dirección: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Flexible(
                    child: FlatButton.icon(
                      icon: Icon(
                        Icons.location_pin,
                        color: Colors.red[300],
                      ),
                      padding: const EdgeInsets.all(0),
                      height: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {
                        if (contact.coordinates.length == 2) {
                          MapsLauncher.launchCoordinates(contact.coordinates[0],
                              contact.coordinates[1], contact.address);
                        }
                      },
                      label: Flexible(
                        child: Text(
                          contact.address,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (contact.phones.length > 0)
              SizedBox(
                height: 5,
              ),
            if (contact.phones.length > 0)
              Row(
                children: [
                  Text(
                    'Teléfonos: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: contact.phones
                            .map((item) => phoneButton(contact.prefix, item))
                            .toList(),
                      ),
                    ),
                  )
                ],
              ),
            if (contact.cellphones.length > 0 && contact.phones.length == 0)
              SizedBox(
                height: 5,
              ),
            if (contact.cellphones.length > 0 && contact.phones.length > 0)
              SizedBox(
                height: 10,
              ),
            if (contact.cellphones.length > 0)
              Row(
                children: [
                  Text(
                    'Celulares: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: contact.cellphones
                            .map((item) => cellphoneButton(item))
                            .toList(),
                      ),
                    ),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  FlatButton phoneButton(int prefix, int phone) {
    final _prefix = prefix.toString();
    final _phone = phone.toString();

    return FlatButton(
      padding: const EdgeInsets.all(0),
      height: 0,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () => setState(() {
        _makePhoneCall(_prefix + _phone);
      }),
      child: Text(
        '($_prefix) $_phone',
      ),
    );
  }

  FlatButton cellphoneButton(int phone) {
    final _phone = phone.toString();

    return FlatButton(
      padding: const EdgeInsets.all(0),
      height: 0,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () => setState(() {
        _makePhoneCall(_phone);
      }),
      child: Text(
        '$_phone',
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
