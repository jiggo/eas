<?php

namespace App\Repositories\Backend\Skill;

use App\Models\Skill\Skill;

/**
 * Interface SkillRepositoryContract
 * @package App\Repositories\Skill
 */
interface SkillRepositoryContract
{

	/**
     * @return mixed
     */
    public function getForDataTable();

    /**
     * @param $input
     * @param $skills
     * @return mixed
     */
    public function create($input);

    /**
     * @param Skill $skill
     * @param $input
     * @param $statuses
     * @return mixed
     */
    public function update(Skill $skill, $input, $statuses);

}