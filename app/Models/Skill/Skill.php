<?php namespace App\Models\Skill;

use Illuminate\Database\Eloquent\Model;
use App\Models\Status\Status;
use App\Models\Ninja\Ninja;
use App\Models\Skill\SkillAttribute;
/**
 * Class Skill
 * package App
 */
class Skill extends Model {

	use SkillAttribute;
	
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
	public function ninja()
	{
		return $this->belongsToMany(Ninja::class, 'ninjas_skills', 'skill_id', 'ninja_id');
	}
	
	/**
	 * @return \Illuminate\Database\Eloquent\Relations\HasMany
	 */
	public function statuses()
	{
		return $this->belongsToMany(Status::class, 'skills_statuses', 'skill_id', 'status_id');
	}	
	
	/**
	 * @return \Illuminate\Database\Eloquent\Relations\HasMany
	 */
	public function chases()
	{
		return $this->belongsToMany(Status::class, 'skills_statuses', 'skill_id', 'status_id')->where('chase_create', 1);
	}
	
	/**
	 * @return \Illuminate\Database\Eloquent\Relations\HasMany
	 */
	public function hurts()
	{
		return $this->belongsToMany(Status::class, 'skills_statuses', 'skill_id', 'status_id')->where('chase_create', 2);
	}
	
	/**
	 * @return \Illuminate\Database\Eloquent\Relations\HasOne
	 */
	public function type() {
		return $this->hasOne(SkillType::class, 'id', 'type_id');
	}
	
	/**
	 * Scope a query to only include mistery skills.
	 *
	 * @param \Illuminate\Database\Eloquent\Builder $query
	 * @return \Illuminate\Database\Eloquent\Builder
	 */
	public function scopeMistery($query)
	{
		return $query->where('type_id', 1);
	}
	
	/**
	 * Scope a query to only include chase skills.
	 *
	 * @param \Illuminate\Database\Eloquent\Builder $query
	 * @return \Illuminate\Database\Eloquent\Builder
	 */
	public function scopeChase($query)
	{
		return $query->where('type_id', 2);
	}
	
	/**
	 * Scope a query to only include standard skills.
	 *
	 * @param \Illuminate\Database\Eloquent\Builder $query
	 * @return \Illuminate\Database\Eloquent\Builder
	 */
	public function scopeStandard($query)
	{
		return $query->where('type_id', 3);
	}
	
	/**
	 * Scope a query to only include passive skills.
	 *
	 * @param \Illuminate\Database\Eloquent\Builder $query
	 * @return \Illuminate\Database\Eloquent\Builder
	 */
	public function scopePassive($query)
	{
		return $query->where('type_id', 4);
	}
}