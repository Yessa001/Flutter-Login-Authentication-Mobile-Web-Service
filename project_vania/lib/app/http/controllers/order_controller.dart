import 'package:project_vania/app/models/customer.dart';
import 'package:vania/vania.dart';
import 'package:project_vania/app/models/order.dart';
import 'package:vania/src/exception/validation_exception.dart';

class OrderController extends Controller {
  // Menampilkan semua order
  Future<Response> index() async {
    final orders = await Order().query().get();
    return Response.json({'data': orders});
  }

  // Menambahkan order baru
  Future<Response> store(Request request) async {
    try {
      // Validasi input
      request.validate({
        'order_num': 'required|integer',
        'order_date': 'required|date',
        'cust_id': 'required|string|max_length:5',
      });

      final orderData = request.input();
      orderData['created_at'] = DateTime.now().toIso8601String();

      // Periksa apakah cust_id ada di tabel pelanggan
      final customer = await Customer()
          .query()
          .where('cust_id', '=', orderData['cust_id'])
          .first();

      if (customer == null) {
        return Response.json(
            {'message': 'cust_id tidak ditemukan di tabel pelanggan.'}, 400);
      }

      // Menyimpan order ke database
      await Order().query().insert(orderData);

      return Response.json(
        {'message': 'Order berhasil ditambahkan.', 'data': orderData},
        201,
      );
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, 400);
      } else {
        print('Unexpected error: $e');
        return Response.json(
            {'message': 'Terjadi kesalahan di sisi server.'}, 500);
      }
    }
  }

  // Mendapatkan detail order berdasarkan ID
  Future<Response> show(int orderNum) async {
    final order =
        await Order().query().where('order_num', '=', orderNum).first();

    if (order == null) {
      return Response.json({'message': 'Order tidak ditemukan.'}, 404);
    }

    return Response.json({'data': order});
  }

  // Memperbarui data order
  Future<Response> update(Request request, int orderNum) async {
    try {
      // Validasi input
      request.validate({
        'order_date': 'required|date',
        'cust_id': 'required|string|max_length:5',
      });

      final orderData = request.input();
      orderData['updated_at'] = DateTime.now().toIso8601String();

      // Periksa apakah cust_id ada di tabel pelanggan
      final customer = await Customer()
          .query()
          .where('cust_id', '=', orderData['cust_id'])
          .first();

      if (customer == null) {
        return Response.json(
            {'message': 'cust_id tidak ditemukan di tabel pelanggan.'}, 400);
      }

      // Log jumlah baris yang diperbarui
      print('Input data: $orderData');

      // Periksa apakah ID yang diberikan sudah ada
      final order =
          await Order().query().where('order_num', '=', orderNum).first();

      if (order == null) {
        return Response.json({'message': 'Order tidak ditemukan.'}, 404);
      }

      // Update data customer
      final updateRows =
          await Order().query().where('order_num', '=', orderNum).update({
        'order_date': orderData['order_date'],
        'cust_id': orderData['cust_id'],
        'updated_at': orderData['updated_at'],
      });

      // Log jumlah baris yang diperbarui
      print("Rows Update: $updateRows");

      return Response.json({
        'message': 'Order berhasil diperbarui.',
        'data': orderData,
      }, 200);
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, 400);
      } else {
        return Response.json(
            {'message': 'Terjadi kesalahan di sisi server.'}, 500);
      }
    }
  }

  // Menghapus order
  Future<Response> destroy(int orderNum) async {
    final deleted =
        await Order().query().where('order_num', '=', orderNum).delete();

    if (deleted == 0) {
      return Response.json({'message': 'Order tidak ditemukan.'}, 404);
    }

    return Response.json({'message': 'Order berhasil dihapus.'});
  }
}

final OrderController orderController = OrderController();
