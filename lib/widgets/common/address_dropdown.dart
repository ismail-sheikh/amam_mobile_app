// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widgets/common/place_picker.dart';
import '../../common/config.dart';
import '../../data/boxes.dart';
import '../../models/index.dart' show Address, UserModel;
import '../../services/index.dart';

class AddressDropdown extends StatefulWidget {
  @override
  _AddressDropdownState createState() => _AddressDropdownState();
}

class _AddressDropdownState extends State<AddressDropdown> {
  List<Address?> listAddress = [];
  Address? selectedAddress; // Track the selected address
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
    setState(() {
      listAddress = list;
      selectedAddress = list.isNotEmpty ? list[0] : null; // Set initial value
    });
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
      value: selectedAddress,
      items: _buildDropdownItems(),
      onChanged: (Address? newAddress) {
        setState(() {
          selectedAddress = newAddress; // Update selected address
        });
        if (newAddress == null) {
          _showAddAddressDialog();
        } else {
          // Handle address change logic here
          print('Selected Address: ${newAddress.street}, ${newAddress.city}');
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
          title: const Text('Select Address'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: () async {
                    // Navigate to the place picker widget
                    final location = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlacePicker(
                            kGoogleApiKey.web), // Use your place picker here
                      ),
                    );
                    // Check if a location was selected
                    if (location != null) {
                      // Fill in the address fields using the selected location data
                      streetController.text = location.street ?? '';
                      cityController.text = location.city ?? '';
                      stateController.text = location.state ?? '';
                      countryController.text = location.country ?? '';
                      zipCodeController.text = location.zip ?? '';
                      if (location.latLng != null) {
                        latitudeController.text =
                            location.latLng!.latitude.toString();
                        longitudeController.text =
                            location.latLng!.longitude.toString();
                      }
                    }
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text('Use Current Location'),
                ),
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
                  mapUrl: latitudeController.text.isNotEmpty &&
                          longitudeController.text.isNotEmpty
                      ? 'https://maps.google.com/maps?q=${latitudeController.text},${longitudeController.text}&output=embed'
                      : null,
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
