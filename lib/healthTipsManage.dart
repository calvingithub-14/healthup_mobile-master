import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:healthup_mobile/healthTips.dart';
import 'package:intl/intl.dart';

class AdminHealthTips extends StatefulWidget {

  // This widget is the root of your application.
  @override
  _AdminHealthTipsState createState() => _AdminHealthTipsState();

}

class _AdminHealthTipsState extends State<AdminHealthTips> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tipController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedStatus = 'Active';
  String _searchQuery = '';

  @override
  void dispose(){
    _tipController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addHealthTip() async{
    if(_formKey.currentState!.validate() && _selectedDate != null){
      await _firestore.collection('healthTips').add({
        'title': _tipController.text,
        'category': _categoryController.text,
        'date': _selectedDate,
        'status': _selectedStatus,
        'createdTime': FieldValue.serverTimestamp(),
      });

      _tipController.clear();
      _categoryController.clear();
      setState(() => _selectedDate = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("New Tips Added")),
      );
    }
  }

  Future<void> _updateTipStatus(String docId, String status) async{
    await _firestore.collection('healthTips').doc(docId).update({
      'status': status,
    });
  }

  Future<void> _deleteTip(String docId) async{
    await _firestore.collection('healthTips').doc(docId).delete();
  }

  Future<void> _selectDate(BuildContext context) async{
    final DateTime? pick = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(),
      firstDate: DateTime(2025), 
      lastDate: DateTime(2030),
    );
    if(pick != null && pick != _selectedDate){
      setState(() => _selectedDate = pick);
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Tips Management"),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.search),
          //   onPressed: () => showSearch(
          //     context: context, 
          //     delegate: HealthTipSearch(_firestore),
          //     ),
          // ),
        ],
      ),
      
      body: Column(
        children: [
          // Add New Tip Form
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _tipController,
                      decoration: InputDecoration(labelText: 'Health Tip Content'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                      maxLines: 3,
                    ),
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(labelText: 'Category'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'No date selected'
                                : 'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
                          ),
                        ),
                        TextButton(
                          onPressed: () => _selectDate(context),
                          child: Text('Select Date'),
                        ),
                      ],
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      items: ['Active', 'Inactive'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedStatus = value!),
                      decoration: InputDecoration(labelText: 'Status'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addHealthTip,
                      child: Text('Add Health Tip'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Tips List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('health_tips')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                
                final tips = snapshot.data!.docs.where((doc) {
                  final tip = doc.data() as Map<String, dynamic>;
                  return tip['content'].toString().toLowerCase()
                      .contains(_searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: tips.length,
                  itemBuilder: (context, index) {
                    final doc = tips[index];
                    final tip = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(tip['content']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category: ${tip['category']}'),
                            Text('Date: ${DateFormat('MMM dd, yyyy').format((tip['date'] as Timestamp).toDate())}'),
                            Text('Status: ${tip['status']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(doc.id, tip),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTip(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String docId, Map<String, dynamic> tip){
    final editTitleController = TextEditingController(text: tip['title']);
    final editCategoryController = TextEditingController(text: tip['category']);
    String editStatus = tip['status'];

    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text("Edit"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editTitleController,
              decoration: InputDecoration(labelText: 'Enter New Health Title'),
              maxLines: 3,
            ),
            TextField(
              controller: editCategoryController,
              decoration: InputDecoration(labelText: 'Enter New Category'),
            ),

            DropdownButton<String>(
              items: ['Active', 'Inactive'].map((String value){
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                  );
              }).toList(), 
              onChanged: (value) => editStatus = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Cancel")
          ),
          TextButton(
            onPressed: () async{
              await _firestore.collection('healthTips').doc(docId).update({
                'title': editTitleController.text,
                'category': editCategoryController.text,
                'status': editStatus,
              });
              Navigator.pop(context);
            }, 
            child: Text('Save Edit'),
          ),
        ],
      ),
    );
  }
}
