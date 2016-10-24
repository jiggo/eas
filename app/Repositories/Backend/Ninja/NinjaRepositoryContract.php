<?php

namespace App\Repositories\Backend\Ninja;

use App\Models\Ninja\Ninja;

/**
 * Interface NinjaRepositoryContract
 * @package App\Repositories\Ninja
 */
interface NinjaRepositoryContract
{

	/**
     * @return mixed
     */
    public function getForDataTable();

    /**
     * @param  string  $order_by
     * @param  string  $sort
     * @param  bool    $withSkills
     * @return mixed
     */
    public function getAllNinjas($order_by = 'id', $sort = 'asc', $withSkills = false);
    
    /**
     * @param $input     
     * @return mixed
     */
    public function create($input);

    /**
     * @param Ninja $ninja
     * @param $request
     * @param $skills
     * @return mixed
     */
    public function update(Ninja $ninja, $request, $skills);

    /**
     * @param  Ninja $ninja
     * @return mixed
     */
    public function delete(Ninja $ninja);
}