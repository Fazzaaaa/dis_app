import 'package:dis_app/models/chart_model.dart';
import 'package:dis_app/pages/findme/checkout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dis_app/utils/constants/colors.dart';
import 'package:dis_app/blocs/chart/chart_bloc.dart';
import 'package:dis_app/blocs/chart/chart_event.dart';
import 'package:dis_app/blocs/chart/chart_state.dart';
import 'package:dis_app/common/widgets/chartPhotoItem.dart';

class ShoppingCartScreen extends StatelessWidget {
  static String? selectedImage;
  final NumberFormat currencyFormat = NumberFormat('#,###', 'id');

  // Constructor with parameter for selectedImage
  ShoppingCartScreen({String? image});

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("No Item Selected"),
          content:
              Text("Please select at least one product before proceeding."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartBloc()
        ..add(AddCartItem(
          CartItem(
            // Using CartItem instead of Cart
            title: selectedImage != null ? "New Photo" : "",
            photographer: selectedImage != null ? "Unknown" : "",
            price: 10000, // Default price, adjust as needed
            imagePath: selectedImage ?? '', // Add image path if available
          ),
        )),
      child: Scaffold(
        appBar: AppBar(
          title: Text("My Cart"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: DisColors.primary,
        ),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            final cartBloc = context.read<CartBloc>();
            return Column(
              children: [
                ListTile(
                  leading: Checkbox(
                    value: state.selectedItems.every((element) => element),
                    activeColor: DisColors.primary,
                    onChanged: (bool? value) {
                      cartBloc.add(SelectAllCartItems(value ?? false));
                    },
                  ),
                  title: Text(
                    "Select All",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  tileColor: Colors.white,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.cartItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10.0),
                        child: Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            alignment: Alignment.centerRight,
                            color: Colors.red,
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            cartBloc.add(RemoveCartItem(index));
                          },
                          child: DisCartPhotoItem(
                            imageAssetPath: state.cartItems[index].imagePath,
                            fileName: state.cartItems[index].title,
                            photographer: state.cartItems[index].photographer,
                            price: state.cartItems[index].price.toDouble(),
                            isChecked: state.selectedItems[index],
                            onCheckedChange: (bool? value) {
                              cartBloc
                                  .add(SelectCartItem(index, value ?? false));
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Price (${state.selectedItems.where((selected) => selected).length} Items)",
                        style: TextStyle(fontSize: 16),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: DisColors.primary),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "IDR ${currencyFormat.format(state.totalPrice)}",
                          style: TextStyle(
                            fontSize: 20,
                            color: DisColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: DisColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black54,
                      ),
                      onPressed: () {
                        if (state.selectedItems.contains(true)) {
                          List<CartItem> selectedCartItems = [];
                          for (int i = 0; i < state.cartItems.length; i++) {
                            if (state.selectedItems[i]) {
                              selectedCartItems.add(state.cartItems[i]);
                            }
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreen(
                                  selectedItems: selectedCartItems),
                            ),
                          );
                        } else {
                          _showWarningDialog(context);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Buy Now",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
