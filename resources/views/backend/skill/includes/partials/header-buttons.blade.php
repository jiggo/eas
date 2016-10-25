<div class="pull-right mb-10">
    <div class="btn-group">
        <button type="button" class="btn btn-primary btn-xs dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
            {{ trans('menus.backend.skills.main') }} <span class="caret"></span>
        </button>

        <ul class="dropdown-menu" skill="menu">
            <li>{{ link_to_route('admin.skill.index', trans('menus.backend.skills.all')) }}</li>

            @permission('manage-skills')
                <li>{{ link_to_route('admin.skill.create', trans('menus.backend.skills.create')) }}</li>
            @endauth
        </ul>
    </div><!--btn group-->

</div><!--pull right-->

<div class="clearfix"></div>
