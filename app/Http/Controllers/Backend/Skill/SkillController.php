<?php

namespace App\Http\Controllers\Backend\Skill;

use App\Models\Skill\Skill;
use App\Models\SkillType\SkillType;
use App\Http\Controllers\Controller;
use Yajra\Datatables\Facades\Datatables;
use App\Http\Requests\Backend\Skill\StoreSkillRequest;
use App\Http\Requests\Backend\Skill\ManageSkillRequest;
use App\Http\Requests\Backend\Skill\UpdateSkillRequest;
use App\Repositories\Backend\Skill\SkillRepositoryContract;
use App\Repositories\Backend\Status\StatusRepositoryContract;
/**
 * Class SkillController
 */
class SkillController extends Controller
{

    /**
     * @var SkillRepositoryContract
     */
    protected $skills;
    
    /**
     * @var StatusRepositoryContract
     */
    protected $statuses;
    
    /**
     * @param SkillRepositoryContract $skills
     * @param StatusRepositoryContract $statuses
     */
    public function __construct(SkillRepositoryContract $skills, StatusRepositoryContract $statuses)
    {
        $this->skills = $skills;
        $this->statuses = $statuses;
    }

	/**
     * @param ManageSkillRequest $request
     * @return \Illuminate\Contracts\View\Factory|\Illuminate\View\View
     */
    public function index(ManageSkillRequest $request)
    {
        return view('backend.skill.index');
    }

	/**
     * @param ManageSkillRequest $request
     * @return mixed
     */
    public function get(ManageSkillRequest $request) {
        return Datatables::of($this->skills->getForDataTable())       
	        ->editColumn('type_id', function($skill) {
	        	return $skill->type_label;
	        })
	        ->editColumn('owner', function($skill) {
	        	return $skill->ninja_label;
	        })
            ->addColumn('actions', function($skill) {
                return $skill->action_buttons;
            })
            ->make(true);
    }

	/**
     * @param ManageSkillRequest $request
     * @return mixed
     */
    public function create(ManageSkillRequest $request)
    {
        return view('backend.skill.create')
            ->withStatuses($this->statuses->getAllStatuses('id', 'asc', true)->pluck('name', 'id'))
        	->withSkillTypes(SkillType::all()->pluck('name', 'id'));
    }

	/**
     * @param StoreSkillRequest $request
     * @return mixed
     */
    public function store(StoreSkillRequest $request)
    {
        $this->skills->create($request);
        return redirect()->route('admin.skill.index')->withFlashSuccess(trans('alerts.backend.skills.created'));
    }

	/**
     * @param Skill $skill
     * @param ManageSkillRequest $request
     * @return mixed
     */
    public function edit(Skill $skill, ManageSkillRequest $request)
    {
        return view('backend.skill.edit')
            ->withSkill($skill)
            ->withChases($skill->chases->lists('id')->all())
            ->withHurts($skill->hurts->lists('id')->all())
            ->withStatuses($this->statuses->getAllStatuses('id', 'asc', true)->pluck('name', 'id'))
        	->withSkillTypes(SkillType::all()->pluck('name', 'id'));
    }

	/**
     * @param Skill $skill
     * @param UpdateSkillRequest $request
     * @return mixed
     */
    public function update(Skill $skill, UpdateSkillRequest $request)
    {
        $this->skills->update(
        		$skill,
        		$request->except(['associated-chases', 'associated-hurts']),        		
            	$request->only(['associated-chases', 'associated-hurts']));
        return redirect()->back()->withFlashSuccess(trans('alerts.backend.skills.updated'));
    }

	/**
     * @param Skill $skill
     * @param ManageSkillRequest $request
     * @return mixed
     */
    public function delete(Skill $skill, ManageSkillRequest $request)
    {
        $this->skills->delete($skill);
        return redirect()->back()->withFlashSuccess(trans('alerts.backend.skills.deleted_permanently'));
    }
}