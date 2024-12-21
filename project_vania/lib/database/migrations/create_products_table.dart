import 'package:vania/vania.dart';

class CreateProductTable extends Migration {

  @override
  Future<void> up() async {
    super.up();

    await createTableNotExists('products', () {
      string('prod_id');
      primary('prod_id');
      string('vend_id', length: 5);
      string('prod_name', length: 25);
      float('prod_price', precision: 10, scale: 2);
      text('prod_desc');
      timeStamps();
      foreign('vend_id', 'vendors', 'vend_id', constrained: true, onDelete: 'CASCADE');
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('products');
  }
}
