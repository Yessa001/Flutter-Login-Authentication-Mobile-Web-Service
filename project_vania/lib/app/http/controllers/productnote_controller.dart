import 'package:vania/vania.dart';
import 'package:project_vania/app/models/product_note.dart';
import 'package:vania/src/exception/validation_exception.dart';

class ProductNoteController extends Controller {
  // Menampilkan semua catatan produk
  Future<Response> index() async {
    final productNotes = await ProductNote().query().get();
    return Response.json({'data': productNotes});
  }

  // Menambahkan catatan produk baru
  Future<Response> store(Request request) async {
    try {
      // Validasi input
      request.validate({
        'note_id': 'required|string|length:255',
        'prod_id': 'required|string|length:10',
        'note_date': 'required|date',
        'note_text': 'required|text',
      });

      final noteData = request.input();

      // Cek apakah note_id yang sama sudah ada
      final existingProduct = await ProductNote()
          .query()
          .where('note_id', '=', noteData['note_id'])
          .first();

      if (existingProduct != null) {
        return Response.json(
          {'message': 'Produk dengan nama ini sudah ada.'},
          409,
        );
      }

      // Tambahkan waktu pembuatan
      noteData['created_at'] = DateTime.now().toIso8601String();

      // Simpan catatan ke database
      await ProductNote().query().insert(noteData);

      return Response.json(
        {
          'message': 'Catatan produk berhasil ditambahkan.',
          'data': noteData,
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

  // Mendapatkan detail catatan produk berdasarkan ID
  Future<Response> show(String id) async {
    final note = await ProductNote().query().where('note_id', '=', id).first();

    if (note == null) {
      return Response.json({'message': 'Catatan produk tidak ditemukan.'}, 404);
    }

    return Response.json({'data': note});
  }

  // Memperbarui data catatan produk
  Future<Response> update(Request request, String id) async {
    try {
      // Validasi input
      request.validate({
        'prod_id': 'required|string|length:10',
        'note_date': 'required|date',
        'note_text': 'required|text',
      });

      final noteData = request.input();
      noteData['updated_at'] = DateTime.now().toIso8601String();

      // Log input data
      print('Input data: $noteData');
      
      // Periksa ID catatan produk 
      final notes = await ProductNote().query().where('note_id', '=', id).first();

      if (notes == null) {
        return Response.json({'message': 'Catatan produk dengan ID tersebut tidak ditemukan.'}, 404);
      }

      // Update data catatan produk
      final updatedRows = await ProductNote().query().where('note_id', '=', id)
      .update({
        'prod_id': noteData['prod_id'],
        'note_date': noteData['note_date'],
        'note_text': noteData['note_text'],
        'updated_at': noteData['updated_at'],
      });

      // Log jumlah baris yang diperbarui
      print('Rows updated: $updatedRows');

      return Response.json({
        'message': 'Catatan produk berhasil diperbarui.',
        'data': noteData,
        }, 200);
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, 400);
      } else {
        return Response.json({'message': 'Terjadi kesalahan di sisi server.'}, 500);
      }
    }
  }

  // Menghapus catatan produk
  Future<Response> destroy(String id) async {
    final deleted = await ProductNote().query().where('note_id', '=', id).delete();

    if (deleted == 0) {
      return Response.json({'message': 'Catatan produk tidak ditemukan.'}, 404);
    }

    return Response.json({'message': 'Catatan produk berhasil dihapus.'});
  }
}

final ProductNoteController productNoteController = ProductNoteController();
