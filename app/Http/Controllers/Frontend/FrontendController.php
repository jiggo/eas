<?php

namespace App\Http\Controllers\Frontend;

use App\Http\Controllers\Controller;
use App\Repositories\Backend\Ninja\NinjaRepositoryContract;

/**
 * Class FrontendController
 * @package App\Http\Controllers
 */
class FrontendController extends Controller
{
	
	/**
	 * @var NinjaRepositoryContract
	 */
	protected $ninjas;
	
	/**
	 * @param NinjaRepositoryContract $ninjas
	 */
	public function __construct(NinjaRepositoryContract $ninjas)
	{
		$this->ninjas = $ninjas;
	}
	
    /**
     * @return \Illuminate\View\View
     */
    public function index()
    {
        javascript()->put([
            'test' => 'it works!',
        ]);

        return view('frontend.index')
        		->withNinjas($this->ninjas->getAllNinjas());
    }

    /**
     * @return \Illuminate\View\View
     */
    public function macros()
    {
        return view('frontend.macros');
    }
}
