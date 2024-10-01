import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart' as config show apiUri;
import 'package:intl/intl.dart';

class DiscountScreen extends StatefulWidget {
  @override
  _DiscountScreenState createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  List<SpecialOffer> specialOffers = [];
  late SpecialOfferDataSource specialOfferDataSource;

  @override
  void initState() {
    super.initState();
    fetchSpecialOffers();
  }

  fetchSpecialOffers() async {
    final response =
        await http.get(Uri.parse('${config.apiUri}/specialOffers'));
    if (response.statusCode == 200) {
      setState(() {
        specialOffers = (json.decode(response.body) as List)
            .map((data) => SpecialOffer.fromJson(data))
            .toList();
        specialOfferDataSource = SpecialOfferDataSource(
          specialOffers: specialOffers,
          onEdit: _editSpecialOffer,
          onDelete: _deleteSpecialOffer,
        );
      });
    } else {
      throw Exception('Failed to load special offers');
    }
  }

  void _addSpecialOffer() async {
    final newSpecialOffer = await showDialog<SpecialOffer>(
      context: context,
      builder: (BuildContext context) {
        return SpecialOfferDialog(
          specialOffer: SpecialOffer(
            id: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isDeleted: false,
            name: '',
            description: '',
            isActive: false,
            offerExpirationDate: DateTime.now().add(Duration(days: 30)),
          ),
          isEdit: false,
        );
      },
    );

    if (newSpecialOffer != null) {
      final response = await http.post(
        Uri.parse('${config.apiUri}/specialOffers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newSpecialOffer.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        fetchSpecialOffers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Special offer added successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to add special offer');
      }
    }
  }

  void _editSpecialOffer(SpecialOffer offer) async {
    final updatedOffer = await showDialog<SpecialOffer>(
      context: context,
      builder: (BuildContext context) {
        return SpecialOfferDialog(
          specialOffer: offer,
          isEdit: true,
        );
      },
    );

    if (updatedOffer != null) {
      final response = await http.put(
        Uri.parse('${config.apiUri}/specialOffers/${updatedOffer.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedOffer.toJson()),
      );

      if (response.statusCode == 200) {
        fetchSpecialOffers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Special offer updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to update special offer');
      }
    }
  }

  void _deleteSpecialOffer(int offerId) async {
    final response = await http.delete(
      Uri.parse('${config.apiUri}/specialOffers/$offerId'),
    );
    if (response.statusCode == 200) {
      fetchSpecialOffers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Special offer deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      throw Exception('Failed to delete special offer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: specialOffers.isEmpty
          ? Center(
              child: Text(
                'No special offers available',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            )
          : SfDataGrid(
              source: specialOfferDataSource,
              columns: [
                GridColumn(
                  columnName: 'name',
                  label: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('Name', textAlign: TextAlign.center),
                  ),
                  minimumWidth: (0.2 * MediaQuery.of(context).size.width),
                ),
                GridColumn(
                  columnName: 'description',
                  label: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('Description', textAlign: TextAlign.center),
                  ),
                  minimumWidth: (0.3 * MediaQuery.of(context).size.width),
                ),
                GridColumn(
                  columnName: 'isActive',
                  label: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('Active', textAlign: TextAlign.center),
                  ),
                  minimumWidth: (0.1 * MediaQuery.of(context).size.width),
                ),
                GridColumn(
                  columnName: 'offerExpirationDate',
                  label: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('Expiration Date', textAlign: TextAlign.center),
                  ),
                  minimumWidth: (0.2 * MediaQuery.of(context).size.width),
                ),
                GridColumn(
                  columnName: 'actions',
                  label: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('Actions', textAlign: TextAlign.center),
                  ),
                  minimumWidth: (0.2 * MediaQuery.of(context).size.width),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSpecialOffer,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class SpecialOffer {
  int id;
  DateTime createdAt;
  DateTime updatedAt;
  bool isDeleted;
  String name;
  String? description;
  bool isActive;
  DateTime offerExpirationDate;

  SpecialOffer({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.name,
    this.description,
    required this.isActive,
    required this.offerExpirationDate,
  });

  factory SpecialOffer.fromJson(Map<String, dynamic> json) {
    return SpecialOffer(
      id: json['id'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isDeleted: json['isDeleted'] ?? false,
      name: json['name'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? false,
      offerExpirationDate: DateTime.parse(json['offerExpirationDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'name': name,
      'description': description,
      'isActive': isActive,
      'offerExpirationDate': offerExpirationDate.toIso8601String(),
    };
  }
}

class SpecialOfferDataSource extends DataGridSource {
  SpecialOfferDataSource({
    required this.specialOffers,
    required this.onEdit,
    required this.onDelete,
  }) {
    dataGridRows = specialOffers.map<DataGridRow>((offer) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'name', value: offer.name),
        DataGridCell<String>(
            columnName: 'description', value: offer.description),
        DataGridCell<bool>(columnName: 'isActive', value: offer.isActive),
        DataGridCell<String>(
          columnName: 'offerExpirationDate',
          value: DateFormat('yyyy-MM-dd').format(offer.offerExpirationDate),
        ),
        DataGridCell<Widget>(
          columnName: 'actions',
          value: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => onEdit(offer),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => onDelete(offer.id),
              ),
            ],
          ),
        ),
      ]);
    }).toList();
  }

  List<DataGridRow> dataGridRows = [];
  final List<SpecialOffer> specialOffers;
  final Function(SpecialOffer) onEdit;
  final Function(int) onDelete;

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'actions') {
          // Directly return the Row widget for actions
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => onEdit(
                    row.getCells()[0].value), // Use the ID or appropriate value
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => onDelete(
                    row.getCells()[0].value), // Use the ID or appropriate value
              ),
            ],
          );
        }
        return Container(
          padding: EdgeInsets.all(8.0),
          child: Text(cell.value.toString()), // Convert cell value to String
        );
      }).toList(),
    );
  }
}

class SpecialOfferDialog extends StatelessWidget {
  final SpecialOffer specialOffer;
  final bool isEdit;

  SpecialOfferDialog({required this.specialOffer, required this.isEdit});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: specialOffer.name);
    final descriptionController =
        TextEditingController(text: specialOffer.description);
    final expirationDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(specialOffer.offerExpirationDate),
    );

    return AlertDialog(
      title: Text(isEdit ? 'Edit Special Offer' : 'Add Special Offer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          TextField(
            controller: expirationDateController,
            decoration:
                InputDecoration(labelText: 'Expiration Date (yyyy-MM-dd)'),
          ),
          CheckboxListTile(
            title: Text('Active'),
            value: specialOffer.isActive,
            onChanged: (value) {
              specialOffer.isActive = value ?? false;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final updatedOffer = SpecialOffer(
              id: specialOffer.id,
              createdAt: specialOffer.createdAt,
              updatedAt: DateTime.now(),
              isDeleted: false,
              name: nameController.text,
              description: descriptionController.text,
              isActive: specialOffer.isActive,
              offerExpirationDate:
                  DateTime.parse(expirationDateController.text),
            );
            Navigator.of(context).pop(updatedOffer);
          },
          child: Text('Save'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
