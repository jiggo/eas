<?php

namespace App\Http\Controllers\Frontend;

use App\Http\Controllers\Controller;
use App\Repositories\Backend\Ninja\NinjaRepositoryContract;
use App\Repositories\Backend\Skill\SkillRepositoryContract;
use Illuminate\Http\Request;
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
	 * @var SkillRepositoryContract
	 */
	protected $skills;
	
	/**
	 * @param NinjaRepositoryContract $ninjas
	 * @param SkillRepositoryContract $skills
	 */
	public function __construct(NinjaRepositoryContract $ninjas, SkillRepositoryContract $skills)
	{
		$this->ninjas = $ninjas;
		$this->skills = $skills;
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
        		->withNinjas($this->ninjas->getAllNinjas('name')->pluck('name', 'id'))
        		->withMains($this->ninjas->getAllMains('name')->pluck('name', 'id'))
        		->withSummons($this->ninjas->getAllSummons('name')->pluck('name', 'id'));
    }

    public function combo(Request $request) {
    	$input = $request->all();

    	$combo = $this->ninjas->getCombo($input);    		    
    	
    	return response($combo ,200);
    }
    
    public function getSkills($id, Request $request) {
    	$input = $request->all();    
    	$misteries = $this->ninjas->getAllSkills($id, 1);
    	$chases = $this->ninjas->getAllSkills($id, 2);
    	$standards = $this->ninjas->getAllSkills($id, 3);
    	$passives = $this->ninjas->getAllSkills($id, 4);
    	$skills = array();
    	foreach($misteries->skills as $mistery)
    		$skills["misteries"][] = array('id' => $mistery->id, "text" => $mistery->name);
    	foreach($chases->skills as $chase)
    		$skills["chases"][] = array('id' => $chase->id, "text" => $chase->name);
    	foreach($standards->skills as $standard)
    		$skills["standards"][] = array('id' => $standard->id, "text" => $standard->name);
    	foreach($passives->skills as $passive)
    		$skills["passives"][] = array('id' => $passive->id, "text" => $passive->name);
    	return response($skills ,200);
    }
    
    /**
     * @return \Illuminate\View\View
     */
    public function macros()
    {
        return view('frontend.macros');
    }
}
