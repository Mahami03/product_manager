import 'package:flutter/material.dart';
import 'main.dart';
import 'drawer.dart';
import 'urun_ekle_duzenle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> urunler = [];
  List<Map<String, dynamic>> kategoriler = [];
  int? selectedKategoriId;
  String selectedKategoriAd = "Tüm Ürünler";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final kList = await DatabaseHelper.getKategoriler();
    final uList = await DatabaseHelper.getUrunler(kategoriId: selectedKategoriId);
    setState(() {
      kategoriler = kList;
      urunler = uList;
    });
  }

  void _onKategoriSelected(int? id, String ad) {
    setState(() {
      selectedKategoriId = id;
      selectedKategoriAd = ad;
    });
    _loadData();
  }

  void _onAddProductPressed() async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: SizedBox(
          width: 400,
          height: 500,
          child: UrunEkleDuzenle(),
        ),
      ),
    );
    _loadData();
  }

  Future<void> _confirmDelete(int urunId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ürünü Sil'),
          content: const Text('Bu ürünü silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper.deleteUrun(urunId);
                _loadData();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Sil',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(selectedKategoriAd)),
      drawer: AppDrawer(
        kategoriler: kategoriler,
        selectedKategoriId: selectedKategoriId,
        onKategoriSelected: _onKategoriSelected,
        onAddProductPressed: _onAddProductPressed,
      ),
      body: urunler.isEmpty
          ? const Center(
        child: Text(
          'Bu kategoride ürün bulunamadı.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: urunler.length,
        itemBuilder: (context, index) {
          final urun = urunler[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              title: Text(urun['ad']),
              subtitle: Text("Fiyat: ${urun['fiyat']}₺ - Stok: ${urun['stok']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: SizedBox(
                            width: 400,
                            height: 500,
                            child: UrunEkleDuzenle(urun: urun),
                          ),
                        ),
                      );
                      _loadData();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _confirmDelete(urun['id']);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddProductPressed,
        child: const Icon(Icons.add),
      ),
    );
  }
}
