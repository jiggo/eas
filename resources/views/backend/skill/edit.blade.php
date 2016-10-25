@extends ('backend.layouts.master')

@section ('title', trans('labels.backend.skills.management') . ' | ' . trans('labels.backend.skills.edit'))

@section('page-header')
    <h1>
        {{ trans('labels.backend.skills.management') }}
        <small>{{ trans('labels.backend.skills.edit') }}</small>
    </h1>
@endsection

@section('content')
    {{ Form::model($skill, ['route' => ['admin.skill.update', $skill], 'class' => 'form-horizontal', 'skill' => 'form', 'method' => 'PATCH', 'id' => 'edit-skill']) }}

        <div class="box box-success">
            <div class="box-header with-border">
                <h3 class="box-title">{{ trans('labels.backend.skills.edit') }}</h3>

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
                    {{ Form::label('associated-chases', trans('validation.attributes.backend.skills.associated-chases'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::select('associated-chases[]', $statuses, $chases, ['class' => 'form-control', 'multiple' => true, 'placeholder' => trans('validation.attributes.backend.skills.associated-chases')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->	
                
                <div class="form-group">
                    {{ Form::label('associated-hurts', trans('validation.attributes.backend.skills.associated-hurts'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::select('associated-hurts[]', $statuses, $hurts, ['class' => 'form-control', 'multiple' => true, 'placeholder' => trans('validation.attributes.backend.skills.associated-hurts')]) }}
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
                    {{ Form::submit(trans('buttons.general.crud.update'), ['class' => 'btn btn-success btn-xs']) }}
                </div><!--pull-right-->

                <div class="clearfix"></div>
            </div><!-- /.box-body -->
        </div><!--box-->

    {{ Form::close() }}
@stop