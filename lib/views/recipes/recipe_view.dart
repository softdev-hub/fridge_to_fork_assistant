import 'package:flutter/material.dart';
import 'components/recipe_list_screen.dart';

class RecipeView extends StatelessWidget {
  const RecipeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF64748B)),
        title: const Text(
          'Món có thể làm từ sữa',
          style: TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: open more options
            },
          ),
        ],
      ),
      body: const SafeArea(top: false, child: RecipeListScreen()),
    );
  }
}
