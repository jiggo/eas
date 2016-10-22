<?php

use Carbon\Carbon as Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Class SkillTypeTableSeeder
 */
class SkillTypeTableSeeder extends Seeder {

	/**
	 *
	 */
	public function run() {

		if (DB::connection()->getDriverName() == 'mysql') {
			DB::statement('SET FOREIGN_KEY_CHECKS=0;');
		}

		DB::table('skill_types')->truncate();

		$types = [
			[
				'id' => 1,
				'name' => 'mistery',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 2,
				'name' => 'chase',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 3,
				'name' => 'standard',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 4,
				'name' => 'passive',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
		];

		DB::table('skill_types')->insert($types);

		if (DB::connection()->getDriverName() == 'mysql') {
			DB::statement('SET FOREIGN_KEY_CHECKS=1;');
		}
	}
}