<?php

Route::group([
    'namespace'  => 'Skill',
], function() {

	/**
	 * Skill Management
	 */

	Route::resource('skill', 'SkillController', ['except' => ['show']]);

	/**
	 * For DataTables
	 */
	Route::get('skill/get', 'SkillController@get')->name('admin.skill.get');

	/**
	 * Specific Skill
	 */
	Route::group(['prefix' => 'skill/{skill}'], function() {	
		Route::get('delete', 'SkillController@delete')->name('admin.skill.delete-permanently');
	});
});	