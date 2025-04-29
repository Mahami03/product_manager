import 'package:flutter/material.dart';
import 'main.dart';


class UrunEkleDuzenle extends StatefulWidget {
  final Map<String, dynamic>? urun;

  const UrunEkleDuzenle({Key? key, this.urun}) : super(key: key);

  @override
  _UrunEkleDuzenleState createState() => _UrunEkleDuzenleState();
}

class _UrunEkleDuzenleState extends State<UrunEkleDuzenle> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  int? _kategoriId;
  List<Map<String, dynamic>> _kategoriler = [];

  @override
  void initState() {
    super.initState();
    _loadKategoriler();
    if (widget.urun != null) {
      _adController.text = widget.urun!['ad'];
      _fiyatController.text = widget.urun!['fiyat'].toString();
      _stokController.text = widget.urun!['stok'].toString();
      _kategoriId = widget.urun!['kategori_id'];
    }
  }

  Future<void> _loadKategoriler() async {
    final kategoriList = await DatabaseHelper.getKategoriler();
    setState(() {
      _kategoriler = kategoriList;
    });
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      if (_kategoriId == null) return;

      if (widget.urun == null) {
        await DatabaseHelper.addUrun(
          _adController.text,
          double.parse(_fiyatController.text),
          int.parse(_stokController.text),
          _kategoriId!,
        );
      } else {
        await DatabaseHelper.updateUrun(
          widget.urun!['id'],
          _adController.text,
          double.parse(_fiyatController.text),
          int.parse(_stokController.text),
          _kategoriId!,
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.urun == null ? 'Ürün Ekle' : 'Ürünü Düzenle')),
      body: _kategoriler.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _adController,
                  decoration: const InputDecoration(labelText: 'Ad'),
                  validator: (v) => v!.isEmpty ? 'Zorunlu' : null),
              TextFormField(controller: _fiyatController,
                  decoration: const InputDecoration(labelText: 'Fiyat'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Zorunlu' : null),
              TextFormField(controller: _stokController,
                  decoration: const InputDecoration(labelText: 'Stok'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Zorunlu' : null),
              DropdownButtonFormField<int>(
                value: _kategoriId,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: _kategoriler.map((kategori) {
                  return DropdownMenuItem<int>(
                    value: kategori['id'],
                    child: Text(kategori['ad']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _kategoriId = val),
                validator: (val) => val == null ? 'Kategori seçin' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Kaydet')),
            ],
          ),
        ),
      ),
    );
  }
}