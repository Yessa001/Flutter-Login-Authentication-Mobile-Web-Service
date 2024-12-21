import 'package:vania/vania.dart';
import 'package:project_vania/app/models/vendor.dart';
import 'package:vania/src/exception/validation_exception.dart';

class VendorController extends Controller {
  // Menampilkan semua vendor
  Future<Response> index() async {
    final vendors = await Vendor().query().get();
    return Response.json({'data': vendors});
  }

  // Menambahkan vendor baru
  Future<Response> store(Request request) async {
    try {
      // Validasi input
      request.validate({
        'vend_id': 'required|string|max_length:5',
        'vend_name': 'required|string|max_length:50',
        'vend_address': 'required|string',
        'vend_city': 'required|string|max_length:50',
        'vend_state': 'required|string|max_length:25',
        'vend_zip': 'required|string|max_length:7',
        'vend_country': 'required|string|max_length:25',
      });

      final vendorData = request.input();
      vendorData['created_at'] = DateTime.now().toIso8601String();

      // Cek apakah vendor dengan ID sudah ada
      final existingVendor = await Vendor()
          .query()
          .where('vend_id', '=', vendorData['vend_id'])
          .first();

      if (existingVendor != null) {
        return Response.json(
          {'message': 'Vendor dengan ID ini sudah ada.'},
          409,
        );
      }

      // Menyimpan data vendor ke database
      await Vendor().query().insert(vendorData);

      return Response.json(
        {'message': 'Vendor berhasil ditambahkan.', 'data': vendorData},
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

  // Mendapatkan detail vendor berdasarkan ID
  Future<Response> show(String id) async {
    final vendor = await Vendor().query().where('vend_id', '=', id).first();

    if (vendor == null) {
      return Response.json({'message': 'Vendor tidak ditemukan.'}, 404);
    }

    return Response.json({'data': vendor});
  }

  // Memperbarui data vendor
  Future<Response> update(Request request, String id) async {
    try {
      // Validasi input
      request.validate({
        'vend_name': 'string|max_length:50',
        'vend_address': 'string',
        'vend_city': 'string|max_length:50',
        'vend_state': 'string|max_length:25',
        'vend_zip': 'string|max_length:7',
        'vend_country': 'string|max_length:25',
      });

      final vendorData = request.input();
      vendorData['updated_at'] = DateTime.now().toIso8601String();

      // Log input data
      print("Imput data: $vendorData");

      // Periksa apakah ID yang diberikan sudah ada
      final vendor = await Vendor().query().where('vend_id', '=', id).first();

      if (vendor == null) {
        return Response.json({'message': 'Vendor tidak ditemukan.'}, 404);
      }

      // Update data vendor
      final updatedRows = await Vendor().query().where('vend_id', '=', id)
      .update({
        'vend_name': vendorData['vend_name'],
        'vend_address': vendorData['vend_address'],
        'vend_city': vendorData['vend_city'],
        'vend_state': vendorData['vend_state'],
        'vend_zip': vendorData['vend_zip'],
        'vend_country': vendorData['vend_country'],
        'updated_at': vendorData['updated_at'],
      });

      // Log jumlah baris yang diperbarui
      print('Rows updated: $updatedRows');

      return Response.json({
        'message': 'Vendor berhasil diperbarui.',
        'data': vendorData,
        }, 200);
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, 400);
      } else {
        return Response.json({'message': 'Terjadi kesalahan di sisi server.'}, 500);
      }
    }
  }

  // Menghapus vendor
  Future<Response> destroy(String id) async {
    final deleted = await Vendor().query().where('vend_id', '=', id).delete();

    if (deleted == 0) {
      return Response.json({'message': 'Vendor tidak ditemukan.'}, 404);
    }

    return Response.json({'message': 'Vendor berhasil dihapus.'});
  }
}

final VendorController vendorController = VendorController();
