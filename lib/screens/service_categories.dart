import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart' as config show apiUri;

class ServiceCategoriesScreen extends StatefulWidget {
  @override
  _ServiceCategoriesScreenState createState() =>
      _ServiceCategoriesScreenState();
}

class _ServiceCategoriesScreenState extends State<ServiceCategoriesScreen> {
  late ServiceDataSource serviceDataSource;
  List<ServiceCategory> serviceCategories = [];

  @override
  void initState() {
    super.initState();
    fetchServiceCategories();
  }

  fetchServiceCategories() async {
    final response = await http
        .get(Uri.parse('http://localhost:5000/api/servicecategories'));
    if (response.statusCode == 200) {
      setState(() {
        serviceCategories = (json.decode(response.body) as List)
            .map((data) => ServiceCategory.fromJson(data))
            .toList();
        serviceDataSource = ServiceDataSource(
          servicecategories: serviceCategories,
          onEdit: _editServiceCategory,
          onDelete: _deleteService,
        );
      });
    } else {
      throw Exception('Failed to load service categories');
    }
  }

  void _addServiceCategory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ServiceCategoryForm(
          onSubmit: (service) async {
            final response = await http.post(
              Uri.parse('http://localhost:5000/api/servicecategories'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(service.toJson()),
            );
            if (response.statusCode.toString().startsWith('2')) {
              fetchServiceCategories();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Service category added successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              throw Exception('Failed to add service category');
            }
          },
        );
      },
    );
  }

  void _editServiceCategory(ServiceCategory serviceCategory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ServiceCategoryForm(
          serviceCategory: serviceCategory,
          onSubmit: (updatedService) async {
            final response = await http.put(
              Uri.parse(
                  'http://localhost:5000/api/servicecategories/${updatedService.id}'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(updatedService.toJson()),
            );
            if (response.statusCode == 200) {
              fetchServiceCategories();
              Navigator.pop(context);
            } else {
              throw Exception('Failed to update service category');
            }
          },
        );
      },
    );
  }

  void _deleteService(int serviceId) async {
    const apiUrl =
        String.fromEnvironment('API_URI', defaultValue: config.apiUri);
    final response =
        await http.delete(Uri.parse('$apiUrl/servicecategories/$serviceId'));
    if (response.statusCode == 200) {
      fetchServiceCategories();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Service category deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      throw Exception('Failed to delete service category');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: serviceCategories.isEmpty
          ? Center(
              child: Text(
                'No service categories yet',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SfDataGrid(
                    source: serviceDataSource,
                    columns: [
                      GridColumn(
                        columnName: 'name',
                        label: Text('Name', textAlign: TextAlign.center),
                        minimumWidth: 0.3 * MediaQuery.of(context).size.width,
                      ),
                      GridColumn(
                        columnName: 'description',
                        label: Text('Description', textAlign: TextAlign.center),
                        minimumWidth: 0.4 * MediaQuery.of(context).size.width,
                      ),
                      GridColumn(
                        columnName: 'isActive',
                        label: Text('Active', textAlign: TextAlign.center),
                        minimumWidth: 0.1 * MediaQuery.of(context).size.width,
                      ),
                      GridColumn(
                        columnName: 'actions',
                        label: Text('Actions', textAlign: TextAlign.center),
                        minimumWidth: 0.2 * MediaQuery.of(context).size.width,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addServiceCategory,
        child: Icon(
          Icons.add,
          color: Color.fromARGB(255, 76, 175, 142),
        ),
      ),
    );
  }
}

class ServiceCategory {
  ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  final int id;
  final String name;
  final String description;
  final bool? isActive;

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? false,
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

class ServiceDataSource extends DataGridSource {
  ServiceDataSource({
    required List<ServiceCategory> servicecategories,
    required this.onEdit,
    required this.onDelete,
  }) {
    dataGridRows = servicecategories
        .map<DataGridRow>((service) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'name', value: service.name),
              DataGridCell<String>(
                  columnName: 'description', value: service.description),
              DataGridCell<bool>(
                  columnName: 'isActive', value: service.isActive ?? false),
              DataGridCell<Widget>(
                  columnName: 'actions',
                  value: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => onEdit(service),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => onDelete(service.id),
                      ),
                    ],
                  )),
            ]))
        .toList();
  }

  List<DataGridRow> dataGridRows = [];
  final Function(ServiceCategory) onEdit;
  final Function(int) onDelete;

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[0].value),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[1].value),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: (row.getCells()[2].value as bool)
            ? Icon(Icons.check, color: Colors.green)
            : Icon(Icons.close, color: Colors.red),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: row.getCells()[3].value, // This is already a Widget
      ),
    ]);
  }
}

class ServiceCategoryForm extends StatefulWidget {
  final ServiceCategory? serviceCategory;
  final Function(ServiceCategory) onSubmit;

  ServiceCategoryForm({required this.onSubmit, this.serviceCategory});

  @override
  _ServiceCategoryFormState createState() => _ServiceCategoryFormState();
}

class _ServiceCategoryFormState extends State<ServiceCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.serviceCategory?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.serviceCategory?.description ?? '');
    _isActive = widget.serviceCategory?.isActive ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.65,
        child: AlertDialog(
          title: Text(widget.serviceCategory == null
              ? 'Add Service Category'
              : 'Edit Service Category'),
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
                  SizedBox(height: 16), // Add some space between fields
                  Row(
                    children: [
                      Text('Active'),
                      Switch(
                        value: _isActive,
                        onChanged: (bool value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ServiceCategory newServiceCategory = ServiceCategory(
                    id: widget.serviceCategory?.id ?? 0,
                    name: _nameController.text,
                    description: _descriptionController.text,
                    isActive: _isActive,
                  );
                  widget.onSubmit(newServiceCategory);
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
