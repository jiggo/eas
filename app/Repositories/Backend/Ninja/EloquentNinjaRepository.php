<?php

namespace App\Repositories\Backend\Ninja;

use App\Models\Ninja\Ninja;
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
    		->orderBy($order_by, $sort)
    		->get();
    	}
    
    	return Ninja::orderBy($order_by, $sort)
    	->get();
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
     * @param $skills
     * @param $ninja
     */
    private function flushSkills($skills, $ninja)
    {
        //Flush skills out, then add array of new ones
        $ninja->skills()->detach();
        $ninja->skills()->attach($skills['associated-skills']);
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
        $ninja->human			  = $input['human'];
        $ninja->summon_color	  = $input['summon_color'];
        return $ninja;
    }
}
