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
     * @param $roles
     * @return mixed
     */
    public function create($input, $roles);

    /**
     * @param Ninja $ninja
     * @param $input
     * @param $skills
     * @return mixed
     */
    public function update(Ninja $ninja, $input, $skills);

    /**
     * @param  Ninja $ninja
     * @return mixed
     */
    public function delete(Ninja $ninja);
}