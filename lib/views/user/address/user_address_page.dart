import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/model/address_model.dart';
import 'package:untitled/provider/address_provider.dart';
import 'package:untitled/views/user/address/addnew_address_page.dart';
import 'package:untitled/widgets/address_items.dart';

class UserAddressPage extends StatefulWidget {
  final String userId;

  const UserAddressPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserAddressPageState createState() => _UserAddressPageState();
}

class _UserAddressPageState extends State<UserAddressPage> {
  late Future<void> _loadAddressesFuture;

  @override
  void initState() {
    super.initState();
    _loadAddressesFuture = Provider.of<AddressProvider>(context, listen: false)
        .init(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Addresses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder(
        future: _loadAddressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Consumer<AddressProvider>(
              builder: (context, addressProvider, child) {
                if (addressProvider.addresses.isEmpty) {
                  return const Center(
                    child: Text('No addresses found'),
                  );
                }

                return ListView.builder(
                  itemCount: addressProvider.addresses.length,
                  itemBuilder: (context, index) {
                    AddressModel address = addressProvider.addresses[index];
                    return AddressItem(
                      address: address,
                      selectedAddress:
                          addressProvider.selectedAddressIndex == index,
                      onSelected: (isSelected) {
                        addressProvider.selectAddress(index, isSelected);
                      },
                      onUpdate: () {
                        // Gọi hàm cập nhật lại dữ liệu ở đây
                      },
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewAddressPage(
                userId: widget.userId,
              ),
            ),
          );
          if (result == true) {
            // Cập nhật lại dữ liệu nếu địa chỉ đã được thêm mới
            Provider.of<AddressProvider>(context, listen: false)
                .init(widget.userId);
            setState(() {
              _loadAddressesFuture =
                  Provider.of<AddressProvider>(context, listen: false)
                      .init(widget.userId);
            });
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
