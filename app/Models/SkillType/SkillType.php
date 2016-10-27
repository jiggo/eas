<?php namespace App\Models\SkillType;

use Illuminate\Database\Eloquent\Model;
use App\Model\Skill\Skill;

/**
 * Class SkillType
 * package App
 */
class SkillType extends Model {

	/**
	 * The database table used by the model.
	 *
	 * @var string
	 */
	protected $table = 'skill_types';

	/**
	 * The attributes that are mass assignable.
	 *
	 * @var array
	 */
	protected $fillable = ['name'];
}