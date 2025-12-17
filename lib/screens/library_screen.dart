import 'package:flutter/material.dart';
import '../book_model.dart';
import 'add_edit_book_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  LibraryScreenState createState() => LibraryScreenState();
}

class LibraryScreenState extends State<LibraryScreen> {
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO: Implement fetching books when BookProvider is ready
  }

  void _filterBooks() async {
    // Made async
    setState(() {
      _isLoading = true;
    });
    try {
      // await Provider.of<BookProvider>(context, listen: false).searchBooks(_searchController.text);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToAddEditScreen([Book? book]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditBookScreen(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المكتبة'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'البحث بالعنوان، المؤلف أو الرقم التسلسلي',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
              onChanged: _isLoading
                  ? null
                  : (value) => _filterBooks(), // Disable when loading
              enabled: !_isLoading, // Disable when loading
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  ) // Show loading indicator
                : const Center(
                    child: Text('لا توجد كتب حالياً.'),
                  ), // Placeholder for book list
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : () => _navigateToAddEditScreen(),
        tooltip: 'إضافة كتاب جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}
