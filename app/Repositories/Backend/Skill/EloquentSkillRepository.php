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
    	return Skill::with(array('ninja' => function($query)
					{
					    $query->select('name');
					
					}))
    		->select(['id', 'name', 'hurt_num', 'type_id'])
            ->get();
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
    public function create($request)
    {
    	
    	$input = $request->all();
    	$skill = $this->createSkillStub($input);    	
    	
    	if (Skill::where('name', $input['name'])->first()) {
    		throw new GeneralException(trans('exceptions.backend.skill.already_exists'));
    	}
    
    	DB::transaction(function() use ($skill, $input) {   
    		if ($skill->save()) {

				//Attach new statuses
    			$chases = [];   
    			if (isset($input['associated-chases']) && count($input['associated-chases'])) {
    				foreach ($input['associated-chases'] as $chase) {
    					if (is_numeric($chase)) {
    						$chases[$chase] = array('chase_create' => 1);    							
    					}
    				}
    			}    
    			$skill->chases()->attach($chases);

    			$hurts = [];
    			if (isset($input['associated-hurts']) && count($input['associated-hurts'])) {
    				foreach ($input['associated-hurts'] as $hurt) {
    					if (is_numeric($hurt)) {
    						$hurts[$hurt] = array('chase_create' => 2);
    					}
    				}
    			}
    			$skill->hurts()->attach($hurts);
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
    public function update(Skill $skill, $input, $statuses)
    {   
        
    		DB::transaction(function() use ($skill, $input, $statuses) {
    			if ($skill->update($input)) {
    				//Remove all skills first
    				$skill->chases()->sync([]);
    				$skill->hurts()->sync([]);
    
    				//Attach statuses if the skill does not have all access
    				$chases = [];   
    				if (is_array($statuses['associated-chases']) && count($statuses['associated-chases'])) {
    					foreach ($statuses['associated-chases'] as $chase) {
    						if (is_numeric($chase)) {
    							$chases[$chase] = array('chase_create' => 1);    							
    						}
    					}
    				}    
    				$skill->chases()->attach($chases);

    				$hurts = [];
    				if (is_array($statuses['associated-hurts']) && count($statuses['associated-hurts'])) {
    					foreach ($statuses['associated-hurts'] as $hurt) {
    						if (is_numeric($hurt)) {
    							$hurts[$hurt] = array('chase_create' => 2);
    						}
    					}
    				}
    				$skill->hurts()->attach($hurts);
    				$skill->save();
    				return true;
    			}
    
    			throw new GeneralException(trans('exceptions.backend.skills.update_error'));
    		});
    }
    
    /**
     * @param  Skill $skill
     * @throws GeneralException
     * @return boolean|null
     */
    public function delete(Skill $skill)
    {
    	DB::transaction(function() use ($skill) {
    		//Detach all statuses
    		$skill->statuses()->detach();
    		if ($skill->forceDelete()) {
    			return true;
    		}
    
    		throw new GeneralException(trans('exceptions.backend.skills.delete_error'));
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
        $skill->hurt_num          = $input['hurt_num'];
        $skill->type_id           = $input['type_id'];
        return $skill;
    }
}
