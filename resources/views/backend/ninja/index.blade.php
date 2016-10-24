@extends ('backend.layouts.master')

@section ('title', trans('labels.backend.ninjas.management'))

@section('after-styles-end')
    {{ Html::style("css/backend/plugin/datatables/dataTables.bootstrap.min.css") }}
@stop

@section('page-header')
    <h1>
        {{ trans('labels.backend.ninjas.management') }}
        <small>{{ trans('labels.backend.ninjas.active') }}</small>
    </h1>
@endsection

@section('content')
    <div class="box box-success">
        <div class="box-header with-border">
            <h3 class="box-title">{{ trans('labels.backend.ninjas.active') }}</h3>

            <div class="box-tools pull-right">
                @include('backend.ninja.includes.partials.header-buttons')
            </div><!--box-tools pull-right-->
        </div><!-- /.box-header -->

        <div class="box-body">
            <div class="table-responsive">
                <table id="ninjas-table" class="table table-condensed table-hover">
                    <thead>
                        <tr>
                            <th>{{ trans('labels.backend.ninjas.table.id') }}</th>
                            <th>{{ trans('labels.backend.ninjas.table.name') }}</th>
                            <th>{{ trans('labels.backend.ninjas.table.alias') }}</th>
                            <th>{{ trans('labels.backend.ninjas.table.life') }}</th>
                            <th>{{ trans('labels.backend.ninjas.table.attack') }}</th>
                            <th>{{ trans('labels.backend.ninjas.table.defense') }}</th>
                            <th>{{ trans('labels.backend.ninjas.table.ninjutsu') }}</th>
                            <th>{{ trans('labels.backend.ninjas.table.resistance') }}</th>
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
            $('#ninjas-table').DataTable({
                processing: true,
                serverSide: true,
                ajax: {
                    url: '{{ route("admin.ninja.get") }}',
                    type: 'get',
                    data: {status: 1, trashed: false}
                },
                columns: [
                    {data: 'id', name: 'id'},
                    {data: 'name', name: 'name'},
                    {data: 'alias', name: 'alias'},
                    {data: 'life', name: 'life'},      
                    {data: 'attack', name: 'attack'},      
                    {data: 'defense', name: 'defense'},      
                    {data: 'ninjutsu', name: 'ninjutsu'},      
                    {data: 'resistance', name: 'resistance'},                          
                    {data: 'actions', name: 'actions'}
                ],
                order: [[0, "asc"]],
                searchDelay: 500
            });
        });
    </script>
@stop