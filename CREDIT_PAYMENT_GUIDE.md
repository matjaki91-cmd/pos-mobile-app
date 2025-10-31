# Customer Credit and Payment Implementation Guide

This document provides detailed instructions for implementing customer credit accounts and payment functionality in the POS mobile app.

## Overview

The POS system supports three payment methods:
1. **Cash Payment**: Immediate payment at the counter
2. **Card Payment**: Credit/debit card payment (integration ready)
3. **Credit Account**: Customer credit balance payment (buy now, pay later)

## Customer Credit System

### How It Works

1. **Customer Registration**: Create a customer account with initial credit balance
2. **Credit Purchase**: Customer purchases items on credit
3. **Credit Balance Update**: System automatically updates customer's credit balance
4. **Payment Recording**: Customer can pay off their credit balance later

### Database Structure

**Customers Table**
```
- id: String (Primary Key)
- name: String
- phoneNumber: String (Optional)
- email: String (Optional)
- address: String (Optional)
- creditBalance: Double (Current credit balance)
- createdAt: DateTime
- updatedAt: DateTime
```

**Credit Transactions Table**
```
- id: String (Primary Key)
- customerId: String (Foreign Key)
- amount: Double
- transactionType: String (credit_purchase, credit_payment)
- orderId: String (Optional)
- description: String (Optional)
- createdAt: DateTime
- updatedAt: DateTime
```

## Implementation

### Step 1: Customer Selection

In the checkout screen, implement customer selection:

```dart
class CustomerSelectionDialog extends StatefulWidget {
  @override
  State<CustomerSelectionDialog> createState() => _CustomerSelectionDialogState();
}

class _CustomerSelectionDialogState extends State<CustomerSelectionDialog> {
  final ApiService _apiService = ApiService();
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);
  }

  Future<void> _loadCustomers() async {
    try {
      final customers = await _apiService.getCustomers();
      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
      });
    } catch (e) {
      print('Error loading customers: $e');
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _customers
          .where((customer) =>
              customer.name.toLowerCase().contains(query) ||
              (customer.phoneNumber?.contains(query) ?? false))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Customer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search by name or phone...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = _filteredCustomers[index];
                return ListTile(
                  title: Text(customer.name),
                  subtitle: Text(
                    'Credit: RM ${customer.creditBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: customer.creditBalance > 0 ? Colors.orange : Colors.green,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, customer);
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

### Step 2: Credit Payment Processing

Implement credit payment in the checkout screen:

```dart
Future<void> _processCreditPayment(
  BuildContext context,
  CartProvider cart,
  Customer customer,
) async {
  setState(() {
    _isProcessing = true;
  });

  try {
    // Prepare order items
    final orderItems = cart.items
        .map((item) => {
              'productId': item.product.id,
              'quantity': item.quantity.toString(),
              'unitPrice': item.product.price.toString(),
            })
        .toList();

    // Create order
    final order = await _apiService.createOrder(
      customerId: customer.id,
      items: orderItems,
      paymentMethod: 'credit',
    );

    // Record credit transaction
    await _apiService.recordCreditTransaction(
      customerId: customer.id,
      amount: cart.total,
      transactionType: 'credit_purchase',
      orderId: order.id,
      description: 'Purchase on ${DateTime.now()}',
    );

    // Clear cart
    cart.clear();

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order created. Customer credit balance: '
            'RM ${(customer.creditBalance - cart.total).toStringAsFixed(2)}',
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back to home
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}
```

### Step 3: Credit Balance Management

Create a customer credit screen:

```dart
class CustomerCreditScreen extends StatefulWidget {
  final Customer customer;

  const CustomerCreditScreen({
    Key? key,
    required this.customer,
  }) : super(key: key);

  @override
  State<CustomerCreditScreen> createState() => _CustomerCreditScreenState();
}

class _CustomerCreditScreenState extends State<CustomerCreditScreen> {
  final ApiService _apiService = ApiService();
  Customer? _updatedCustomer;

  @override
  void initState() {
    super.initState();
    _loadCustomerDetails();
  }

  Future<void> _loadCustomerDetails() async {
    try {
      final customer = await _apiService.getCustomerById(widget.customer.id);
      if (customer != null) {
        setState(() {
          _updatedCustomer = customer;
        });
      }
    } catch (e) {
      print('Error loading customer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = _updatedCustomer ?? widget.customer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Credit'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Info
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (customer.phoneNumber != null)
                        Text('Phone: ${customer.phoneNumber}'),
                      if (customer.email != null)
                        Text('Email: ${customer.email}'),
                      if (customer.address != null)
                        Text('Address: ${customer.address}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Credit Balance
              Card(
                elevation: 2,
                color: customer.creditBalance > 0 ? Colors.orange.shade50 : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Credit Balance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'RM ${customer.creditBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: customer.creditBalance > 0 ? Colors.orange : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        customer.creditBalance > 0
                            ? 'Amount owed'
                            : 'Credit available',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Action
              if (customer.creditBalance > 0)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showPaymentDialog(context, customer);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Make Payment'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, Customer customer) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Amount owed: RM ${customer.creditBalance.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Payment amount',
                border: OutlineInputBorder(),
                prefixText: 'RM ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                try {
                  await _apiService.recordCreditTransaction(
                    customerId: customer.id,
                    amount: amount,
                    transactionType: 'credit_payment',
                    description: 'Payment on ${DateTime.now()}',
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    _loadCustomerDetails();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment recorded successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }
}
```

## Payment Methods Comparison

| Feature | Cash | Card | Credit |
|---------|------|------|--------|
| Immediate Payment | ✓ | ✓ | ✗ |
| Deferred Payment | ✗ | ✗ | ✓ |
| Balance Tracking | ✗ | ✗ | ✓ |
| Transaction History | ✗ | ✗ | ✓ |
| Credit Limit | N/A | N/A | Yes |

## Best Practices

1. **Always Verify Customer**: Confirm customer identity before credit purchase
2. **Real-time Balance Update**: Update credit balance immediately after transaction
3. **Transaction Logging**: Log all credit transactions for audit trail
4. **Credit Limit**: Implement credit limit checks before allowing purchase
5. **Payment Reminders**: Send reminders for overdue payments
6. **Receipt Generation**: Include credit balance on receipt

## Error Handling

```dart
try {
  // Credit transaction
} on InsufficientCreditException {
  // Handle insufficient credit
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Insufficient credit balance'),
      backgroundColor: Colors.red,
    ),
  );
} on CustomerNotFoundException {
  // Handle customer not found
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Customer not found'),
      backgroundColor: Colors.red,
    ),
  );
} catch (e) {
  // Handle other errors
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

## Testing

Test the credit system with these scenarios:

1. **New Customer**: Create new customer and make credit purchase
2. **Existing Customer**: Use existing customer with credit balance
3. **Payment Recording**: Record payment and verify balance update
4. **Multiple Transactions**: Multiple purchases and payments
5. **Edge Cases**: Zero balance, negative balance, large transactions

## References

- Backend API Documentation
- Customer Management API
- Credit Transaction API

