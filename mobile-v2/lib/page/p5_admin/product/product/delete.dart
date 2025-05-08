import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/page/p5_admin/product/product/service.dart';

void deleteProduct(int id,Function onDelete) async {
    final Service service = Service();

    try {
      await service.delete(id);
      onDelete();
      UI.toast(text: 'Success');
    } catch (error) {
      print("Failed to delete product: $error");
      UI.toast(text: 'Error deleting product');
    }
  }