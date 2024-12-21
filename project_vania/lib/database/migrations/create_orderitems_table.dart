import 'package:vania/vania.dart';

class CreateOrderitemsTable extends Migration {

  @override
  Future<void> up() async{
   super.up();
   await createTableNotExists('orderitems', () {
      string('order_item');
      primary('order_item');
      integer('order_num');
      string('prod_id', length: 10);
      integer('quantity');
      integer('size');
      timeStamps();
      foreign('order_num', 'orders', 'order_num', constrained: true, onDelete: 'CASCADE');
      foreign('prod_id', 'products', 'prod_id', constrained: true, onDelete: 'CASCADE');
    });
  }
  
  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('orderitems');
  }
}
