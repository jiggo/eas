<?php

namespace App\Models\Skill;

/**
 * Class SkillAttribute
 * @package App\Models\Access\Skill
 */
trait SkillAttribute
{

	/**
	 * @return string
	 */
	public function getTypeLabelAttribute()
	{
		$label = "";
		switch($this->type_id) {
			case 1:
				$label = "<label class='label label-success'>".trans('labels.general.mistery')."</label>";
				break;
			case 2:
				$label = "<label class='label label-warning'>".trans('labels.general.chase')."</label>";
				break;
			case 3:
				$label = "<label class='label label-primary'>".trans('labels.general.standard')."</label>";
				break;				
			case 4:
				$label = "<label class='label label-danger'>".trans('labels.general.passive')."</label>";
				break;
		}
		
		return $label;
	}
	
	/**
	 * @return string
	 */
	public function getNinjaLabelAttribute()
	{	
		$label = "";
		
		foreach($this->ninja as $ninja) {
			$label .= "<label class='label label-default' data-search='".$ninja->name."'>".$ninja->name."</label> ";
		}
		
		return $label;
	}
	
    /**
     * @return string
     */
    public function getEditButtonAttribute()
    {
        return '<a href="' . route('admin.skill.edit', $this) . '" class="btn btn-xs btn-primary"><i class="fa fa-pencil" data-toggle="tooltip" data-placement="top" title="' . trans('buttons.general.crud.edit') . '"></i></a> ';
    }
	/**
     * @return string
     */
    public function getDeletePermanentlyButtonAttribute()
    {
        return '<a href="' . route('admin.skill.delete-permanently', $this) . '" name="delete_skill_perm" class="btn btn-xs btn-danger"><i class="fa fa-trash" data-toggle="tooltip" data-placement="top" title="' . trans('buttons.backend.skills.delete_permanently') . '"></i></a> ';
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
   
