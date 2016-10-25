@extends ('backend.layouts.master')

@section ('title', trans('labels.backend.skills.management'))

@section('after-styles-end')
    {{ Html::style("css/backend/plugin/datatables/dataTables.bootstrap.min.css") }}
@stop

@section('page-header')
    <h1>
        {{ trans('labels.backend.skills.management') }}
        <small>{{ trans('labels.backend.skills.active') }}</small>
    </h1>
@endsection

@section('content')
    <div class="box box-success">
        <div class="box-header with-border">
            <h3 class="box-title">{{ trans('labels.backend.skills.active') }}</h3>

            <div class="box-tools pull-right">
                @include('backend.skill.includes.partials.header-buttons')
            </div><!--box-tools pull-right-->
        </div><!-- /.box-header -->

        <div class="box-body">
            <div class="table-responsive">
                <table id="skills-table" class="table table-condensed table-hover">
                    <thead>
                        <tr>
                            <th>{{ trans('labels.backend.skills.table.id') }}</th>
                            <th style="width: 40%;">{{ trans('labels.backend.skills.table.name') }}</th>
                            <th>{{ trans('labels.backend.skills.table.hurt_num') }}</th>
                            <th>{{ trans('labels.backend.skills.table.type') }}</th>
                            <th>{{ trans('labels.backend.skills.table.owner') }}</th>                                  
                            <th>{{ trans('labels.general.actions') }}</th>
                        </tr>
                    </thead>
                </table>
            </div><!--table-responsive-->
        </div><!-- /.box-body -->
    </div><!--box-->

    <div class="box box-info">
        <div class="box-header with-border">
            <h3 class="box-title">{{ trans('history.backend.recent_history') }}</h3>
            <div class="box-tools pull-right">
                <button class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i></button>
            </div><!-- /.box tools -->
        </div><!-- /.box-header -->
        <div class="box-body">
            {!! history()->renderType('User') !!}
        </div><!-- /.box-body -->
    </div><!--box box-success-->
@stop

@section('after-scripts-end')
    {{ Html::script("js/backend/plugin/datatables/jquery.dataTables.min.js") }}
    {{ Html::script("js/backend/plugin/datatables/dataTables.bootstrap.min.js") }}

    <script>
        $(function() {
            $('#skills-table').DataTable({
                processing: true,
                serverSide: true,
                ajax: {
                    url: '{{ route("admin.skill.get") }}',
                    type: 'get',
                    data: {status: 1, trashed: false}
                },
                columns: [
                    {data: 'id', name: 'id'},
                    {data: 'name', name: 'name'},
                    {data: 'hurt_num', name: 'hurt_num'},
                    {data: 'type_id', name: 'type_id'},
                    {data: 'owner', name: 'owner'},                                     
                    {data: 'actions', name: 'actions'}
                ],
                order: [[1, "asc"]],
                searchDelay: 500
            });
        });
    </script>
@stop