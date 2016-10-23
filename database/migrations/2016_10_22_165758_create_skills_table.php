<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateSkillsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('skills', function (Blueprint $table) {
            $table->increments('id');
            $table->integer('type_id')->nullable();
            $table->string('name')->nullable();
            $table->string('chase_status')->nullable();
            $table->string('hurt_status')->nullable();
            $table->integer('hurt_num')->default(0);
            $table->string('pic_url')->nullable();
            $table->string('id_json')->nullable();
            $table->timestamp('created_at')->default(DB::raw('CURRENT_TIMESTAMP'));
            $table->timestamp('updated_at');   
            
            $table->foreign('type_id')
	            ->references('id')
	            ->on('skill_types')
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
        Schema::drop('skills');
    }
}
