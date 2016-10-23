<?php

namespace App\Http\Controllers\Backend\Ninja;

use App\Models\Ninja\Ninja;
use App\Http\Controllers\Controller;
use Yajra\Datatables\Facades\Datatables;
use App\Http\Requests\Backend\Ninja\StoreNinjaRequest;
use App\Http\Requests\Backend\Ninja\ManageNinjaRequest;
use App\Http\Requests\Backend\Ninja\UpdateNinjaRequest;
use App\Repositories\Backend\Ninja\NinjaRepositoryContract;
use App\Repositories\Backend\Skill\SkillRepositoryContract;

/**
 * Class NinjaController
 */
class NinjaController extends Controller
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
     * @param ManageNinjaRequest $request
     * @return \Illuminate\Contracts\View\Factory|\Illuminate\View\View
     */
    public function index(ManageNinjaRequest $request)
    {
        return view('backend.ninja.index');
    }

	/**
     * @param ManageNinjaRequest $request
     * @return mixed
     */
    public function get(ManageNinjaRequest $request) {
        return Datatables::of($this->ninjas->getForDataTable())            
            ->addColumn('skills', function($ninja) {
                $skills = [];

                if ($ninja->skills()->count() > 0) {
                    foreach ($ninja->skills as $skill) {
                        array_push($skills, $skill->name);
                    }

                    return implode("<br/>", $skills);
                } else {
                    return trans('labels.general.none');
                }
            })
            ->addColumn('actions', function($ninja) {
                return $ninja->action_buttons;
            })
            ->make(true);
    }

	/**
     * @param ManageNinjaRequest $request
     * @return mixed
     */
    public function create(ManageNinjaRequest $request)
    {
        return view('backend.ninja.create')
            ->withSkills($this->skills->getAllSkills('sort', 'asc', true));
    }

	/**
     * @param StoreNinjaRequest $request
     * @return mixed
     */
    public function store(StoreNinjaRequest $request)
    {
        $this->ninjas->create(
           $request
        );
        return redirect()->route('admin.ninja.index')->withFlashSuccess(trans('alerts.backend.ninjas.created'));
    }

	/**
     * @param Ninja $ninja
     * @param ManageNinjaRequest $request
     * @return mixed
     */
    public function edit(Ninja $ninja, ManageNinjaRequest $request)
    {
        return view('backend.ninja.edit')
            ->withNinja($ninja)
            ->withNinjaSkills($ninja->skills->lists('id')->all())
            ->withSkills($this->skills->getAllSkills('sort', 'asc', true));
    }

	/**
     * @param Ninja $ninja
     * @param UpdateNinjaRequest $request
     * @return mixed
     */
    public function update(Ninja $ninja, UpdateNinjaRequest $request)
    {
        $this->ninjas->update($ninja,
            $request
        );
        return redirect()->route('admin.ninja.index')->withFlashSuccess(trans('alerts.backend.ninjas.updated'));
    }

	/**
     * @param Ninja $deletedNinja
     * @param ManageNinjaRequest $request
     * @return mixed
     */
    public function delete(Ninja $deletedNinja, ManageNinjaRequest $request)
    {
        $this->ninjas->delete($deletedNinja);
        return redirect()->back()->withFlashSuccess(trans('alerts.backend.ninjas.deleted_permanently'));
    }
}