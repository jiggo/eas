<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateSkillsStatusesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('skills_statuses', function (Blueprint $table) {
            $table->increments('id');
            $table->integer('status_id')->nullable();
            $table->integer('skill_id')->nullable();
            $table->integer('chase_create')->default(0);
            $table->timestamp('created_at')->default(DB::raw('CURRENT_TIMESTAMP'));
            $table->timestamp('updated_at')->default(DB::raw('CURRENT_TIMESTAMP'));
            
            $table->foreign('status_id')
	            ->references('id')
	            ->on('statuses')
	            ->onDelete('cascade');
            
            $table->foreign('skill_id')
	            ->references('id')
	            ->on('skills')
	            ->onDelete('cascade');
        });
        

    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::drop('skills_statuses');
    }
}
