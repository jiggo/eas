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