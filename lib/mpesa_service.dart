import 'dart:convert';
import 'package:http/http.dart' as http;

class MpesaService {
  // Your Daraja API credentials
  static const String consumerKey = '8iWpTcqKxtct71LnWn3w72O1SeauYjzGJvzNrnoNoMDP38GX';
  static const String consumerSecret = '9nVkZ3YqK4G5MEhw7nKqKaugA2Py75uprNRMmWq4ybZDTwBGAGx3kRwXrvg2A6yF';
  static const String shortcode = '174379';
  static const String passkey = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';
  
  // Daraja API URLs (Sandbox)
  static const String baseUrl = 'https://sandbox.safaricom.co.ke';
  static const String authUrl = '$baseUrl/oauth/v1/generate?grant_type=client_credentials';
  static const String stkPushUrl = '$baseUrl/mpesa/stkpush/v1/processrequest';

  // Get access token from Daraja
  static Future<String?> getAccessToken() async {
    try {
      final credentials = base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
      
      final response = await http.get(
        Uri.parse(authUrl),
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      } else {
        print('Auth error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Auth exception: $e');
      return null;
    }
  }

  // Initiate STK Push (M-Pesa prompt on phone)
  static Future<Map<String, dynamic>> stkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    String transactionDesc = 'Payment',
  }) async {
    try {
      // Get access token first
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        return {
          'success': false,
          'message': 'Failed to authenticate with M-Pesa',
        };
      }

      // Format phone number (remove + and spaces)
      String formattedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '254${formattedPhone.substring(1)}';
      }
      if (!formattedPhone.startsWith('254')) {
        formattedPhone = '254$formattedPhone';
      }

      // Generate timestamp
      final timestamp = DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '').substring(0, 14);
      
      // Generate password
      final password = base64Encode(utf8.encode('$shortcode$passkey$timestamp'));

      // Prepare request body
      final requestBody = {
        'BusinessShortCode': shortcode,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount.toInt().toString(),
        'PartyA': formattedPhone,
        'PartyB': shortcode,
        'PhoneNumber': formattedPhone,
        'CallBackURL': 'https://mydomain.com/callback', // You'll need a real callback URL later
        'AccountReference': accountReference,
        'TransactionDesc': transactionDesc,
      };

      print('Sending STK Push to: $formattedPhone');
      print('Amount: $amount');

      final response = await http.post(
        Uri.parse(stkPushUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('STK Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['ResponseCode'] == '0') {
          return {
            'success': true,
            'message': 'STK push sent! Check your phone.',
            'checkoutRequestId': data['CheckoutRequestID'],
            'merchantRequestId': data['MerchantRequestID'],
          };
        } else {
          return {
            'success': false,
            'message': data['ResponseDescription'] ?? 'STK push failed',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to send STK push: ${response.body}',
        };
      }
    } catch (e) {
      print('STK Push exception: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
  // Pay to Paybill (for KPLC, Water, etc)
static Future<Map<String, dynamic>> payBill({
  required String phoneNumber,
  required double amount,
  required String paybillNumber,
  required String accountNumber,
  String transactionDesc = 'Bill Payment',
}) async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      return {'success': false, 'message': 'Failed to authenticate'};
    }

    String formattedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '254${formattedPhone.substring(1)}';
    }
    if (!formattedPhone.startsWith('254')) {
      formattedPhone = '254$formattedPhone';
    }

    final timestamp = DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '').substring(0, 14);
    final password = base64Encode(utf8.encode('$shortcode$passkey$timestamp'));

    final requestBody = {
      'BusinessShortCode': shortcode,
      'Password': password,
      'Timestamp': timestamp,
      'TransactionType': 'CustomerPayBillOnline',
      'Amount': amount.toInt().toString(),
      'PartyA': formattedPhone,
      'PartyB': paybillNumber,
      'PhoneNumber': formattedPhone,
      'CallBackURL': 'https://mydomain.com/callback',
      'AccountReference': accountNumber,
      'TransactionDesc': transactionDesc,
    };

    final response = await http.post(
      Uri.parse(stkPushUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['ResponseCode'] == '0') {
        return {'success': true, 'message': 'Payment sent! Check your phone.'};
      } else {
        return {'success': false, 'message': data['ResponseDescription'] ?? 'Payment failed'};
      }
    } else {
      return {'success': false, 'message': 'Failed to send payment'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Error: $e'};
  }
}

// Buy Airtime
static Future<Map<String, dynamic>> buyAirtime({
  required String phoneNumber,
  required double amount,
}) async {
  // For airtime, we use the same STK push but with different description
  return await stkPush(
    phoneNumber: phoneNumber,
    amount: amount,
    accountReference: 'Airtime',
    transactionDesc: 'Airtime Purchase',
  );
}
}