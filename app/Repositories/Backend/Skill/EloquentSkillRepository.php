<?php

namespace App\Repositories\Backend\Skill;

use App\Models\Skill\Skill;
use Illuminate\Support\Facades\DB;
use App\Exceptions\GeneralException;
use App\Events\Backend\Skill\SkillCreated;
use App\Events\Backend\Skill\SkillUpdated;

/**
 * Class EloquentSkillRepository
 * @package App\Repositories\Skill
 */
class EloquentSkillRepository implements SkillRepositoryContract
{

    /**
     * @return mixed
     */
    public function getCount() {
    	return Skill::count();
    }
    
    /**
     * @return \Illuminate\Database\Eloquent\Collection|static[]
     */
    public function getForDataTable() {
    	return Skill::all();
    }
    
    /**
     * @param  string  $order_by
     * @param  string  $sort
     * @param  bool    $withStatuses
     * @return mixed
     */
    public function getAllSkills($order_by = 'id', $sort = 'asc', $withStatuses = false)
    {
    	if ($withStatuses) {
    		return Skill::with('statuses')
    		->orderBy($order_by, $sort)
    		->get();
    	}
    
    	return Skill::orderBy($order_by, $sort)
    	->get();
    }
    
    /**
     * @param  $input
     * @throws GeneralException
     * @return bool
     */
    public function create($input)
    {
    	if (Skill::where('name', $input['name'])->first()) {
    		throw new GeneralException(trans('exceptions.backend.skill.already_exists'));
    	}
        
    	if (! isset($input['statuses']))
    		$input['statuses'] = [];
    
    		DB::transaction(function() use ($input, $all) {
    			$skill       = new Skill;
    			$skill->name = $input['name'];
    
    			if ($skill->save()) {

    				$statuses = [];
    
    				if (is_array($input['statuses']) && count($input['statuses'])) {
    					foreach ($input['statuses'] as $perm) {
    						if (is_numeric($perm)) {
    							array_push($statuses, $perm);
    						}
    					}
    				}
    
    				$skill->attachStatuses($statuses);
    				
    
    				event(new SkillCreated($skill));
    				return true;
    			}
    
    			throw new GeneralException(trans('exceptions.backend.access.skills.create_error'));
    		});
    }
    
    /**
     * @param  Skill $skill
     * @param  $input
     * @throws GeneralException
     * @return bool
     */
    public function update(Skill $skill, $input)
    {
    
    	if (! isset($input['statuses']))
    		$input['statuses'] = [];
    
    		$skill->name = $input['name'];
        
    		DB::transaction(function() use ($skill, $input, $all) {
    			if ($skill->save()) {
    				//Remove all skills first
    				$skill->statuses()->sync([]);
    
    				//Attach statuses if the skill does not have all access
    				$statuses = [];
    
    				if (is_array($input['statuses']) && count($input['statuses'])) {
    					foreach ($input['statuses'] as $perm) {
    						if (is_numeric($perm)) {
    							array_push($statuses, $perm);
    						}
    					}
    				}
    
    				$skill->attachStatuses($statuses);
    				
    
    				event(new SkillUpdated($skill));
    				return true;
    			}
    
    			throw new GeneralException(trans('exceptions.backend.skills.update_error'));
    		});
    }
    
    /**
     * @param  $input
     * @return mixed
     */
    private function createSkillStub($input)
    {
        $skill                    = new Skill;
        $skill->name              = $input['name'];
        $skill->alias             = $input['alias'];
        return $skill;
    }
}