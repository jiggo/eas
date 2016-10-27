<?php

use Illuminate\Database\Seeder;

class StatusesTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('statuses')->delete();
        
        \DB::table('statuses')->insert(array (
            0 => 
            array (
                'id' => 1,
                'name' => 'Knock Down',
                'alias' => 'knockdown',
                'created_at' => '2016-10-25 08:11:24',
                'updated_at' => '2016-10-25 08:11:24',
            ),
            1 => 
            array (
                'id' => 2,
                'name' => 'Repulse',
                'alias' => 'repulse',
                'created_at' => '2016-10-25 08:11:24',
                'updated_at' => '2016-10-25 08:11:24',
            ),
            2 => 
            array (
                'id' => 3,
                'name' => 'Low Float',
                'alias' => 'low_float',
                'created_at' => '2016-10-25 08:11:24',
                'updated_at' => '2016-10-25 08:11:24',
            ),
            3 => 
            array (
                'id' => 4,
                'name' => 'High Float',
                'alias' => 'high_float',
                'created_at' => '2016-10-25 08:11:24',
                'updated_at' => '2016-10-25 08:11:24',
            ),
            4 => 
            array (
                'id' => 5,
                'name' => 'High Combo',
                'alias' => 'high_combo',
                'created_at' => '2016-10-25 08:11:24',
                'updated_at' => '2016-10-25 08:11:24',
            ),
            5 => 
            array (
                'id' => 6,
                'name' => 'Poisoning',
                'alias' => 'poisoning',
                'created_at' => '2016-10-25 08:11:24',
                'updated_at' => '2016-10-25 08:11:24',
            ),
            6 => 
            array (
                'id' => 7,
                'name' => 'Sleeping',
                'alias' => 'sleeping',
                'created_at' => '2016-10-25 08:11:24',
                'updated_at' => '2016-10-25 08:11:24',
            ),
            7 => 
            array (
                'id' => 8,
                'name' => 'Paralysis',
                'alias' => 'paralysis',
                'created_at' => '2016-10-25 08:11:24',
                'updated_at' => '2016-10-25 08:11:24',
            ),
            8 => 
            array (
                'id' => 9,
                'name' => 'Ignition',
                'alias' => 'ignition',
                'created_at' => '2016-10-25 08:11:24',
                'updated_at' => '2016-10-25 08:11:24',
            ),
            9 => 
            array (
                'id' => 10,
                'name' => 'Tag',
                'alias' => 'tag',
                'created_at' => '2016-10-25 08:11:24',
                'updated_at' => '2016-10-25 08:11:24',
            ),
            10 => 
            array (
                'id' => 11,
                'name' => 'Blindness',
                'alias' => 'blindness',
                'created_at' => '2016-10-25 08:11:24',
                'updated_at' => '2016-10-25 08:11:24',
            ),
            11 => 
            array (
                'id' => 12,
                'name' => 'Acupuncture',
                'alias' => 'acupuncture',
                'created_at' => '2016-10-25 08:11:24',
                'updated_at' => '2016-10-25 08:11:24',
            ),
            12 => 
            array (
                'id' => 13,
                'name' => 'Immobile',
                'alias' => 'immobile',
                'created_at' => '2016-10-25 08:11:24',
                'updated_at' => '2016-10-25 08:11:24',
            ),
            13 => 
            array (
                'id' => 14,
                'name' => 'Five Combo',
                'alias' => 'five_combo',
                'created_at' => '2016-10-27 16:45:12',
                'updated_at' => '2016-10-27 16:45:12',
            ),
        ));
        
        
    }
}
