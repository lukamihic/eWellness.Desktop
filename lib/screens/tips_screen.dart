import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TipsScreen extends StatefulWidget {
  @override
  _TipsScreenState createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  List<Tip> tips = [];
  late TipDataSource tipDataSource;

  @override
  void initState() {
    super.initState();
    fetchTips();
  }

  fetchTips() async {
    final response =
        await http.get(Uri.parse('http://localhost:5000/api/tips'));
    if (response.statusCode == 200) {
      setState(() {
        tips = (json.decode(response.body) as List)
            .map((data) => Tip.fromJson(data))
            .toList();
        tipDataSource = TipDataSource(
          tips: tips,
          onDelete: _deleteTip,
          onEdit: _editTip,
        );
      });
    } else {
      throw Exception('Failed to load tips');
    }
  }

  void _addTip() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TipForm(
          onSubmit: (tip) async {
            final response = await http.post(
              Uri.parse('http://localhost:5000/api/tips'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(tip.toJson()),
            );
            if (response.statusCode.toString().startsWith('2')) {
              fetchTips();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tip added successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              throw Exception('Failed to add tip');
            }
          },
        );
      },
    );
  }

  void _editTip(Tip tip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TipForm(
          tip: tip,
          onSubmit: (updatedTip) async {
            final response = await http.put(
              Uri.parse('http://localhost:5000/api/tips/${updatedTip.id}'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(updatedTip.toJson()),
            );
            if (response.statusCode == 200) {
              fetchTips();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tip updated successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              throw Exception('Failed to update tip');
            }
          },
        );
      },
    );
  }

  void _deleteTip(int id) async {
    final response =
        await http.delete(Uri.parse('http://localhost:5000/api/tips/$id'));
    if (response.statusCode == 200) {
      fetchTips();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tip deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      throw Exception('Failed to delete tip');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tips'),
      ),
      body: tips.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SfDataGrid(
              source: tipDataSource,
              columns: [
                GridColumn(
                  columnName: 'id',
                  label: Text('ID', textAlign: TextAlign.center),
                  minimumWidth: (0.1 * MediaQuery.sizeOf(context).width),
                ),
                GridColumn(
                  columnName: 'name',
                  label: Text('Name', textAlign: TextAlign.center),
                  minimumWidth: (0.2 * MediaQuery.sizeOf(context).width),
                ),
                GridColumn(
                  columnName: 'description',
                  label: Text('Description', textAlign: TextAlign.center),
                  minimumWidth: (0.45 * MediaQuery.sizeOf(context).width),
                ),
                GridColumn(
                  columnName: 'isActive',
                  label: Text('Active', textAlign: TextAlign.center),
                  minimumWidth: (0.1 * MediaQuery.sizeOf(context).width),
                ),
                GridColumn(
                  columnName: 'actions',
                  label: Text('Actions', textAlign: TextAlign.center),
                  minimumWidth: (0.15 * MediaQuery.sizeOf(context).width),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTip,
        child: Icon(Icons.add),
      ),
    );
  }
}

class Tip {
  final int id;
  final String? name;
  final String? description;
  final bool? isActive;

  Tip({
    required this.id,
    this.name,
    this.description,
    this.isActive,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
    };
  }
}

class TipDataSource extends DataGridSource {
  TipDataSource({
    required List<Tip> tips,
    required this.onDelete,
    required this.onEdit,
  }) {
    dataGridRows = tips
        .map<DataGridRow>((tip) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: tip.id),
              DataGridCell<String>(columnName: 'name', value: tip.name ?? ''),
              DataGridCell<String>(
                  columnName: 'description', value: tip.description ?? ''),
              DataGridCell<bool>(
                  columnName: 'isActive', value: tip.isActive ?? false),
              DataGridCell<Widget>(
                columnName: 'actions',
                value: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => onEdit(tip),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => onDelete(tip.id),
                    ),
                  ],
                ),
              ),
            ]))
        .toList();
  }

  List<DataGridRow> dataGridRows = [];
  final Function(int) onDelete;
  final Function(Tip) onEdit;

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[0].value.toString()),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[1].value),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[2].value),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: (row.getCells()[3].value as bool)
            ? Icon(Icons.check, color: Colors.green)
            : Icon(Icons.close, color: Colors.red),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: row.getCells()[4].value,
      ),
    ]);
  }
}

class TipForm extends StatefulWidget {
  final Tip? tip;
  final Function(Tip) onSubmit;

  TipForm({this.tip, required this.onSubmit});

  @override
  _TipFormState createState() => _TipFormState();
}

class _TipFormState extends State<TipForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tip?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.tip?.description ?? '');
    _isActive = widget.tip?.isActive ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: AlertDialog(
          title: Text(widget.tip == null ? 'Add Tip' : 'Edit Tip'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  CheckboxListTile(
                    title: Text('Active'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Tip newTip = Tip(
                    id: widget.tip?.id ?? 0,
                    name: _nameController.text,
                    description: _descriptionController.text,
                    isActive: _isActive,
                  );
                  await widget.onSubmit(newTip);
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
