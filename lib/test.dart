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