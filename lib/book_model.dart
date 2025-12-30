

class Book {
  final int? id;
  final String title;
  final String author;
  final String isbn;
  final String genre;
  final int totalCopies;
  final int availableCopies;
  final String? description;
  final String? imageUrl;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.genre,
    required this.totalCopies,
    required this.availableCopies,
    this.description,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'genre': genre,
      'total_copies': totalCopies,
      'available_copies': availableCopies,
      'description': description,
      'image_url': imageUrl,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int?,
      title: map['title'] as String,
      author: map['author'] as String,
      isbn: map['isbn'] as String,
      genre: map['genre'] as String,
      totalCopies: map['total_copies'] as int,
      availableCopies: map['available_copies'] as int,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
    );
  }

  @override
  String toString() {
    return 'Book{id: $id, title: $title, author: $author, isbn: $isbn, genre: $genre, totalCopies: $totalCopies, availableCopies: $availableCopies, description: $description, imageUrl: $imageUrl}';
  }

  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? isbn,
    String? genre,
    int? totalCopies,
    int? availableCopies,
    String? description,
    String? imageUrl,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      genre: genre ?? this.genre,
      totalCopies: totalCopies ?? this.totalCopies,
      availableCopies: availableCopies ?? this.availableCopies,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
