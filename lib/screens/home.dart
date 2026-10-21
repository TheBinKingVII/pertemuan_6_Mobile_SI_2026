import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/data.dart';
import 'detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  bool isLoading = true;

  Future<void> fetchProducts() async {
    try {
      // Kode yang bisa jadi gagal
      final productData = await ApiService.getProducts();
      setState(() {
        products = productData;
        isLoading = false;
      });
    } catch (e) {
      // Dijalankan jika ada error di blok try
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Halo!, Budi Santoso!'),
      ),
      body: isLoading
          // Jika data belum dapat, tampilkan loading.
          ? const Center(child: CircularProgressIndicator())
          // Jika data sudah ada, tampilkan list
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailPage(productId: product.id),
                      ),
                    );
                  },
                  title: Text(product.title),
                  subtitle: Text('Rp ${product.price}'),
                  leading: Image.network(
                    product.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.black54),
                );
              },
            ),
    );
  }
}
