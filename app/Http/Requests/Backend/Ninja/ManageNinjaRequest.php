<?php

namespace App\Http\Requests\Backend\Ninja;

use App\Http\Requests\Request;

/**
 * Class ManageNinjaRequest
 * @package App\Http\Requests\Backend\Access\Ninja
 */
class ManageNinjaRequest extends Request
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
