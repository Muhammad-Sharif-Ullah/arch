import 'package:flutter/material.dart';

import 'country.dart';
import 'country_list.dart';

class CountryCodePicker extends StatefulWidget {
  final Function(Country?)? onChanged;
  final String initialSelection;
  final List<String> favorite;
  final bool showCountryOnly;
  final bool showOnlyCountryWhenClosed;
  final bool alignLeft;
  final TextStyle textStyle;

  const CountryCodePicker({
    super.key,
    this.onChanged,
    this.initialSelection = 'BD', // Default to Bangladesh
    this.favorite = const [],
    this.showCountryOnly = false,
    this.showOnlyCountryWhenClosed = false,
    this.alignLeft = false,
    required this.textStyle,
  });

  @override
  CountryCodePickerState createState() => CountryCodePickerState();
}

class CountryCodePickerState extends State<CountryCodePicker> {
  String selectedDialCode = '+880'; // Default to Bangladesh
  Country? selectedCountry;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
    selectedCountry = countryList.firstWhere(
      (country) => country.isoCode == widget.initialSelection,
      orElse: () => countryList.first,
    );
    selectedDialCode = selectedCountry!.dialCode;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCountry(BuildContext context) async {
    final Country? country = await showDialog<Country>(
      context: context,
      builder: (BuildContext context) {
        List<Country> filteredCountryList = countryList;
        if (_searchText.isNotEmpty) {
          filteredCountryList = countryList.where((Country country) {
            return country.name.toLowerCase().contains(
              _searchText.toLowerCase(),
            );
          }).toList();
        }
        return AlertDialog(
          title: const Text('Select Country', textAlign: TextAlign.center),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        filteredCountryList = countryList.where((
                          Country country,
                        ) {
                          return country.name.toLowerCase().contains(
                            _searchText.toLowerCase(),
                          );
                        }).toList();
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Search',

                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _searchController.clear();
                            filteredCountryList = countryList;
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: filteredCountryList.map((Country country) {
                          if (widget.showCountryOnly &&
                              !widget.favorite.contains(country.dialCode)) {
                            return Container(); // Skip if showing country only and not in favorites
                          }
                          return ListTile(
                            leading: Text(
                              country.flag,
                              style: const TextStyle(fontSize: 20),
                            ),
                            title: Text(country.name),
                            subtitle: Text(country.dialCode),
                            selected: selectedCountry == country,
                            trailing: selectedCountry == country
                                ? const Icon(Icons.check)
                                : null,
                            onTap: () {
                              Navigator.pop(context, country);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (country != null) {
      setState(() {
        selectedCountry = country;
        selectedDialCode = country.dialCode;
        widget.onChanged?.call(country); // Notify onChanged callback
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _selectCountry(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(shape: BoxShape.rectangle),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCountry!.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                // const SizedBox(width: 5),
                // const Icon(Icons.arrow_drop_down),
                const SizedBox(width: 5),
                Text(selectedDialCode, style: widget.textStyle),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

class PhoneNumberValidator {
  PhoneNumberValidator._();
  static final _instance = PhoneNumberValidator._();
  factory PhoneNumberValidator() => _instance;

  static String? validate(String? value, Country country) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != country.phoneLength) {
      return 'Invalid phone number';
    }
    return null;
  }

  static String? validateCountry(Country? country) {
    if (country == null) {
      return 'Country is required';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value, String isoCode) {
    final country = countryList.firstWhere(
      (country) => country.isoCode == isoCode,
      orElse: () => countryList.first,
    );
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != country.phoneLength) {
      return 'Invalid phone number';
    }
    return null;
  }

  // get length
  static int getLength(String isoCode) {
    final country = countryList.firstWhere(
      (country) => country.isoCode == isoCode,
      orElse: () => countryList.first,
    );
    return country.phoneLength;
  }
}
