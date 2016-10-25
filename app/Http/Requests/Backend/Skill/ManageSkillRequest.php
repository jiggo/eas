<?php

namespace App\Http\Requests\Backend\Skill;

use App\Http\Requests\Request;

/**
 * Class ManageSkillRequest
 * @package App\Http\Requests\Backend\Access\Skill
 */
class ManageSkillRequest extends Request
{
	/**
	 * Determine if the user is authorized to make this request.
	 *
	 * @return bool
	 */
	public function authorize()
	{
		return true;
		//return access()->allow('manage-users');
	}

	/**
	 * Get the validation rules that apply to the request.
	 *
	 * @return array
	 */
	public function rules()
	{
		return [
			//
		];
	}
}
