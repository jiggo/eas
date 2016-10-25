<?php

namespace App\Repositories\Backend\Status;

use App\Models\Status\Status;
use Illuminate\Support\Facades\DB;
use App\Exceptions\GeneralException;
use App\Events\Backend\Status\StatusCreated;
use App\Events\Backend\Status\StatusUpdated;

/**
 * Class EloquentStatusRepository
 * @package App\Repositories\Status
 */
class EloquentStatusRepository implements StatusRepositoryContract
{

    /**
     * @return mixed
     */
    public function getCount() {
    	return Status::count();
    }
    
    /**
     * @return \Illuminate\Database\Eloquent\Collection|static[]
     */
    public function getForDataTable() {
    	return Status::all();
    }
    
    /**
     * @param  string  $order_by
     * @param  string  $sort
     * @return mixed
     */
    public function getAllStatuses($order_by = 'id', $sort = 'asc')
    {
    	return Status::orderBy($order_by, $sort)
    	->get();
    }
    
    /**
     * @param  $input
     * @throws GeneralException
     * @return bool
     */
    public function create($input)
    {
    	if (Status::where('name', $input['name'])->first()) {
    		throw new GeneralException(trans('exceptions.backend.status.already_exists'));
    	}        
    
    		DB::transaction(function() use ($input, $all) {
    			$status       = new Status;
    			$status->name = $input['name'];
    
    			if ($status->save()) {    			
    				return true;
    			}
    
    			throw new GeneralException(trans('exceptions.backend.access.statuss.create_error'));
    		});
    }
    
    /**
     * @param  Status $status
     * @param  $input
     * @throws GeneralException
     * @return bool
     */
    public function update(Status $status, $input)
    {
    
    		$status->name = $input['name'];
        
    		DB::transaction(function() use ($status, $input, $all) {
    			if ($status->save()) {    				
    				return true;
    			}
    
    			throw new GeneralException(trans('exceptions.backend.statuss.update_error'));
    		});
    }
    
    /**
     * @param  $input
     * @return mixed
     */
    private function createStatusStub($input)
    {
        $status                    = new Status;
        $status->name              = $input['name'];
        $status->alias             = $input['alias'];
        return $status;
    }
}
