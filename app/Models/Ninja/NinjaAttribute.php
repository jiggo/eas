<?php

namespace App\Models\Ninja;

/**
 * Class NinjaAttribute
 * @package App\Models\Access\Ninja
 */
trait NinjaAttribute
{

    /**
     * @return string
     */
    public function getEditButtonAttribute()
    {
        return '<a href="' . route('admin.ninja.edit', $this) . '" class="btn btn-xs btn-primary"><i class="fa fa-pencil" data-toggle="tooltip" data-placement="top" title="' . trans('buttons.general.crud.edit') . '"></i></a> ';
    }
	/**
     * @return string
     */
    public function getDeletePermanentlyButtonAttribute()
    {
        return '<a href="' . route('admin.ninja.delete-permanently', $this) . '" name="delete_ninja_perm" class="btn btn-xs btn-danger"><i class="fa fa-trash" data-toggle="tooltip" data-placement="top" title="' . trans('buttons.backend.ninjas.delete_permanently') . '"></i></a> ';
    }

    /**
     * @return string
     */
    public function getActionButtonsAttribute()
    {
        return
            $this->getEditButtonAttribute() .
            $this->getDeletePermanentlyButtonAttribute();
    }
}
