<?php

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\Model;


class DatabaseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        Model::unguard();

        $this->call(AccessTableSeeder::class);
        //$this->call(HistoryTypeTableSeeder::class);

        $this->call(SkillTypeTableSeeder::class);
        $this->call(StatusTableSeeder::class);
        
        Model::reguard();
        $this->call('NinjasTableSeeder');
        $this->call('SkillsTableSeeder');
        $this->call('NinjasSkillsTableSeeder');
        $this->call('SkillsStatusesTableSeeder');
        $this->call('StatusesTableSeeder');
    }
}
