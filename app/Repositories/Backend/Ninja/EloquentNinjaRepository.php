<?php

namespace App\Repositories\Backend\Ninja;

use App\Models\Ninja\Ninja;
use App\Models\Skill\Skill;
use App\Models\Status\Status;
use Illuminate\Support\Facades\DB;
use App\Exceptions\GeneralException;
use App\Events\Backend\Ninja\NinjaCreated;
use App\Events\Backend\Ninja\NinjaUpdated;
use App\Exceptions\Backend\Access\Ninja\NinjaNeedsRolesException;

/**
 * Class EloquentNinjaRepository
 * @package App\Repositories\Ninja
 */
class EloquentNinjaRepository implements NinjaRepositoryContract
{
	private $highest_combo = 1;
	private $ninjas = array();
	private $considered = array();
	private $high_combo_queue = array();
	private $best_team = array();
	private $teams = array();
	private $highest_team_combo = 1;
	private $combos = 1;
	private $hits = 0;
	private $counter = 1;
	private $perms = array();
	private $perms_sets = array();
	
    /**
     * @return mixed
     */
    public function getForDataTable()
    {
        return Ninja::select(['id', 'name', 'alias', 'life', 'attack', 'defense', 'ninjutsu', 'resistance'])
            ->get();
    }

    /**
     * @param  string  $order_by
     * @param  string  $sort
     * @param  bool    $withSkills
     * @return mixed
     */
    public function getAllNinjas($order_by = 'id', $sort = 'asc', $withSkills = false)
    {
    	if ($withSkills) {
    		return Ninja::with('skills')
			    		->where('main', false)
			    		->where('human', true)
			    		->orderBy($order_by, $sort)
			    		->get();
    	}
    
    	return Ninja::
			    	where('main', false)
			    	->where('human', true)
			    	->orderBy($order_by, $sort)
			    	->get();
    }
    
    /**
     * @param  string  $order_by
     * @param  string  $sort
     * @param  bool    $withSkills
     * @return mixed
     */
    public function getAllMains($order_by = 'id', $sort = 'asc', $withSkills = false)
    {
    	if ($withSkills) {
    		return Ninja::with('skills')
    		->where('main', true)
    		->orderBy($order_by, $sort)
    		->get();
    	}
    
    	return Ninja::
    	where('main', true)
    	->orderBy($order_by, $sort)
    	->get();
    }
    
    /**
     * @param  string  $order_by
     * @param  string  $sort
     * @param  bool    $withSkills
     * @return mixed
     */
    public function getAllSummons($order_by = 'id', $sort = 'asc', $withSkills = false)
    {
    	if ($withSkills) {
    		return Ninja::with('skills')
    		->where('human', false)
    		->orderBy($order_by, $sort)
    		->get();
    	}
    
    	return Ninja::
    	where('human', false)
    	->orderBy($order_by, $sort)
    	->get();
    }
    
    /**
     * @param integer $ninja_id
     * @return mixed
     */
    public function getAllSkills($ninja_id, $type_id)
    {    	    
    	return Ninja::with(array('skills' => function($query) use ($type_id) {
    		switch($type_id) {
    			case 1:
    				$query->mistery();
    				break;
    			case 2:
    				$query->chase();
    				break;
    			case 3:
    				$query->standard();
    				break;
    			case 4:
    				$query->passive();
    				break;
    		}
    	}))
    	->where('id', $ninja_id)
    	->first();
    }
    
    /**
     * @param  $request
     * @throws GeneralException
     * @throws NinjaNeedsRolesException
     * @return bool
     */
    public function create($request)
    {
    	$input = $request->all();
        $ninja = $this->createNinjaStub($input);
        
		DB::transaction(function() use ($ninja, $input) {
			if ($ninja->save()) {

				//Attach new skills
				$ninja->skills()->attach($input['associated-skills']);

				return true;
			}

        	throw new GeneralException(trans('exceptions.backend.ninjas.create_error'));
		});
    }

    /**
     * @param Ninja $ninja
     * @param $input
     * @param $skills
     * @return bool
     * @throws GeneralException
     */
    public function update(Ninja $ninja, $input, $skills)
    {            	
		DB::transaction(function() use ($ninja, $input, $skills) {
			if ($ninja->update($input)) {
				//For whatever reason this just wont work in the above call, so a second is needed for now
				$this->flushSkills($skills, $ninja);
				$ninja->save();

				return true;
			}

        	throw new GeneralException(trans('exceptions.backend.ninjas.update_error'));
		});
    }

    /**
     * @param  Ninja $ninja
     * @throws GeneralException
     * @return boolean|null
     */
    public function delete(Ninja $ninja)
    {
		DB::transaction(function() use ($ninja) {
			//Detach all skills
			$ninja->skills()->detach();
			if ($ninja->forceDelete()) {				
				return true;
			}

			throw new GeneralException(trans('exceptions.backend.ninjas.delete_error'));
		});
    }   
    
    /**
     * @param  $input
     * @return integer
     */
    public function getTeams($input, $fixed = array(), $variable = array(), $main, $summon) {    	
    	
    	$this->ninjas = $this->loadData($input);

    	$this->pc_permute_subset($variable, 4 - count($fixed) - 1);   
    	foreach($this->perms_sets as $perm) {
    		$tocombine = array_merge($perm, $fixed, array($main["id"]), array($summon));
    		$this->pc_permute($tocombine);
    		foreach($this->perms as $key => $ids) {
    			$this->teams[$key] = array();
    			$this->ninjasCombo($ids, $key);
    		}
    	}
    	$return_teams = array();
    	foreach($this->teams as $team) {
    		if(count($return_teams) == 0) { 
    			$return_teams[] = $team;
    		} else {
    			$result = $this->recursive_array_search($team["team"], array_column($return_teams, "team")); 
    			if($result === false) {
    				$return_teams[] = $team;
    			} else {
					
    				if($return_teams[$result]["combo"] < $team["combo"]) {
    					$return_teams[$result] = $team;
    				}    				
    			}
    		}    		
    	}
    	
    	$teams = array();
    	foreach($return_teams as $key => $row) {
    		$teams[$key] = $row["combo"];
    	}
    	array_multisort($teams, SORT_DESC, $return_teams);
    	return $return_teams;
    }
    
    /**
     * @param  $input     
     * @return integer
     */
    public function getCombo($input) {    	
    	$this->ninjas = $this->loadData($input);
    	$ids = array();

    	foreach($this->ninjas as $key => $ninja)
    		$ids[] = $key;
    	$this->pc_permute($ids);
    	foreach($this->perms as $key => $ids) {
    		$this->ninjasCombo($ids);    	
    	}
    	return $this->highest_combo;
    }
    
    private function ninjasCombo($ids, $key = 0) {

    	$this->considered = array();
    	$this->high_combo_queue = array();
    	$this->combos = 1;
    	$this->highest_team_combo = 1;
    	$this->hits = 0;
    	$this->teams[$key]["team"] = $ids;
    	$this->teams[$key]["combo"] = $this->highest_team_combo;
    	foreach($ids as $id) {
			$ninja = $this->ninjas[$id];
			
    		/************** Mistery **************/
    		if(isset($ninja["mistery"])) {
    			    			
    			//echo "Mistery of ".$ninja['name']."\n";    			
	    		$this->considered = array();
	    		$this->high_combo_queue = array();
	    		$this->combos = 1;
	    		$this->hits = 0;
	    		$this->findNext($ninja, $ninja["mistery"], $ids);
	    		//echo "hits: ".$this->hits."\n";
	    		if($this->hits >= 10) {
	    			foreach($this->high_combo_queue as $key => $value) {
	    				$this->combos++;
	    			}
	    		}
    		}

    		if($this->combos > $this->highest_team_combo) {
    			$this->highest_team_combo = $this->combos;
    		}    		
    		
    		/************** Standard **************/
    		if(isset($ninja["standard"])) {
    			//echo "Standard of ".$ninja['name']."\n";
		    	$this->considered = array();
		    	$this->high_combo_queue = array();
		    	$this->combos = 1;
	    		$this->hits = 0;
	    		$this->findNext($ninja, $ninja["standard"], $ids);
	    		//echo "hits: ".$this->hits."\n";
	    		if($this->hits >= 10) {
	    			foreach($this->high_combo_queue as $key => $value) {
	    				$this->combos++;
	    			}
	    		}
    		}

    		if($this->combos > $this->highest_team_combo) {
    			$this->highest_team_combo = $this->combos;
    		}
    		
    		if($this->combos > $this->highest_combo) {
    			$this->highest_combo = $this->combos;        			
    		}
    	}
    	
    	$this->teams[$key]["combo"] = $this->highest_team_combo;
    }
    
    private function findNext($current, $attack, $ids) {
       
    	$toReturn = array();
    	$summon_times = 0;
    	if(!isset($attack["hurt_statuses"]) || count($attack["hurt_statuses"]) == 0)
    		return $toReturn;
    
    	$i = 0;
    	foreach($ids as $ninja_key) {
    		$ninja = $this->ninjas[$ninja_key];
    		foreach($attack["hurt_statuses"] as $create_key => $create) {
    			if(isset($ninja["chases"])) {
	    			foreach($ninja["chases"] as $chase_key => $chase) {
	    				if(isset($chase["chase_statuses"])) {
		    				foreach($chase["chase_statuses"] as $pursuit_key => $pursuit) {
		    					if(!$this->isConsidered($ninja_key, $chase_key))
		    					{
		    						if($create["id"] == $pursuit["id"])
		    						{
		    							$this->combos++;
										//echo "Found Match: ".$current['name']." with ".$ninja['name']." - ".$create["alias"]."\n";
		    							if((!$ninja["human"] && $ninja["summon_color"] == 'yellow' && $summon_times > 2) || $ninja["human"]) {
		    								$this->considered[] = array('ninja_key' => $ninja_key, 'chase_key' => $chase_key);
		    							}
		    							if(!$ninja["human"] && $ninja["summon_color"] == 'yellow' && $summon_times < 2) {
		    								$summon_times++;
		    							}
		    							$toReturn[] = $ninja["name"];
		    							if($i == 0)
		    								$this->hits += $attack["hurt_num"];
		    								
		    							$this->hits += $chase["hurt_num"];
		    							$toReturn = array_merge($toReturn, $this->findNext($ninja, $chase, $ids));
		    							break;
		    						}
		    		    		    
		    						if($pursuit["alias"] == 'high_combo')
		    						{
		    							$this->high_combo_queue[] = array('ninja_key' => $ninja_key, 'chase_key' => $chase_key);
		    							$this->considered[] = array('ninja_key' => $ninja_key, 'chase_key' => $chase_key);
		    						}
		    					}
		    				}
		    			}
	    				if(count($toReturn) > 0)
	    					break;
	    			}
    			}
    			if(count($toReturn) > 0)
    				break;
    		}
    		if(count($toReturn) > 0)
    			break;
    		$i++;
    	}
    	return $toReturn;
    }
    
    private function isConsidered($ninja_key, $chase_key) {
    	$return = false;
    	foreach($this->considered as $cons_key => $cons_value) {
    		if($cons_value['ninja_key'] == $ninja_key && $cons_value['chase_key'] == $chase_key) {
    			$return = true;
    		}
    	}
    	return $return;
    }
    
    private function pc_permute($items, $perms = array( )) {

	    if (empty($items)) { 
	    	$this->perms[] = $perms;
	    }  else {
	    	$return = array();
	        for ($i = count($items) - 1; $i >= 0; --$i) {
	             $newitems = $items;
	             $newperms = $perms;
	             list($foo) = array_splice($newitems, $i, 1);
	             array_unshift($newperms, $foo);
	             $this->pc_permute($newitems, $newperms);
	         }
	    }
	}
    
	private function pc_permute_subset($super_set, $k, $idx = 0, &$current = array()) {
		//successful stop clause
		if (count($current) == $k) {
			$this->perms_sets[] = $current;
			return;
		}
		//unseccessful stop clause
		if ($idx == count($super_set)) return;
		$x = $super_set[$idx];
		$current[$x] = $x;
		//"guess" x is in the subset
		$this->pc_permute_subset($super_set, $k, $idx+1, $current);
		unset($current[$x]);
		//"guess" x is not in the subset
		$this->pc_permute_subset($super_set, $k, $idx+1, $current);
	}
	
    private function loadData($input) {    	
    	$ninjas = array();
    	
    	foreach($input as $type => $id) {
    		if($type == "main") {
    			//Get Ninjas mistery
    			$mistery = Skill::where('id', $id["mistery"])
    			->select(['id', 'name', 'hurt_num'])->first();
    			
    			//Get Ninjas mistery hurt
    			if(isset($mistery)) {
    				$ninjas[$id["id"]]["mistery"]["hurt_num"] = $mistery->hurt_num;
    				$statuses = Status::whereHas('skill', function($q) use($mistery) {
    					$q->where('skills.id', $mistery->id)
    					->where('skills_statuses.chase_create', 2);
    				})
    				->select(['statuses.id', 'statuses.alias'])->get();
    					
    				foreach ($statuses as $status) {
    					$ninjas[$id["id"]]["mistery"]["hurt_statuses"][] = array("id" => $status->id, "alias" => $status->alias);
    				}
    			}
    			
    			//Get Ninjas standard
    			$standard = Skill::where('id', $id["standard"])
    			->select(['id', 'name', 'hurt_num'])->first();
    				
    			//Get Ninjas standard hurt
    			if(isset($standard)) {
    				$ninjas[$id["id"]]["standard"]["hurt_num"] = $standard->hurt_num;
    				$statuses = Status::whereHas('skill', function($q) use($standard) {
    					$q->where('skills.id', $standard->id)
    					->where('skills_statuses.chase_create', 2);
    				})
    				->select(['statuses.id', 'statuses.alias'])->get();
    			
    				foreach ($statuses as $status) {
    					$ninjas[$id["id"]]["standard"]["hurt_statuses"][] = array("id" => $status->id, "alias" => $status->alias);
    				}
    			}   				
    				
    			//Get Ninjas chase
    			$chase = Skill::where('id', $id["chase"])
    			->select(['id', 'name', 'hurt_num'])->first();
    			
    			//Get Ninjas chases hurt
    			if(isset($chase)) {

    				$ninjas[$id["id"]]["chases"][$chase->id]["hurt_num"] = $chase->hurt_num;
    				$statuses = Status::whereHas('skill', function($q) use($chase) {
    					$q->where('skills.id', $chase->id)
    					->where('skills_statuses.chase_create', 2);
    				})
    				->select(['statuses.id', 'statuses.alias'])->get();
    				foreach ($statuses as $status) {
    					$ninjas[$id["id"]]["chases"][$chase->id]["hurt_statuses"][] = array("id" => $status->id, "alias" => $status->alias);
    				}
    			
    				$statuses = Status::whereHas('skill', function($q) use($chase) {
    					$q->where('skills.id', $chase->id)
    					->where('skills_statuses.chase_create', 1);
    				})
    				->select(['statuses.id', 'statuses.alias'])->get();
    				foreach ($statuses as $status) {
    					$ninjas[$id["id"]]["chases"][$chase->id]["chase_statuses"][] = array("id" => $status->id, "alias" => $status->alias);
    				}
    			}
    			$ninja = Ninja::where('id', $id["id"])->first();
    			 
    			$ninjas[$id["id"]]["name"] = $ninja->name;
    			$ninjas[$id["id"]]["human"] = $ninja->human;
    			$ninjas[$id["id"]]["summon_color"] = $ninja->summon_color;
    			$ninjas[$id["id"]]["attributes"]["life"] = $ninja->life;
    			$ninjas[$id["id"]]["attributes"]["attack"] = $ninja->attack;
    			$ninjas[$id["id"]]["attributes"]["defense"] = $ninja->defense;
    			$ninjas[$id["id"]]["attributes"]["ninjutsu"] = $ninja->ninjutsu;
    			$ninjas[$id["id"]]["attributes"]["resistance"] = $ninja->resistance;
    				
    		} else {
    		
	    		//Get Ninjas mistery
	    		$mistery = Skill::whereHas('ninja', function($q) use($id) {
	    						$q->where('ninjas.id', $id);
					    	})
					    	->where('type_id', 1)
					    	->select(['skills.id', 'skills.name', 'skills.hurt_num'])->first();
	    	
	    		//Get Ninjas mistery hurt
	    		if(isset($mistery)) {
	    			$ninjas[$id]["mistery"]["hurt_num"] = $mistery->hurt_num;
	    			$statuses = Status::whereHas('skill', function($q) use($mistery) {
				    				$q->where('skills.id', $mistery->id)
				    					->where('skills_statuses.chase_create', 2);
				    			})			    			
				    			->select(['statuses.id', 'statuses.alias'])->get();
	    			    			    		    
			    	foreach ($statuses as $status) {
			    		$ninjas[$id]["mistery"]["hurt_statuses"][] = array("id" => $status->id, "alias" => $status->alias);
			    	}
	    	
	    		}
	    	
	    		//Get Ninjas standard
	    		$standard = Skill::whereHas('ninja', function($q) use($id) {
				    			$q->where('ninjas.id', $id);
				    		})
				    		->where('type_id', 3)
				    		->select(['skills.id', 'skills.name', 'skills.hurt_num'])->first();
				    		    		
	    		//Get Ninjas standard hurt
	    		if(isset($standard)) {
	    			$ninjas[$id]["standard"]["hurt_num"] = $standard->hurt_num;
	    			$statuses = Status::whereHas('skill', function($q) use($standard) {
						    				$q->where('skills.id', $standard->id)
						    				->where('skills_statuses.chase_create', 2);
						    			})
						    			->select(['statuses.id', 'statuses.alias'])->get();
	    			
	    			foreach ($statuses as $status) {
	    				$ninjas[$id]["standard"]["hurt_statuses"][] = array("id" => $status->id, "alias" => $status->alias);
	    			}
	    		}
	    	
	    		//Get Ninjas chase
	    		$chases = Skill::whereHas('ninja', function($q) use($id) {
					    			$q->where('ninjas.id', $id);
					    		})
					    		->where('type_id', 2)
					    		->select(['skills.id', 'skills.name', 'skills.hurt_num'])->get();
	    	
	    		//Get Ninjas chases hurt
	    		if(isset($chases)) {
	    			foreach($chases as $chase) {
	    				$ninjas[$id]["chases"][$chase->id]["hurt_num"] = $chase->hurt_num;
	    				$statuses = Status::whereHas('skill', function($q) use($chase) {
				    					$q->where('skills.id', $chase->id)
				    					->where('skills_statuses.chase_create', 2);
				    				})
				    				->select(['statuses.id', 'statuses.alias'])->get();
	    				foreach ($statuses as $status) {
	    					$ninjas[$id]["chases"][$chase->id]["hurt_statuses"][] = array("id" => $status->id, "alias" => $status->alias);
	    				}    			
	    	
	    				$statuses = Status::whereHas('skill', function($q) use($chase) {
				    					$q->where('skills.id', $chase->id)
				    					->where('skills_statuses.chase_create', 1);
				    				})
				    				->select(['statuses.id', 'statuses.alias'])->get();
	    				foreach ($statuses as $status) {
	    					$ninjas[$id]["chases"][$chase->id]["chase_statuses"][] = array("id" => $status->id, "alias" => $status->alias);
	    				}    				
	    			}
	    		}
	    	
	    		$ninja = Ninja::where('id', $id)->first();
	    		
	    		$ninjas[$id]["name"] = $ninja->name;
	    		$ninjas[$id]["human"] = $ninja->human;
	    		$ninjas[$id]["summon_color"] = $ninja->summon_color;
	    		$ninjas[$id]["attributes"]["life"] = $ninja->life;
	    		$ninjas[$id]["attributes"]["attack"] = $ninja->attack;
	    		$ninjas[$id]["attributes"]["defense"] = $ninja->defense;
	    		$ninjas[$id]["attributes"]["ninjutsu"] = $ninja->ninjutsu;
	    		$ninjas[$id]["attributes"]["resistance"] = $ninja->resistance;  
    		}
    	}
    	
    	return $ninjas;
    }
    
    private function getMainSkills($main) {
    	
    }
    /**
     * @param $skills
     * @param $ninja
     */
    private function flushSkills($skills, $ninja)
    {
        //Flush skills out, then add array of new ones
        $ninja->skills()->detach();
        $ninja->skills()->attach($skills['associated-skills']);
    }

    private function in_array_r($needle, $haystack, $strict = false) {
    	foreach ($haystack as $item) {
    		if (($strict ? $item === $needle : $item == $needle) || (is_array($item) && $this->in_array_r($needle, $item, $strict))) {
    			return true;
    		}
    	}
    
    	return false;
    }
    
    private function recursive_array_search($needle,$haystack) {
    	foreach($haystack as $key => $value) {
    		$current_key=$key;
    		asort($needle);
    		asort($value);
    		if(count(array_diff($needle, $value)) == 0) {
    			return $current_key;
    		}
    	}
    	return false;
    }
    
    /**
     * @param  $input
     * @return mixed
     */
    private function createNinjaStub($input)
    {
        $ninja                    = new Ninja;
        $ninja->name              = $input['name'];
        $ninja->alias             = $input['alias'];
        $ninja->attribute		  = $input['attribute'];
        $ninja->chakra			  = $input['chakra'];
        $ninja->life			  = $input['life'];
        $ninja->attack			  = $input['attack'];
        $ninja->defense			  = $input['defense'];
        $ninja->ninjutsu		  = $input['ninjutsu'];
        $ninja->resistance		  = $input['resistance'];
        $ninja->human			  = isset($input['human']) ? true : false;
        $ninja->summon_color	  = $input['summon_color'];
        return $ninja;
    }
}
