import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GoldPriceScreen extends StatefulWidget {
  const GoldPriceScreen({super.key});

  @override
  _GoldPriceScreenState createState() => _GoldPriceScreenState();
}

class _GoldPriceScreenState extends State<GoldPriceScreen> {
  final TextEditingController _hallmarkController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _makingChargesController =
      TextEditingController();

  double? goldPricePerGram;
  double? finalPrice;
  double? convertedKarat;
  double? goldValue;
  String lastUpdated = "Fetching...";
  String calculationBreakdown = "";

  final String apiKey = "goldapi-5anx90sm7ix7cis-io";
  final String apiUrl = "https://www.goldapi.io/api/XAU/INR";

  final Map<int, double> hallmarkToKarat = {
    999: 24,
    995: 23.88,
    990: 23,
    917: 22,
    916: 22,
    833: 20,
    750: 18,
    625: 15,
    585: 14,
    583: 14,
    575: 14,
    417: 10,
    375: 9,
    333: 8,
  };

  Future<void> fetchGoldPrice() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"x-access-token": apiKey, "Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double goldRatePerGram = data['price_gram_24k'];
        setState(() {
          goldPricePerGram = goldRatePerGram;
          lastUpdated = DateTime.now().toString();
        });
      } else {
        throw Exception("Failed to fetch gold prices");
      }
    } catch (e) {
      setState(() {
        lastUpdated = "Error fetching data";
      });
    }
  }

  void calculateGoldPrice() {
    if (goldPricePerGram == null) {
      fetchGoldPrice();
      return;
    }

    int hallmark = int.tryParse(_hallmarkController.text) ?? 999;
    double weight = double.tryParse(_weightController.text) ?? 0;
    double makingCharges = double.tryParse(_makingChargesController.text) ?? 0;

    if (!hallmarkToKarat.containsKey(hallmark)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Enter a valid hallmark number (e.g., 999, 916, 750)"),
      ));
      return;
    }

    double purityFactor = hallmarkToKarat[hallmark]! / 24;
    goldValue = goldPricePerGram! * purityFactor * weight;
    finalPrice = goldValue! + makingCharges;

    setState(() {
      convertedKarat = hallmarkToKarat[hallmark];
      calculationBreakdown =
          "Gold Rate per gram: ₹${goldPricePerGram!.toStringAsFixed(2)}\n"
          "Entered Hallmark: $hallmark (${convertedKarat!.toStringAsFixed(2)}K)\n"
          "Purity Factor: ${purityFactor.toStringAsFixed(4)}\n"
          "Weight: ${weight.toStringAsFixed(2)}g\n"
          "Gold Value: ₹${goldValue!.toStringAsFixed(2)}\n"
          "Making Charges: ₹${makingCharges.toStringAsFixed(2)}\n"
          "Final Price: ₹${finalPrice!.toStringAsFixed(2)}";
    });
  }

  @override
  void initState() {
    super.initState();
    fetchGoldPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gold Price Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                "Live Gold Price: ₹${goldPricePerGram?.toStringAsFixed(2) ?? 'Loading...'} /gram"),
            Text("Last Updated: $lastUpdated",
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: _hallmarkController,
              decoration: const InputDecoration(
                  labelText: "Enter Hallmark Number (e.g., 999, 916, 750)",
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                  labelText: "Enter Weight (grams)",
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _makingChargesController,
              decoration: const InputDecoration(
                  labelText: "Enter Making Charges (₹)",
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateGoldPrice,
              child: const Text("Calculate Price"),
            ),
            const SizedBox(height: 20),
            if (finalPrice != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Estimated Price: ₹${finalPrice!.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber),
                  ),
                  const SizedBox(height: 10),
                  Text(calculationBreakdown,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber[100],
                      )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
