import 'package:vania/vania.dart';
import 'package:project_vania/app/models/product.dart';
import 'package:vania/src/exception/validation_exception.dart';

class ProductController extends Controller {
  // Mendapatkan semua produk
  Future<Response> index() async {
    final products = await Product().query().get();
    return Response.json({'data': products});
  }

  // Menambahkan produk baru
  Future<Response> store(Request request) async {
    try {
      // Validasi input
      request.validate({
        'prod_id': 'required|string|length:10',
        'vend_id': 'required|string|length:5',
        'prod_name': 'required|string|max_length:25',
        'prod_price': 'required|numeric|min:0',
        'prod_desc': 'required|text',
      });

      final productData = request.input();

      // Cek apakah produk dengan nama yang sama sudah ada
      final existingProduct = await Product()
          .query()
          .where('prod_name', '=', productData['prod_name'])
          .first();

      if (existingProduct != null) {
        return Response.json(
          {'message': 'Produk dengan nama ini sudah ada.'},
          409,
        );
      }

      // Tambahkan waktu pembuatan
      productData['created_at'] = DateTime.now().toIso8601String();

      // Simpan ke database
      await Product().query().insert(productData);

      return Response.json(
        {
          'message': 'Produk berhasil ditambahkan.',
          'data': productData,
        },
        201,
      );
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, 400);
      } else {
        return Response.json({'message': 'Terjadi kesalahan di sisi server.'}, 500);
      }
    }
  }

  // Mendapatkan detail produk berdasarkan ID
  Future<Response> show(String id) async {
    final product = await Product().query().where('prod_id', '=', id).first();

    if (product == null) {
      return Response.json({'message': 'Produk tidak ditemukan.'}, 404);
    }

    return Response.json({'data': product});
  }

  // Memperbarui data produk
  Future<Response> update(Request request, String id) async {
    try {
      // Validasi input
      request.validate({
        'vend_id': 'required|string|length:5',
        'prod_name': 'required|string|max_length:25',
        'prod_price': 'required|numeric|min:0',
        'prod_desc': 'required|text',
      });

      final productData = request.input();
      productData['updated_at'] = DateTime.now().toIso8601String();

      // Log input data
      print('input data: $productData');

      // Periksa ID produk
      final product = await Product().query().where('prod_id', '=', id).first();

      if (product == null) {
        return Response.json({'message': 'Produk dengan ID tersebut tidak ditemukan.'}, 404);
      }

      // Update data produk
      final updatedRows = await Product().query().where('prod_id', '=', id)
      .update({
        'vend_id': productData['vend_id'],
        'prod_name': productData['prod_name'],
        'prod_price': productData['prod_price'],
        'prod_desc': productData['prod_desc'],
        'updated_at': productData['updated_at'],
      });

      // Log jumlah baris yang diperbarui
      print('Rows updated: $updatedRows');

      return Response.json({
        'message': 'Produk berhasil diperbarui.',
        'data': productData,
        }, 200);
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, 400);
      } else {
        return Response.json({'message': 'Terjadi kesalahan di sisi server.'}, 500);
      }
    }
  }

  // Menghapus produk
  Future<Response> destroy(String id) async {
    final deleted = await Product().query().where('prod_id', '=', id).delete();

    if (deleted == 0) {
      return Response.json({'message': 'Produk tidak ditemukan.'}, 404);
    }

    return Response.json({'message': 'Produk berhasil dihapus.'});
  }
}

final ProductController productController = ProductController();
