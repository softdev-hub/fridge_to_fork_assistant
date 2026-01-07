<?php

use App\Http\Controllers\DashboardController;
use App\Http\Controllers\IngredientController;
use App\Http\Controllers\PantryItemController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\RecipeController;
use App\Http\Controllers\MealPlanController;
use App\Http\Controllers\ShoppingListController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes - Admin Panel
|--------------------------------------------------------------------------
*/

// Dashboard
Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

// Ingredients Management
Route::resource('ingredients', IngredientController::class);

// Pantry Items Management
Route::get('/pantry-items', [PantryItemController::class, 'index'])->name('pantry-items.index');
Route::get('/pantry-items/{id}', [PantryItemController::class, 'show'])->name('pantry-items.show');
Route::delete('/pantry-items/{id}', [PantryItemController::class, 'destroy'])->name('pantry-items.destroy');

// Profiles/Users Management
Route::get('/profiles', [ProfileController::class, 'index'])->name('profiles.index');
Route::get('/profiles/{id}', [ProfileController::class, 'show'])->name('profiles.show');

// Recipes Management
Route::resource('recipes', RecipeController::class);

// Meal Plans Management
Route::get('/meal-plans', [MealPlanController::class, 'index'])->name('meal-plans.index');
Route::get('/meal-plans/{id}', [MealPlanController::class, 'show'])->name('meal-plans.show');
Route::delete('/meal-plans/{id}', [MealPlanController::class, 'destroy'])->name('meal-plans.destroy');

// Shopping Lists Management
Route::get('/shopping-lists', [ShoppingListController::class, 'index'])->name('shopping-lists.index');
Route::get('/shopping-lists/{id}', [ShoppingListController::class, 'show'])->name('shopping-lists.show');
Route::delete('/shopping-lists/{id}', [ShoppingListController::class, 'destroy'])->name('shopping-lists.destroy');
