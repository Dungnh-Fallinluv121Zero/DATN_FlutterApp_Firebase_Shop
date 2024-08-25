import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/provider/auth_provider.dart';
import 'package:untitled/views/user/address/addnew_address_page.dart';
import 'package:untitled/model/address_model.dart';

class AddressItem extends StatelessWidget {
  final AddressModel address;
  final bool selectedAddress;
  final Function(bool) onSelected;
  final VoidCallback onUpdate;

  const AddressItem({
    required this.address,
    required this.selectedAddress,
    required this.onSelected,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!selectedAddress),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: selectedAddress ? Colors.blue[100] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${address.name}'),
                    Text('Phone: ${address.phone}'),
                    Text('Address: ${address.address}'),
                  ],
                ),
              ),
              Visibility(
                visible: selectedAddress,
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.redAccent),
                      onPressed: () async {
                        final userId =
                            Provider.of<AuthProvider>(context, listen: false)
                                .userId;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddNewAddressPage(
                              address: address,
                              userId: userId,
                            ),
                          ),
                        );
                      
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () {
                        // Chức năng xác nhận ở đây
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
