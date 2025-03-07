import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart' as config show apiUri;

class ServiceCategoriesScreen extends StatefulWidget {
  const ServiceCategoriesScreen({super.key});

  @override
  _ServiceCategoriesScreenState createState() =>
      _ServiceCategoriesScreenState();
}

class _ServiceCategoriesScreenState extends State<ServiceCategoriesScreen> {
  late ServiceDataSource serviceDataSource;
  List<ServiceCategory> serviceCategories = [];
  static const apiUrl =
      String.fromEnvironment('API_URI', defaultValue: config.apiUri);
  String token = '';

  @override
  void initState() {
    super.initState();
    fetchServiceCategories();
  }

  fetchServiceCategories() async {
    final Uri fullApiUrl = Uri.parse('$apiUrl/users/login');

    final Map<String, String> body = {
      'email': 'desktop',
      'password': 'test',
    };

    final responseLogin = await http.post(
      fullApiUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(body),
    );

    if (responseLogin.statusCode == 200) {
      token = responseLogin.body.toString();
    } else {
      throw Exception('Failed to fetch user.');
    }

    final response = await http
        .get(Uri.parse('$apiUrl/servicecategories'), headers:{HttpHeaders.authorizationHeader: 'Bearer $token'});
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
              Uri.parse('$apiUrl/servicecategories'),
              headers: {'Content-Type': 'application/json', HttpHeaders.authorizationHeader: 'Bearer $token'},
              body: jsonEncode(service.toJson()),
            );
            if (response.statusCode.toString().startsWith('2')) {
              fetchServiceCategories();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
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
                  '$apiUrl/servicecategories/${updatedService.id}'),
              headers: {'Content-Type': 'application/json', HttpHeaders.authorizationHeader: 'Bearer $token'},
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
        await http.delete(Uri.parse('$apiUrl/servicecategories/$serviceId'),headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      fetchServiceCategories();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
          ? const Center(
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
                        label: const Text('Name', textAlign: TextAlign.center),
                        minimumWidth: 0.3 * MediaQuery.of(context).size.width,
                      ),
                      GridColumn(
                        columnName: 'description',
                        label: const Text('Description', textAlign: TextAlign.center),
                        minimumWidth: 0.4 * MediaQuery.of(context).size.width,
                      ),
                      GridColumn(
                        columnName: 'isActive',
                        label: const Text('Active', textAlign: TextAlign.center),
                        minimumWidth: 0.1 * MediaQuery.of(context).size.width,
                      ),
                      GridColumn(
                        columnName: 'actions',
                        label: const Text('Actions', textAlign: TextAlign.center),
                        minimumWidth: 0.2 * MediaQuery.of(context).size.width,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addServiceCategory,
        child: const Icon(
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
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEdit(service),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
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
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[0].value),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[1].value),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: (row.getCells()[2].value as bool)
            ? const Icon(Icons.check, color: Colors.green)
            : const Icon(Icons.close, color: Colors.red),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: row.getCells()[3].value, // This is already a Widget
      ),
    ]);
  }
}

class ServiceCategoryForm extends StatefulWidget {
  final ServiceCategory? serviceCategory;
  final Function(ServiceCategory) onSubmit;

  const ServiceCategoryForm({super.key, required this.onSubmit, this.serviceCategory});

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
      child: SizedBox(
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
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 16), // Add some space between fields
                  Row(
                    children: [
                      const Text('Active'),
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
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
