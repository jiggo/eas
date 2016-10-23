<?php

Route::group([
    'namespace'  => 'Ninja',
], function() {

	/**
	 * Ninja Management
	 */

	Route::resource('ninja', 'NinjaController', ['except' => ['show']]);

	/**
	 * For DataTables
	 */
	Route::get('ninja/get', 'NinjaController@get')->name('admin.ninja.get');

	/**
	 * Specific Ninja
	 */
	Route::group(['prefix' => 'ninja/{ninja}'], function() {	
		Route::get('delete', 'NinjaController@delete')->name('admin.ninja.delete-permanently');
	});
});	