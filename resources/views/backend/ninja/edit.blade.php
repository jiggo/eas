@extends ('backend.layouts.master')

@section ('title', trans('labels.backend.ninjas.management') . ' | ' . trans('labels.backend.ninjas.edit'))

@section('page-header')
    <h1>
        {{ trans('labels.backend.ninjas.management') }}
        <small>{{ trans('labels.backend.ninjas.edit') }}</small>
    </h1>
@endsection

@section('content')
    {{ Form::model($ninja, ['route' => ['admin.ninja.update', $ninja], 'class' => 'form-horizontal', 'ninja' => 'form', 'method' => 'PATCH', 'id' => 'edit-ninja']) }}

        <div class="box box-success">
            <div class="box-header with-border">
                <h3 class="box-title">{{ trans('labels.backend.ninjas.edit') }}</h3>

                <div class="box-tools pull-right">
                    @include('backend.ninja.includes.partials.header-buttons')
                </div><!--box-tools pull-right-->
            </div><!-- /.box-header -->

            <div class="box-body">
                <div class="form-group">
                    {{ Form::label('name', trans('validation.attributes.backend.ninjas.name'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::text('name', null, ['class' => 'form-control', 'placeholder' => trans('validation.attributes.backend.ninjas.name')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->

				<div class="form-group">
                    {{ Form::label('alias', trans('validation.attributes.backend.ninjas.alias'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::text('alias', null, ['class' => 'form-control', 'placeholder' => trans('validation.attributes.backend.ninjas.alias')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->
                
                <div class="form-group">
                    {{ Form::label('attribute', trans('validation.attributes.backend.ninjas.attribute'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::text('attribute', null, ['class' => 'form-control', 'placeholder' => trans('validation.attributes.backend.ninjas.attribute')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->
                
                <div class="form-group">
                    {{ Form::label('chakra', trans('validation.attributes.backend.ninjas.chakra'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::number('chakra', null, ['class' => 'form-control', 'placeholder' => trans('validation.attributes.backend.ninjas.chakra')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->
                
                <div class="form-group">
                    {{ Form::label('life', trans('validation.attributes.backend.ninjas.life'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::number('life', null, ['class' => 'form-control', 'placeholder' => trans('validation.attributes.backend.ninjas.life')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->
                
                <div class="form-group">
                    {{ Form::label('attack', trans('validation.attributes.backend.ninjas.attack'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::number('attack', null, ['class' => 'form-control', 'placeholder' => trans('validation.attributes.backend.ninjas.attack')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->
                
                <div class="form-group">
                    {{ Form::label('defense', trans('validation.attributes.backend.ninjas.defense'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::number('defense', null, ['class' => 'form-control', 'placeholder' => trans('validation.attributes.backend.ninjas.defense')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->
                
                <div class="form-group">
                    {{ Form::label('ninjutsu', trans('validation.attributes.backend.ninjas.ninjutsu'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::number('ninjutsu', null, ['class' => 'form-control', 'placeholder' => trans('validation.attributes.backend.ninjas.ninjutsu')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->
                
                <div class="form-group">
                    {{ Form::label('resistance', trans('validation.attributes.backend.ninjas.resistance'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::number('resistance', null, ['class' => 'form-control', 'placeholder' => trans('validation.attributes.backend.ninjas.resistance')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->
                
                <div class="form-group">
                    {{ Form::label('human', trans('validation.attributes.backend.ninjas.human'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::checkbox('human',  $ninja->human, ['class' => 'form-control', 'placeholder' => trans('validation.attributes.backend.ninjas.resistance')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->
                
                <div class="form-group">
                    {{ Form::label('summon_color', trans('validation.attributes.backend.ninjas.summon_color'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::text('summon_color', null, ['class' => 'form-control', 'placeholder' => trans('validation.attributes.backend.ninjas.summon_color')]) }}
                    </div><!--col-lg-10-->
                </div><!--form control-->
                
                <div class="form-group">
                    {{ Form::label('associated-skills', trans('validation.attributes.backend.ninjas.associated_skills'), ['class' => 'col-lg-2 control-label']) }}

                    <div class="col-lg-10">
                        {{ Form::select('associated-skills[]', $skills, $ninja_skills, ['class' => 'form-control', 'multiple' => true]) }}
                    </div><!--col-lg-3-->
                </div><!--form control-->
            </div><!-- /.box-body -->
        </div><!--box-->

        <div class="box box-success">
            <div class="box-body">
                <div class="pull-left">
                    {{ link_to_route('admin.ninja.index', trans('buttons.general.cancel'), [], ['class' => 'btn btn-danger btn-xs']) }}
                </div><!--pull-left-->

                <div class="pull-right">
                    {{ Form::submit(trans('buttons.general.crud.update'), ['class' => 'btn btn-success btn-xs']) }}
                </div><!--pull-right-->

                <div class="clearfix"></div>
            </div><!-- /.box-body -->
        </div><!--box-->

    {{ Form::close() }}
@stop