import 'package:flutter/material.dart';
import '../book_model.dart';
import '../custom_exception.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book;

  const AddEditBookScreen({super.key, this.book});

  @override
  AddEditBookScreenState createState() => AddEditBookScreenState();
}

class AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _isbnController;
  late TextEditingController _genreController;
  late TextEditingController _totalCopiesController;
  late TextEditingController _availableCopiesController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _authorController = TextEditingController(text: widget.book?.author ?? '');
    _isbnController = TextEditingController(text: widget.book?.isbn ?? '');
    _genreController = TextEditingController(text: widget.book?.genre ?? '');
    _totalCopiesController = TextEditingController(text: widget.book?.totalCopies.toString() ?? '');
    _availableCopiesController = TextEditingController(text: widget.book?.availableCopies.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.book?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.book?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _genreController.dispose();
    _totalCopiesController.dispose();
    _availableCopiesController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      // final book = Book(
      //   id: widget.book?.id,
      //   title: _titleController.text,
      //   author: _authorController.text,
      //   isbn: _isbnController.text,
      //   genre: _genreController.text,
      //   totalCopies: int.tryParse(_totalCopiesController.text) ?? 0,
      //   availableCopies: int.tryParse(_availableCopiesController.text) ?? 0,
      //   description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      //   imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
      // );

      // TODO: Implement saving/updating book using BookProvider
      // final provider = Provider.of<BookProvider>(context, listen: false);
      // final message = widget.book == null
      //     ? 'تمت إضافة الكتاب بنجاح'
      //     : 'تم تحديث الكتاب بنجاح';

      try {
        // if (widget.book == null) {
        //   await provider.addBook(book);
        // } else {
        //   await provider.updateBook(book);
        // }
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book saved successfully!'), backgroundColor: Colors.green),
        );
      } on CustomException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ الكتاب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'إضافة كتاب' : 'تعديل كتاب'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال عنوان الكتاب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    labelText: 'المؤلف',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال اسم المؤلف' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _isbnController,
                  decoration: const InputDecoration(
                    labelText: 'الرقم التسلسلي (ISBN)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال الرقم التسلسلي' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _genreController,
                  decoration: const InputDecoration(
                    labelText: 'النوع (مثل خيال علمي، تاريخ)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال نوع الكتاب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _totalCopiesController,
                  decoration: const InputDecoration(
                    labelText: 'إجمالي النسخ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال إجمالي عدد النسخ' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _availableCopiesController,
                  decoration: const InputDecoration(
                    labelText: 'النسخ المتاحة',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال عدد النسخ المتاحة' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'الوصف (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'رابط الصورة (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveBook,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('حفظ الكتاب'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
