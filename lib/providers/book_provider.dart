import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../book_model.dart';

class BookProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Book> _books = [];

  List<Book> get books => _books;

  BookProvider() {
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    _books = await _databaseHelper.getBooks();
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    await _databaseHelper.createBook(book);
    await _fetchBooks();
  }

  Future<void> updateBook(Book book) async {
    await _databaseHelper.updateBook(book);
    await _fetchBooks();
  }

  Future<void> deleteBook(int id) async {
    await _databaseHelper.deleteBook(id);
    await _fetchBooks();
  }

  Future<List<Book>> searchBooks(String query) async {
    return await _databaseHelper.searchBooks(query);
  }

  Future<Book?> getBookById(int id) async {
    return await _databaseHelper.getBookById(id);
  }

  Future<void> decreaseAvailableQuantity(int bookId, int quantity) async {
    final book = await _databaseHelper.getBookById(bookId);
    if (book != null && book.availableCopies >= quantity) {
      final updatedBook = book.copyWith(availableCopies: book.availableCopies - quantity);
      await _databaseHelper.updateBook(updatedBook);
      await _fetchBooks();
    } else {
      throw Exception('Not enough available copies or book not found.');
    }
  }

  Future<void> increaseAvailableQuantity(int bookId, int quantity) async {
    final book = await _databaseHelper.getBookById(bookId);
    if (book != null) {
      final updatedBook = book.copyWith(availableCopies: book.availableCopies + quantity);
      await _databaseHelper.updateBook(updatedBook);
      await _fetchBooks();
    } else {
      throw Exception('Book not found.');
    }
  }
}