<?php

use Carbon\Carbon as Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Class StatusTableSeeder
 */
class StatusTableSeeder extends Seeder {

	/**
	 *
	 */
	public function run() {

		if (DB::connection()->getDriverName() == 'mysql') {
			DB::statement('SET FOREIGN_KEY_CHECKS=0;');
		}

		DB::table('statuses')->truncate();

		$statuses = [
			[
				'id' => 1,
				'name' => 'Knock Down',
				'alias' => 'knockdown',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 2,
				'name' => 'Repulse',
				'alias' => 'repulse',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 3,
				'name' => 'Low Float',
				'alias' => 'low_float',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 4,
				'name' => 'High Float',
				'alias' => 'high_float',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 5,
				'name' => 'High Combo',
				'alias' => 'high_combo',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 6,
				'name' => 'Poisoning',
				'alias' => 'poisoning',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 7,
				'name' => 'Sleeping',
				'alias' => 'sleeping',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 8,
				'name' => 'Paralysis',
				'alias' => 'paralysis',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 9,
				'name' => 'Ignition',
				'alias' => 'ignition',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 10,
				'name' => 'Tag',
				'alias' => 'tag',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 11,
				'name' => 'Blindness',
				'alias' => 'blindness',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 12,
				'name' => 'Acupuncture',
				'alias' => 'acupuncture',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
			[
				'id' => 13,
				'name' => 'Immobile',
				'alias' => 'immobile',
				'created_at' => Carbon::now(),
				'updated_at' => Carbon::now()
			],
		];

		DB::table('statuses')->insert($statuses);

		if (DB::connection()->getDriverName() == 'mysql') {
			DB::statement('SET FOREIGN_KEY_CHECKS=1;');
		}
	}
}