import 'package:project_vania/app/http/middleware/authenticate.dart';
import 'package:vania/vania.dart';
import 'package:project_vania/app/http/controllers/auth_controller.dart';
import 'package:project_vania/app/http/controllers/product_controller.dart';
import 'package:project_vania/app/http/controllers/vendor_controller.dart';
import 'package:project_vania/app/http/controllers/order_controller.dart';
import 'package:project_vania/app/http/controllers/customer_controller.dart';
import 'package:project_vania/app/http/controllers/orderitem_controller.dart';
import 'package:project_vania/app/http/controllers/productnote_controller.dart';

class ApiRoute implements Route {
  @override
  void register() {
    // Routes for AuthController
    Router.group(() {
      Router.post('register', authController.register);
      Router.post('login', authController.login);
    }, prefix: 'auth');

    Router.get('me', authController.me).middleware([AuthenticateMiddleware()]);

    // Routes for ProductController
    Router.post('/create-product', productController.store);
    Router.get('/products', productController.index);
    Router.get('/product/{id}', productController.show);
    Router.put('/product/{id}', productController.update);
    Router.delete('/product/{id}', productController.destroy);

    // Routes for VendorController
    Router.post('/create-vendor', vendorController.store);
    Router.get('/vendors', vendorController.index);
    Router.get('/vendor/{id}', vendorController.show);
    Router.put('/vendor/{id}', vendorController.update);
    Router.delete('/vendor/{id}', vendorController.destroy);

    // Routes for CustomerController
    Router.post('/create-customer', customerController.store);
    Router.get('/customers', customerController.index);       
    Router.get('/customer/{id}', customerController.show);      
    Router.put('/customer/{id}', customerController.update);      
    Router.delete('/customer/{id}', customerController.destroy); 

    // Routes for OrderController
    Router.post('/create-order', orderController.store);
    Router.get('/orders', orderController.index);
    Router.get('/order/{id}', orderController.show);
    Router.put('/order/{id}', orderController.update);
    Router.delete('/order/{id}', orderController.destroy);

    // Routes for OrderItemController
    Router.post('/create-order-item', orderItemController.store);
    Router.get('/order-items', orderItemController.index);
    Router.get('/order-item/{id}', orderItemController.show);
    Router.put('/order-item/{id}', orderItemController.update);
    Router.delete('/order-item/{id}', orderItemController.destroy);

    // Routes for ProductNoteController
    Router.post('/create-product-note', productNoteController.store);
    Router.get('/product-notes', productNoteController.index);
    Router.get('/product-note/{id}', productNoteController.show);
    Router.put('/product-note/{id}', productNoteController.update);
    Router.delete('/product-note/{id}', productNoteController.destroy);
  }
}
