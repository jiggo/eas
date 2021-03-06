<?php namespace App\Models\Status;

use Illuminate\Database\Eloquent\Model;
use App\Models\Skill\Skill;

/**
 * Class Status
 * package App
 */
class Status extends Model {

	/**
	 * The database table used by the model.
	 *
	 * @var string
	 */
	protected $table = 'statuses';

	/**
	 * The attributes that are mass assignable.
	 *
	 * @var array
	 */
	protected $fillable = ['name', 'alias'];

	/**
	 * @return \Illuminate\Database\Eloquent\Relations\HasMany
	 */
	
	public function skill()
	{
		return $this->belongsToMany(Skill::class, 'skills_statuses','status_id', 'skill_id');
	}
	
	
	
}