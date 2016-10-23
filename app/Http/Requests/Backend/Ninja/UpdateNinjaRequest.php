<?php

namespace App\Http\Requests\Backend\Ninja;

use App\Http\Requests\Request;

/**
 * Class UpdateNinjaRequest
 * @package App\Http\Requests\Backend\Ninja
 */
class UpdateNinjaRequest extends Request
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
            'name'  => 'required',
        ];
    }
}
