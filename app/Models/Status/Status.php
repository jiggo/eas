<?php namespace App\Models\Status;

use Illuminate\Database\Eloquent\Model;
use App\Model\Skill\Skill;

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
	/*
	public function skills()
	{
		return $this->belongsToMany(Skill::class, 'skills_statuses', 'skill_id', 'status_id');
	}
	*/
}