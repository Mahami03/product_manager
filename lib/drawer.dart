import 'package:flutter/material.dart';
import 'package:urun_yonetim_uygulama/login_screen.dart';

class AppDrawer extends StatelessWidget {

  final List<Map<String, dynamic>> kategoriler;

  final int? selectedKategoriId;

  final Function(int?, String) onKategoriSelected;

  final Function() onAddProductPressed;



  const AppDrawer({

    Key? key,

    required this.kategoriler,

    required this.selectedKategoriId,

    required this.onKategoriSelected,

    required this.onAddProductPressed,

  }) : super(key: key);



  @override

  Widget build(BuildContext context) {

    return Drawer(

      child: ListView(

        padding: EdgeInsets.zero,

        children: [

          const DrawerHeader(

            decoration: BoxDecoration(

              color: Colors.blue,

            ),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                CircleAvatar(

                  radius: 30,

                  child: Icon(Icons.shopping_cart, size: 30),

                ),

                SizedBox(height: 10),

                Text(

                  'Ürün Yönetimi',

                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 24,

                  ),

                ),

                Text(

                  'Örnek Proje',

                  style: TextStyle(

                    color: Colors.white70,

                    fontSize: 16,

                  ),

                ),

              ],

            ),

          ),

          ListTile(

            leading: const Icon(Icons.category),

            title: const Text('Tüm Ürünler'),

            selected: selectedKategoriId == null,

            onTap: () {

              onKategoriSelected(null, 'Tüm Ürünler');

              Navigator.pop(context);

            },

          ),

          const Divider(),

          const Padding(

            padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),

            child: Text(

              'KATEGORİLER',

              style: TextStyle(

                color: Colors.grey,

                fontWeight: FontWeight.bold,

              ),

            ),

          ),

          ...kategoriler.map((kategori) {

            return ListTile(

              leading: const Icon(Icons.folder),

              title: Text(kategori['ad']),

              selected: selectedKategoriId == kategori['id'],

              onTap: () {

                onKategoriSelected(kategori['id'], kategori['ad']);

                Navigator.pop(context);

              },

            );

          }).toList(),

          const Divider(),

          ListTile(

            leading: const Icon(Icons.add_business),

            title: const Text('Ürün Ekle'),

            onTap: () {

              Navigator.pop(context);

              onAddProductPressed();

            },

          ),

          ListTile(

            leading: const Icon(Icons.exit_to_app),

            title: const Text('Çıkış Yap'),

            onTap: () {

              Navigator.pushReplacement(

                context,

                MaterialPageRoute(builder: (context) => const LoginScreen()),

              );

            },

          ),

        ],

      ),

    );

  }

}