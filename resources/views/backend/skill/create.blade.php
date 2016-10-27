@extends ('backend.layouts.master')

@section ('title', trans('labels.backend.skills.management') . ' | ' . trans('labels.backend.skills.create'))

@section('page-header')
    <h1>
        {{ trans('labels.backend.skills.management') }}
        <small>{{ trans('labels.backend.skills.create') }}</small>
    </h1>
@endsection

@section('content')
    {{ Form::open(['route' => 'admin.skill.store', 'class' => 'form-horizontal', 'skill' => 'form', 'method' => 'POST', 'id' => 'create-skill']) }}

        <div class="box box-success">
            <div class="box-header with-border">
                <h3 class="box-title">{{ trans('labels.backend.skills.create') }}</h3>

                <div class="box-tools pull-right">
                    @include('backend.skill.includes.partials.header-buttons')
                </div><!--box-tools pull-right-->
            </div><!-- /.box-header -->

            <div class="box-body">
                <div class="form-group">
                    {{ Form::label('name', trans('validation.attributes.backend.skills.name'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::text('name', null, ['class' => 'form-control', 'placeholder' => trans('validation.attributes.backend.skills.name')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->	
                <div class="form-group">
                    {{ Form::label('hurt_num', trans('validation.attributes.backend.skills.hurt_num'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::text('hurt_num', null, ['class' => 'form-control', 'placeholder' => trans('validation.attributes.backend.skills.hurt_num')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->	
                <div class="form-group">
                    {{ Form::label('type_id', trans('validation.attributes.backend.skills.type_id'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::select('type_id', $skill_types, null, ['class' => 'form-control', 'placeholder' => trans('validation.attributes.backend.skills.type_id')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->
                <div class="form-group">
                    {{ Form::label('associated-chases', trans('validation.attributes.backend.skills.associated-chases'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::select('associated-chases[]', $statuses,  'all', ['class' => 'form-control', 'multiple' => true, 'placeholder' => trans('validation.attributes.backend.skills.associated-chases')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->	
                
                <div class="form-group">
                    {{ Form::label('associated-hurts', trans('validation.attributes.backend.skills.associated-hurts'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::select('associated-hurts[]', $statuses, 'all', ['class' => 'form-control', 'multiple' => true, 'placeholder' => trans('validation.attributes.backend.skills.associated-hurts')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->	
                			
            </div><!-- /.box-body -->
        </div><!--box-->

        <div class="box box-success">
            <div class="box-body">
                <div class="pull-left">
                    {{ link_to_route('admin.skill.index', trans('buttons.general.cancel'), [], ['class' => 'btn btn-danger btn-xs']) }}
                </div><!--pull-left-->

                <div class="pull-right">
                    {{ Form::submit(trans('buttons.general.crud.create'), ['class' => 'btn btn-success btn-xs']) }}
                </div><!--pull-right-->

                <div class="clearfix"></div>
            </div><!-- /.box-body -->
        </div><!--box-->

    {{ Form::close() }}
@stop