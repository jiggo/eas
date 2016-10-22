<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateNinjasSkillsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('ninjas_skills', function (Blueprint $table) {
            $table->increments('id');
            $table->integer('ninja_id')->nullable();
            $table->integer('skill_id')->nullable();
            $table->timestamp('created_at')->default(DB::raw('CURRENT_TIMESTAMP'));
            $table->timestamp('updated_at');            
        });
        
        $table->foreign('ninja_id')
        	->references('id')
        	->on('ninjas')
        	->onDelete('cascade');
        
        $table->foreign('skill_id')
	        ->references('id')
	        ->on('skills')
	        ->onDelete('cascade');
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::drop('ninjas_skills');
    }
}
