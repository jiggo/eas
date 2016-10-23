<div class="pull-right mb-10">
    <div class="btn-group">
        <button type="button" class="btn btn-primary btn-xs dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
            {{ trans('menus.backend.ninjas.main') }} <span class="caret"></span>
        </button>

        <ul class="dropdown-menu" skill="menu">
            <li>{{ link_to_route('admin.ninja.index', trans('menus.backend.ninjas.all')) }}</li>

            @permission('manage-ninjas')
                <li>{{ link_to_route('admin.ninja.create', trans('menus.backend.ninjas.create')) }}</li>
            @endauth
        </ul>
    </div><!--btn group-->

</div><!--pull right-->

<div class="clearfix"></div>
