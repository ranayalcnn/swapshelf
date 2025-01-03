import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExchangeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Center(child: Text('Please login to view exchanges'));
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: 'Available Books'),
              Tab(text: 'My Requests'),
              Tab(text: 'Incoming Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAvailableBooks(currentUser),
            _buildMyRequests(currentUser),
            _buildIncomingRequests(currentUser),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableBooks(User currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('library_books')
          .where('userId', isNotEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('An error occurred'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final books = snapshot.data?.docs ?? [];

        if (books.isEmpty) {
          return Center(child: Text('No books available for exchange'));
        }

        return ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final bookData = books[index].data() as Map<String, dynamic>;
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  bookData['title'] ?? 'Unknown Book',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Author: ${bookData['authorName'] ?? 'Unknown Author'}'),
                    Text('Owner: ${bookData['ownerName'] ?? 'Unknown Owner'}'),
                    Text('Condition: ${bookData['condition'] ?? 'Unknown'}'),
                    Text('Category: ${bookData['category'] ?? 'Unknown'}'),
                    if (bookData['description'] != null)
                      Text('Description: ${bookData['description']}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () =>
                      _sendExchangeRequest(context, bookData, currentUser),
                  child: Text('Request Exchange'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyRequests(User currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('exchanges')
          .where('requesterId', isEqualTo: currentUser.uid)
          .where('status',
              whereIn: ['pending', 'accepted', 'rejected']).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('An error occurred'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data?.docs ?? [];

        if (requests.isEmpty) {
          return Center(child: Text('No active exchange requests'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            final status = request['status'] as String;

            Color statusColor;
            switch (status) {
              case 'pending':
                statusColor = Colors.orange;
                break;
              case 'accepted':
                statusColor = Colors.green;
                break;
              case 'rejected':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.grey;
            }

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  request['bookTitle'] ?? 'Unknown Book',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Author: ${request['bookAuthor'] ?? 'Unknown Author'}'),
                    Text('Owner: ${request['ownerName'] ?? 'Unknown Owner'}'),
                    Text(
                        'Category: ${request['category'] ?? 'Unknown Category'}'),
                    Text(
                        'Condition: ${request['condition'] ?? 'Unknown Condition'}'),
                    Row(
                      children: [
                        Text('Status: '),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: status == 'pending'
                    ? IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        onPressed: () =>
                            _showCancelDialog(context, requests[index].id),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIncomingRequests(User currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('exchanges')
          .where('ownerId', isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('An error occurred'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data?.docs ?? [];

        if (requests.isEmpty) {
          return Center(child: Text('No incoming exchange requests'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            final status = request['status'] as String;

            Color statusColor;
            switch (status) {
              case 'pending':
                statusColor = Colors.orange;
                break;
              case 'accepted':
                statusColor = Colors.green;
                break;
              case 'rejected':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.grey;
            }

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  request['bookTitle'] ?? 'Unknown Book',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Author: ${request['bookAuthor'] ?? 'Unknown Author'}'),
                    FutureBuilder<DocumentSnapshot>(
                      future: _firestore
                          .collection('users')
                          .doc(request['requesterId'])
                          .get(),
                      builder: (context, userSnapshot) {
                        String requesterName =
                            request['requesterName'] ?? 'Unknown User';
                        if (userSnapshot.hasData && userSnapshot.data != null) {
                          final userData = userSnapshot.data!.data()
                              as Map<String, dynamic>?;
                          requesterName = userData?['name'] ??
                              request['requesterName'] ??
                              'Unknown User';
                        }
                        return Text('Requested by: $requesterName');
                      },
                    ),
                    Text(
                        'Category: ${request['category'] ?? 'Unknown Category'}'),
                    Text(
                        'Condition: ${request['condition'] ?? 'Unknown Condition'}'),
                    Row(
                      children: [
                        Text('Status: '),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: status == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _updateExchangeStatus(
                              context,
                              requests[index].id,
                              'accepted',
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _updateExchangeStatus(
                              context,
                              requests[index].id,
                              'rejected',
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Exchange Request'),
          content:
              Text('Are you sure you want to cancel this exchange request?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _firestore
                      .collection('exchanges')
                      .doc(requestId)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Exchange request cancelled successfully')),
                  );
                } catch (e) {
                  print('Error cancelling exchange: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to cancel exchange request')),
                  );
                }
              },
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendExchangeRequest(
    BuildContext context,
    Map<String, dynamic> bookData,
    User currentUser,
  ) async {
    try {
      // Önce kullanıcının adını Firestore'dan al
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      final requesterName =
          userDoc.data()?['name'] ?? currentUser.email ?? 'Unknown User';

      // Takas isteği zaten var mı kontrol et
      final existingRequest = await _firestore
          .collection('exchanges')
          .where('bookTitle', isEqualTo: bookData['title'])
          .where('requesterId', isEqualTo: currentUser.uid)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You already requested this book')),
        );
        return;
      }

      // Yeni takas isteği oluştur
      await _firestore.collection('exchanges').add({
        'bookTitle': bookData['title'],
        'bookAuthor': bookData['authorName'],
        'ownerId': bookData['userId'],
        'ownerName': bookData['ownerName'],
        'requesterId': currentUser.uid,
        'requesterName': requesterName,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'description': bookData['description'],
        'condition': bookData['condition'],
        'category': bookData['category'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exchange request sent successfully!')),
      );
    } catch (e) {
      print('Error sending exchange request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send exchange request')),
      );
    }
  }

  Future<void> _updateExchangeStatus(
      BuildContext context, String requestId, String newStatus) async {
    try {
      await _firestore.collection('exchanges').doc(requestId).update({
        'status': newStatus,
      });

      String message = newStatus == 'accepted'
          ? 'Exchange request accepted'
          : 'Exchange request rejected';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      print('Error updating exchange status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update exchange status')),
      );
    }
  }
}
