<?php namespace App\Models\Skill;

use Illuminate\Database\Eloquent\Model;
use App\Models\Status\Status;
/**
 * Class Skill
 * package App
 */
class Skill extends Model {

	/**
	 * The database table used by the model.
	 *
	 * @var string
	 */
	protected $table = 'skills';

	/**
	 * The attributes that are mass assignable.
	 *
	 * @var array
	 */
	protected $fillable = ['name', 'chase_status', 'hurt_status', 'hurt_num', 'pic_url'];

	/**
	 * @return \Illuminate\Database\Eloquent\Relations\HasMany
	 */
	public function statuses()
	{
		return $this->belongsToMany(Status::class, 'skills_statuses', 'skill_id', 'status_id');
	}

	/**
	 * @return \Illuminate\Database\Eloquent\Relations\HasOne
	 */
	public function type() {
		return $this->hasOne(SkillType::class, 'id', 'type_id');
	}
}