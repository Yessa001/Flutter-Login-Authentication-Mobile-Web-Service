import 'package:vania/vania.dart';
import 'package:project_vania/app/models/order_item.dart';
import 'package:vania/src/exception/validation_exception.dart';

class OrderItemController extends Controller {
  // Mendapatkan semua item pesanan
  Future<Response> index() async {
    final orderItems = await OrderItem().query().get();
    return Response.json({'data': orderItems});
  }

  // Menambahkan item pesanan baru
  Future<Response> store(Request request) async {
    try {
      // Validasi input
      request.validate({
        'order_item': 'required|string|length:10',
        'order_num': 'required|numeric',
        'prod_id': 'required|string|length:10',
        'quantity': 'required|numeric',
        'size': 'required|numeric',
      });

      final orderItemData = request.input();
      orderItemData['created_at'] = DateTime.now().toIso8601String();

      // Cek apakah vendor dengan ID sudah ada
      final existingOrderItem = await OrderItem()
          .query()
          .where('order_item', '=', orderItemData['order_item'])
          .first();

      if (existingOrderItem != null) {
        return Response.json(
          {'message': 'Order Item dengan ID ini sudah ada.'},
          409,
        );
      }

      // Simpan item pesanan ke database
      await OrderItem().query().insert(orderItemData);

      return Response.json({'message': 'Item pesanan berhasil ditambahkan.', 'data': orderItemData,
      }, 201);
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, 400);
      } else {
        return Response.json({'message': 'Terjadi kesalahan di sisi server.'}, 500);
      }
    }
  }

  // Mendapatkan detail item pesanan berdasarkan ID
  Future<Response> show(String id) async {
    final orderItem = await OrderItem().query().where('order_item', '=', id).first();

    if (orderItem == null) {
      return Response.json({'message': 'Item pesanan tidak ditemukan.'}, 404);
    }

    return Response.json({'data': orderItem});
  }

  // Memperbarui data item pesanan
  Future<Response> update(Request request, String id) async {
    try {
      // Validasi input
      request.validate({
        'order_num': 'required|numeric',
        'prod_id': 'required|string|length:10',
        'quantity': 'required|numeric',
        'size': 'required|numeric',
      });

      final orderItemData = request.input();
      orderItemData['uptade_at'] = DateTime.now().toIso8601String();

      // Log imput data 
      print('Imput data: $orderItemData');

      // Periksa apakah ID yang diberikan sudah ada
      final orderIt = await OrderItem().query().where('order_item', '=', id).first();

      if (orderIt == null) {
        return Response.json({'message': 'Item pesanan tidak ditemukan.'}, 404);
      }

      // Update data order item 
      final updatedRows = await OrderItem().query().where('order_item', '=', id)
      .update({
        'order_num': orderItemData['order_num'],
        'prod_id': orderItemData['prod_id'],
        'quantity': orderItemData['quantity'],
        'size': orderItemData['size'],
        'updated_at': orderItemData['updated_at'],
      });

      // Log jumlah baris yang diperbarui
      print('Rows updated: $updatedRows');

      return Response.json({
        'message': 'Item pesanan berhasil diperbarui.',
        'data': orderItemData,
        }, 200);
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, 400);
      } else {
        return Response.json({'message': 'Terjadi kesalahan di sisi server.'}, 500);
      }
    }
  }

  // Menghapus item pesanan
  Future<Response> destroy(String id) async {
    final deleted = await OrderItem().query().where('order_item', '=', id).delete();

    if (deleted == 0) {
      return Response.json({'message': 'Item pesanan tidak ditemukan.'}, 404);
    }

    return Response.json({'message': 'Item pesanan berhasil dihapus.'});
  }
}

final OrderItemController orderItemController = OrderItemController();
