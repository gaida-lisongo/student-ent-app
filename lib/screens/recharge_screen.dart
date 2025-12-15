import 'package:flutter/material.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Recharge Screen',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
