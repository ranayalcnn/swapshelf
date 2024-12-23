import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapshelfproje/add_book_screen.dart';

class WishesScreen extends StatelessWidget {
  final CollectionReference booksCollection =
      FirebaseFirestore.instance.collection('wishes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('İsteklerim')),
      body: StreamBuilder<QuerySnapshot>(
        stream: booksCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Henüz bir kitap eklenmedi.'));
          }

          final books = snapshot.data!.docs;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final bookDoc = books[index]; // Belgenin referansı
              final book = bookDoc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: Image.network(
                    book['imageUrl'] ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(book['title'] ?? 'Bilinmeyen Kitap'),
                  subtitle: Text(book['author'] ?? 'Bilinmeyen Yazar'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete,
                        color: const Color.fromARGB(255, 223, 146, 223)),
                    onPressed: () {
                      _deleteBook(context, bookDoc.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBookScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Kitabı silme fonksiyonu
  void _deleteBook(BuildContext context, String bookId) async {
    try {
      await booksCollection.doc(bookId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kitap başarıyla silindi!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silme sırasında bir hata oluştu: $e')),
      );
    }
  }
}
