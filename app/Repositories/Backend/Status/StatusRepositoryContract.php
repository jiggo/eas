<?php

namespace App\Repositories\Backend\Status;

use App\Models\Status\Status;

/**
 * Interface StatusRepositoryContract
 * @package App\Repositories\Status
 */
interface StatusRepositoryContract
{

	/**
     * @return mixed
     */
    public function getForDataTable();

    /**
     * @param $input
     * @param $statuss
     * @return mixed
     */
    public function create($input);

    /**
     * @param Status $status
     * @param $input
     * @return mixed
     */
    public function update(Status $status, $input);

}