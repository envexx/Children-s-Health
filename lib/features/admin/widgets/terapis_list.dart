import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './terapis_card.dart';
import './terapis_filter.dart';

class TerapisListScreen extends StatefulWidget {
  const TerapisListScreen({Key? key}) : super(key: key);

  @override
  State<TerapisListScreen> createState() => _TerapisListScreenState();
}

class _TerapisListScreenState extends State<TerapisListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String _selectedSpesialisasi = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TerapisFilter(
          onSearchChanged: (value) => setState(() => _searchQuery = value),
          onSpesialisasiChanged: (value) =>
              setState(() => _selectedSpesialisasi = value),
          selectedSpesialisasi: _selectedSpesialisasi,
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('terapis').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Terjadi kesalahan'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final filteredDocs = _filterDocs(snapshot.data?.docs ?? []);

              if (filteredDocs.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocs[index];
                  return TerapisCard(
                    terapisId: doc.id,
                    data: doc.data() as Map<String, dynamic>,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<QueryDocumentSnapshot> _filterDocs(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final matchesSearch = data['nama']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          data['email']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesSpesialisasi = _selectedSpesialisasi == 'Semua' ||
          data['spesialisasi'] == _selectedSpesialisasi;

      return matchesSearch && matchesSpesialisasi;
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada terapis yang sesuai',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
