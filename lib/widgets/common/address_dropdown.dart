// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/boxes.dart';
import '../../models/index.dart' show Address, UserModel;
import '../../services/index.dart';

class AddressDropdown extends StatefulWidget {
  @override
  _AddressDropdownState createState() => _AddressDropdownState();
}

class _AddressDropdownState extends State<AddressDropdown> {
  List<Address?> listAddress = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    _getDataFromLocal();
    final loggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
    if (loggedIn) {
      await _getDataFromNetwork();
    }
    setState(() {
      isLoading = false;
    });
  }

  void _getDataFromLocal() {
    var list = List<Address>.from(UserBox().addresses);
    listAddress = list;
  }

  Future<void> _getDataFromNetwork() async {
    try {
      var user = await Services().api.getUserInfo(UserBox().userInfo!.cookie);
      var result = await Services().api.getCustomerInfo(user?.id);
      if (result?['billing'] != null) {
        listAddress.add(result?['billing']);
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator();
    }

    return DropdownButton<Address?>(
      value: listAddress.isNotEmpty ? listAddress[0] : null,
      items: _buildDropdownItems(),
      onChanged: (Address? newAddress) {
        if (newAddress == null) {
          _showAddAddressDialog();
        } else {
          // Handle address change logic here
        }
      },
      isExpanded: true,
    );
  }

  List<DropdownMenuItem<Address?>> _buildDropdownItems() {
    return [
      ...listAddress.map((Address? address) {
        return DropdownMenuItem<Address?>(
          value: address,
          child: Text(
            address!.toString(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ), // Format address display as needed
        );
      }).toList(),
      const DropdownMenuItem<Address?>(
        value: null,
        child: Text('Add New Address'),
      ),
    ];
  }

  void _showAddAddressDialog() {
    // Controllers for each field
    var firstNameController = TextEditingController();
    var lastNameController = TextEditingController();
    var emailController = TextEditingController();
    var streetController = TextEditingController();
    var apartmentController = TextEditingController();
    var blockController = TextEditingController();
    var cityController = TextEditingController();
    var stateController = TextEditingController();
    var countryController = TextEditingController();
    var phoneNumberController = TextEditingController();
    var zipCodeController = TextEditingController();
    var latitudeController = TextEditingController();
    var longitudeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Address'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(hintText: 'First Name'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(hintText: 'Last Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(hintText: 'Email'),
                ),
                TextField(
                  controller: streetController,
                  decoration: const InputDecoration(hintText: 'Street'),
                ),
                TextField(
                  controller: apartmentController,
                  decoration: const InputDecoration(hintText: 'Apartment'),
                ),
                TextField(
                  controller: blockController,
                  decoration: const InputDecoration(hintText: 'Block'),
                ),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(hintText: 'City'),
                ),
                TextField(
                  controller: stateController,
                  decoration: const InputDecoration(hintText: 'State'),
                ),
                TextField(
                  controller: countryController,
                  decoration: const InputDecoration(hintText: 'Country'),
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: const InputDecoration(hintText: 'Phone Number'),
                ),
                TextField(
                  controller: zipCodeController,
                  decoration: const InputDecoration(hintText: 'Zip Code'),
                ),
                TextField(
                  controller: latitudeController,
                  decoration: const InputDecoration(hintText: 'Latitude'),
                ),
                TextField(
                  controller: longitudeController,
                  decoration: const InputDecoration(hintText: 'Longitude'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                var newAddress = Address(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  email: emailController.text,
                  street: streetController.text,
                  apartment: apartmentController.text,
                  block: blockController.text,
                  city: cityController.text,
                  state: stateController.text,
                  country: countryController.text,
                  phoneNumber: phoneNumberController.text,
                  zipCode: zipCodeController.text,
                  latitude: latitudeController.text,
                  longitude: longitudeController.text,
                  mapUrl:
                      '', // Optional: you can generate this or leave it empty
                );

                _addNewAddress(newAddress);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addNewAddress(Address newAddress) {
    setState(() {
      listAddress.add(newAddress);
    });

    // Optionally, save the new address to local storage or server
  }
}
