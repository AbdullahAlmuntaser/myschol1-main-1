import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../book_model.dart';
import '../providers/book_provider.dart';
import 'add_edit_book_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  LibraryScreenState createState() => LibraryScreenState();
}

class LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch books initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterBooks();
    });
  }

  void _filterBooks() {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    bookProvider.searchBooks(_searchController.text);
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
              onChanged: (value) => _filterBooks(),
            ),
          ),
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, bookProvider, child) {
                if (bookProvider.books.isEmpty) {
                  return const Center(
                    child: Text('لا توجد كتب حالياً.'),
                  );
                }
                return ListView.builder(
                  itemCount: bookProvider.books.length,
                  itemBuilder: (context, index) {
                    final book = bookProvider.books[index];
                    return ListTile(
                      title: Text(book.title),
                      subtitle: Text(book.author),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _navigateToAddEditScreen(book),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('تأكيد الحذف'),
                                  content: const Text(
                                      'هل أنت متأكد أنك تريد حذف هذا الكتاب؟'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('إلغاء'),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('حذف'),
                                      onPressed: () async {
                                        await bookProvider.deleteBook(book.id!);
                                        if (!mounted) return;
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(ctx).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        tooltip: 'إضافة كتاب جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}
