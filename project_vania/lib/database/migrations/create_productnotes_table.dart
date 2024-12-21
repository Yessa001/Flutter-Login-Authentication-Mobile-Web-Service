import 'package:vania/vania.dart';

class CreateProductnotesTable extends Migration {

  @override
  Future<void> up() async{
   super.up();
   await createTableNotExists('productnotes', () {
      string('note_id');
      primary('note_id');
      string('prod_id', length: 10);
      date('note_date');
      text('note_text');
      timeStamps();
      foreign('prod_id', 'products', 'prod_id', constrained: true, onDelete: 'CASCADE');
    });
  }
  
  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('productnotes');
  }
}
