import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:urun_yonetim_uygulama/login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Veritabanı bağlantısını aç
  final database = openDatabase(
    join(await getDatabasesPath(), 'veritabani.db'),
    onCreate: (db, version) {
      // Kullanıcılar tablosu oluştur
      db.execute(
        'CREATE TABLE kullanicilar(id INTEGER PRIMARY KEY, kullanici_adi TEXT, sifre TEXT)',
      );

      // Kategoriler tablosu oluştur
      db.execute(
        'CREATE TABLE kategoriler(id INTEGER PRIMARY KEY AUTOINCREMENT, ad TEXT)',
      );

      // Ürünler tablosu oluştur
      return db.execute(
        'CREATE TABLE urunler(id INTEGER PRIMARY KEY AUTOINCREMENT, ad TEXT, fiyat REAL, stok INTEGER, kategori_id INTEGER, FOREIGN KEY (kategori_id) REFERENCES kategoriler (id))',
      );
    },
    version: 1,
  );

  // Veritabanının mevcut olup olmadığını kontrol et
  final db = await database;
  final kullanicilar = await db.query('kullanicilar');
  final kategoriler = await db.query('kategoriler');

  // Sadece ilk kurulumda örnek veri ekle
  if (kullanicilar.isEmpty) {
    // Örnek kullanıcı ekle
    await db.insert(
      'kullanicilar',
      {'kullanici_adi': 'admin', 'sifre': '1234'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Sadece ilk kurulumda 3 sabit kategori ekle
  if (kategoriler.isEmpty) {
    await db.insert('kategoriler', {'ad': 'Elektronik'});
    await db.insert('kategoriler', {'ad': 'Giyim'});
    await db.insert('kategoriler', {'ad': 'Gıda'});
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobil Uygulama Dersi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}
// Veritabanı yardımcı sınıfı
class DatabaseHelper {
  static Future<Database> database() async {
    return openDatabase(
      join(await getDatabasesPath(), 'veritabani.db'),
      version: 1,
    );
  }

  static Future<bool> validateUser(String username, String password) async {
    final db = await database();
    final List<Map<String, dynamic>> maps = await db.query(
      'kullanicilar',
      where: 'kullanici_adi = ? AND sifre = ?',
      whereArgs: [username, password],
    );

    return maps.isNotEmpty;
  }

  static Future<List<Map<String, dynamic>>> getKategoriler() async {
    final db = await database();
    return await db.query('kategoriler');
  }

  static Future<List<Map<String, dynamic>>> getUrunler({int? kategoriId}) async {
    final db = await database();
    if (kategoriId != null) {
      return await db.query(
        'urunler',
        where: 'kategori_id = ?',
        whereArgs: [kategoriId],
      );
    } else {
      return await db.query('urunler');
    }
  }

  static Future<Map<String, dynamic>?> getKategori(int id) async {
    final db = await database();
    final maps = await db.query(
      'kategoriler',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  static Future<int> addUrun(String ad, double fiyat, int stok, int kategoriId) async {
    final db = await database();
    return await db.insert(
      'urunler',
      {
        'ad': ad,
        'fiyat': fiyat,
        'stok': stok,
        'kategori_id': kategoriId,
      },
    );
  }

  static Future<int> updateUrun(int id, String ad, double fiyat, int stok, int kategoriId) async {
    final db = await database();
    return await db.update(
      'urunler',
      {
        'ad': ad,
        'fiyat': fiyat,
        'stok': stok,
        'kategori_id': kategoriId,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteUrun(int id) async {
    final db = await database();
    return await db.delete(
      'urunler',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}