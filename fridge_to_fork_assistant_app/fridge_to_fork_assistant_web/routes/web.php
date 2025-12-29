<?php

use App\Http\Controllers\DashboardController;
use App\Http\Controllers\IngredientController;
use App\Http\Controllers\PantryItemController;
use App\Http\Controllers\ProfileController;
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
