# Modul 5 - HTTP Request (Praktikum Teknologi dan Pemrograman Mobile)

Project ini berisi hasil langkah praktikum Modul 5: mengganti sumber data yang awalnya statis menjadi **dinamis** menggunakan API [DummyJSON](https://dummyjson.com/products).

Project dasar berasal dari Modul 4 (`modul_4_prak_mobile`). Di sini ditampilkan hasil akhirnya, dan setiap langkah dijelaskan di bawah agar bisa diikuti ulang.

## Struktur Project

```
lib/
├── main.dart
├── api/
│   └── api_service.dart   # endpoint + function pengambilan data
├── models/
│   └── data.dart          # class Product + factory fromJson()
└── screens/
    ├── home.dart          # list produk
    └── detail.dart        # detail satu produk
```

## Cara Menjalankan

```bash
flutter pub get
flutter run
```

Jika folder platform (`android/`, `ios/`, dll.) belum ada, jalankan dulu `flutter create .` di folder project ini.

---

## Langkah Praktikum

### A. Membuat `api_service.dart` dan Function `get` Pertama

1. Struktur JSON dari `https://dummyjson.com/products`:

   ```json
   {
     "products": [
       { "id": 1, "title": "Mascara" },
       { "id": 2, "title": "Lipstick" }
     ]
   }
   ```

2. Tambahkan dependency `http` lewat `pubspec.yaml` atau terminal:

   ```bash
   flutter pub add http
   ```

   ```yaml
   dependencies:
     http: ^1.6.0
   ```

   Lalu jalankan `flutter pub get`.

3. Di folder `lib`, buat folder `api`, lalu buat file `api_service.dart` di dalamnya.

4. Simpan endpoint ke dalam variabel string:

   ```dart
   String apiUrl = 'https://dummyjson.com/products';
   ```

5. Buat function pertama `getProducts()`:

   ```dart
   import 'dart:convert';
   import 'package:http/http.dart' as http;

   String apiUrl = 'https://dummyjson.com/products';

   Future<List<dynamic>> getProducts() async {
     final response = await http.get(Uri.parse(apiUrl));
     if (response.statusCode == 200) {
       final data = jsonDecode(response.body);
       return data['products'];
     } else {
       throw Exception('Failed to load products');
     }
   }
   ```

### B. Mengambil Data Products

1. Buka `home.dart`, import `api_service.dart`, lalu refactor page menjadi **StatefulWidget**.
2. Di dalam `_HomePageState`, tambah dua variabel: `products` (menyimpan data dari API) dan `isLoading` (penanda sedang memuat).
3. Buat fungsi `fetchProducts()` untuk memanggil API dan memperbarui UI:

   ```dart
   class _HomePageState extends State<HomePage> {
     List<dynamic> products = [];
     bool isLoading = true;

     Future<void> fetchProducts() async {
       final productData = await getProducts();
       setState(() {
         products = productData;
         isLoading = false;
       });
     }
     // kodingan lain
   }
   ```

   Panggil di dalam `initState()` (dijalankan satu kali saat page dibuka), tepat di bawah `fetchProducts()`:

   ```dart
   @override
   void initState() {
     super.initState();
     fetchProducts();
   }
   ```

4. Tambahkan **error handling** dengan `try-catch`:

   ```dart
   Future<void> fetchProducts() async {
     try {
       final productData = await getProducts();
       setState(() {
         products = productData;
         isLoading = false;
       });
     } catch (e) {
       setState(() {
         isLoading = false;
       });
       print('Error: $e');
     }
   }
   ```

### C. Menampilkan Data API di UI

1. Di `home.dart`, bagian `body`:

   ```dart
   body: ListView.builder(
     itemCount: products.length,
     itemBuilder: (context, index) {
       final product = products[index];
       return ListTile(
         title: Text(product['title']),
         subtitle: Text('Rp ${product['price']}'),
         leading: Image.network(
           product['images'][0],
           width: 50,
           height: 50,
           fit: BoxFit.cover,
         ),
         trailing: Icon(Icons.arrow_forward_ios, color: Colors.black54),
       );
     },
   ),
   ```

2. Jalankan aplikasi dan pastikan list produk tampil.
3. Akan ada *delay* sebelum produk muncul. Itulah konsep **asynchronous**: waktu yang dibutuhkan untuk mengambil data dari API.
4. Tampilkan indikator loading dengan ternary operator pada `isLoading`:

   ```dart
   body: isLoading
       // Jika data belum dapat, tampilkan loading.
       ? const Center(child: CircularProgressIndicator())
       // Jika data sudah ada, tampilkan list
       : ListView.builder(
           // kodingan lainnya
         ),
   ```

### D. Data untuk Detail Page

Detail page hanya menerima **id produk**, lalu melakukan HTTP Request sendiri ke endpoint `/products/{id}`.

1. Di `api_service.dart`, tambahkan `getSingleProduct()`:

   ```dart
   Future<Map<String, dynamic>> getSingleProduct(int productId) async {
     final response = await http.get(Uri.parse('$apiUrl/$productId'));
     if (response.statusCode == 200) {
       final data = jsonDecode(response.body);
       return data;
     } else {
       throw Exception('Failed to load product details');
     }
   }
   ```

2. Di `detail.dart`, ubah menjadi **StatefulWidget** dan ganti parameter menjadi `productId`:

   ```dart
   class DetailPage extends StatefulWidget {
     final int productId;
     const DetailPage({super.key, required this.productId});

     @override
     State<DetailPage> createState() => _DetailPageState();
   }
   ```

3. Di `home.dart`, tambahkan `onTap` pada `ListTile` untuk mengirim id ke detail:

   ```dart
   onTap: () {
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => DetailPage(productId: product['id']),
       ),
     );
   },
   ```

4. Di `_DetailPageState`, buat variabel, fungsi fetch, dan panggil di `initState()`:

   ```dart
   Map<String, dynamic> product = {};
   bool isLoading = true;

   Future<void> fetchSingleProduct() async {
     final productData = await getSingleProduct(widget.productId);
     setState(() {
       product = productData;
       isLoading = false;
     });
   }

   @override
   void initState() {
     super.initState();
     fetchSingleProduct();
   }
   ```

5. Tanpa loading indicator, akan muncul red screen sesaat. Tambahkan `CircularProgressIndicator()` di `build()`:

   ```dart
   body: isLoading
       ? Center(child: CircularProgressIndicator())
       : SingleChildScrollView(
           // tampilan detail memakai product['title'], product['price'], dst.
         ),
   ```

6. Jalankan kembali. Jika data muncul dengan baik, item-list berhasil ditampilkan.

### E. Class dengan Static Method

Agar function API lebih rapi dan mudah dicari, kelompokkan dalam satu class dengan `static method`. Method dipanggil langsung lewat nama class tanpa membuat instance.

1. Ubah seluruh isi `api_service.dart`:

   ```dart
   import 'dart:convert';
   import 'package:http/http.dart' as http;

   class ApiService {
     static const String apiUrl = 'https://dummyjson.com/products';

     static Future<List<dynamic>> getProducts() async {
       final response = await http.get(Uri.parse(apiUrl));
       if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
         return data['products'];
       } else {
         throw Exception('Failed to load products');
       }
     }

     static Future<Map<String, dynamic>> getSingleProduct(int productId) async {
       final response = await http.get(Uri.parse('$apiUrl/$productId'));
       if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
         return data;
       } else {
         throw Exception('Failed to load product details');
       }
     }
   }
   ```

2. Ubah pemanggilan di home dan detail:

   ```dart
   // Di home.dart
   final productData = await ApiService.getProducts();

   // Di detail.dart
   final productData = await ApiService.getSingleProduct(widget.productId);
   ```

### F. Menggunakan Model pada Data Dinamis

Akses dengan `product['title']` rentan typo, tidak ada autocomplete, dan tidak ada pengecekan tipe data. Solusinya: gunakan **model**.

1. Di `models/data.dart`, buat class `Product`:

   ```dart
   class Product {
     final int id;
     final String title;
     final String description;
     final String category;
     final double price;
     final String image;

     Product({
       required this.id,
       required this.title,
       required this.description,
       required this.category,
       required this.price,
       required this.image,
     });
   }
   ```

2. Di `ApiService`, konversi Map ke `Product` secara manual (`getProducts()` kini me-return `List<Product>`, jangan lupa `import '../models/data.dart';`):

   ```dart
   static Future<List<Product>> getProducts() async {
     final response = await http.get(Uri.parse(apiUrl));
     if (response.statusCode == 200) {
       final data = jsonDecode(response.body);
       List rawList = data['products'];

       List<Product> productList = [];
       for (var item in rawList) {
         productList.add(
           Product(
             id: item['id'],
             title: item['title'],
             description: item['description'],
             category: item['category'],
             price: (item['price'] as num).toDouble(),
             image: item['images'][0],
           ),
         );
       }
       return productList;
     } else {
       throw Exception('Failed to load products');
     }
   }
   ```

3. Di `home.dart`, ganti tipe list:

   ```dart
   List<Product> products = [];
   ```

4. Ganti notasi key menjadi notasi dot (`product.title`, `product.price`, `product.image`, `product.id`).

### G. Factory Constructor

Logika konversi sebaiknya menjadi urusan class `Product`, bukan `ApiService`.

1. Tambahkan `factory Product.fromJson()` di class `Product`:

   ```dart
   factory Product.fromJson(Map<String, dynamic> json) {
     return Product(
       id: json['id'],
       title: json['title'],
       description: json['description'],
       category: json['category'],
       price: (json['price'] as num).toDouble(),
       image: json['images'][0],
     );
   }
   ```

2. `getProducts()` menjadi jauh lebih ringkas:

   ```dart
   List products = data['products'];
   return products.map((e) => Product.fromJson(e)).toList();
   ```

3. Update `getSingleProduct()` agar mengembalikan `Product`:

   ```dart
   static Future<Product> getSingleProduct(int productId) async {
     final response = await http.get(Uri.parse('$apiUrl/$productId'));
     if (response.statusCode == 200) {
       final data = jsonDecode(response.body);
       return Product.fromJson(data);
     } else {
       throw Exception('Failed to load product details');
     }
   }
   ```

4. Di `detail.dart`, ubah tipe variabel menjadi nullable:

   ```dart
   Product? product;
   ```

5. Gunakan dot notation dengan null-assertion operator (`!`), misalnya `product!.title`. Aman karena saat `product` masih `null`, UI menampilkan `CircularProgressIndicator()`.

6. Jalankan aplikasi.

---

## Catatan

- Kode di folder `lib/` adalah **hasil akhir** (setelah langkah G).
- `home.dart` dan `detail.dart` di project ini dibuat sederhana (tanpa bottom navigation "Beranda/Profil" dari Modul 4). Jika kamu memakai project Modul 4, cukup salin bagian yang berubah.
- Tugas praktikum (API Dattebayo) **tidak** dimasukkan ke project ini.
