<?php namespace App\Models\Ninja;

use Illuminate\Database\Eloquent\Model;
use App\Models\Skill\Skill;
use App\Models\Ninja\NinjaAttribute;
/**
 * Class Ninja
 * package App
 */
class Ninja extends Model {

	use NinjaAttribute;
	
	/**
	 * The database table used by the model.
	 *
	 * @var string
	 */
	protected $table = 'ninjas';

	/**
	 * The attributes that are mass assignable.
	 *
	 * @var array
	 */
	protected $fillable = ['name', 'alias', 'attribute', 'chakra', 'life', 'attack', 'defense', 'ninjutsu', 'resistance', 'human', 'summon_color'];

	/**
	 * @return \Illuminate\Database\Eloquent\Relations\HasMany
	 */
	public function skills()
	{
		return $this->belongsToMany(Skill::class, 'ninjas_skills', 'ninja_id', 'skill_id');
	}
}