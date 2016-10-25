@extends('frontend.layouts.master')

@section('content')
    <div class="row">

		<div class="col-md-10 col-md-offset-1">
			<div class="panel panel-default">
                <div class="panel-heading"><i class="fa fa-home"></i> Calculate Combo </div>
                
                <div class="panel-body">
                	<div class="form-group">
                        {{ Form::label('main', trans('validation.attributes.frontend.main'), ['class' => 'col-md-4 control-label']) }}
                        <div class="col-md-6">
                            {{ Form::select('main', $mains, [], ['class' => 'form-control main', 'placeholder' => trans('validation.attributes.frontend.main')]) }}
                        </div><!--col-md-6-->
                    </div><!--form-group-->
                    
                    <div class="form-group">
                        {{ Form::label('mistery', trans('validation.attributes.frontend.mistery'), ['class' => 'col-md-4 control-label']) }}
                        <div class="col-md-6">
                            {{ Form::select('mistery', [], [], ['class' => 'form-control mistery', 'placeholder' => trans('validation.attributes.frontend.mistery')]) }}
                        </div><!--col-md-6-->
                    </div><!--form-group-->
                    <div class="form-group">
                        {{ Form::label('standard', trans('validation.attributes.frontend.standard'), ['class' => 'col-md-4 control-label']) }}
                        <div class="col-md-6">
                            {{ Form::select('standard', [], [], ['class' => 'form-control standard', 'placeholder' => trans('validation.attributes.frontend.standard')]) }}
                        </div><!--col-md-6-->
                    </div><!--form-group-->
                    <div class="form-group">
                        {{ Form::label('chase', trans('validation.attributes.frontend.chase'), ['class' => 'col-md-4 control-label']) }}
                        <div class="col-md-6">
                            {{ Form::select('chase', [], [], ['class' => 'form-control chase', 'placeholder' => trans('validation.attributes.frontend.chase')]) }}
                        </div><!--col-md-6-->
                    </div><!--form-group-->
                    <div class="form-group">
                        {{ Form::label('ninja1', trans('validation.attributes.frontend.ninja1'), ['class' => 'col-md-4 control-label']) }}
                        <div class="col-md-6">
                            {{ Form::select('ninja1', $ninjas, [], ['class' => 'form-control ninja', 'placeholder' => trans('validation.attributes.frontend.ninja1')]) }}
                        </div><!--col-md-6-->
                    </div><!--form-group-->
                    
                    <div class="form-group">
                        {{ Form::label('ninja2', trans('validation.attributes.frontend.ninja2'), ['class' => 'col-md-4 control-label']) }}
                        <div class="col-md-6">
                            {{ Form::select('ninja2', $ninjas, [], ['class' => 'form-control ninja', 'placeholder' => trans('validation.attributes.frontend.ninja2')]) }}
                        </div><!--col-md-6-->
                    </div><!--form-group-->
                    
                    <div class="form-group">
                        {{ Form::label('ninja3', trans('validation.attributes.frontend.ninja3'), ['class' => 'col-md-4 control-label']) }}
                        <div class="col-md-6">
                            {{ Form::select('ninja3', $ninjas, [], ['class' => 'form-control ninja', 'placeholder' => trans('validation.attributes.frontend.ninja3')]) }}
                        </div><!--col-md-6-->
                    </div><!--form-group-->
                                        
                    <div class="form-group">
                        {{ Form::label('summon', trans('validation.attributes.frontend.summon'), ['class' => 'col-md-4 control-label']) }}
                        <div class="col-md-6">
                            {{ Form::select('summon', $summons, [], ['class' => 'form-control summon', 'placeholder' => trans('validation.attributes.frontend.summon')]) }}
                        </div><!--col-md-6-->
                    </div><!--form-group-->    
                    <div class="form-group">
                    	<button class="calculate btn btn-primary">Calculate combo</button>
                    </div>
                    <h2 id="combo">Max combo: <span>0</span></h2>    
                </div>
            </div>
		</div>
    </div><!--row-->
    <div class="loading hide"><div class="inner-loading"><i class="fa fa-circle-o-notch fa-spin fa-4x"></i><div id="progress"></div></div></div>
@endsection

@section('after-scripts-end')
    <script>
			
		$('.calculate').on('click', function() {
			var data = {};	
			$('.loading').toggleClass('hide');
			$.each($('select'), function(key, select) {
	            switch($(select).attr('name')) {
	            	case 'main':
	                	data.main = {id : $(select).val()};
	                	break;
	            	case 'ninja1':
	                	data.ninja1 = $(select).val();
	                	break;
	            	case 'ninja2':
	                	data.ninja2 = $(select).val();
	                	break;
	            	case 'ninja3':
	                	data.ninja3 = $(select).val();
	                	break;
	            	case 'summon':
	                	data.summon = $(select).val();
	                	break;
	            	case 'mistery':
		            	data.main.mistery = $(select).val();
		            	break;
	            	case 'standard':
		            	data.main.standard = $(select).val();
		            	break;
	            	case 'chase':
		            	data.main.chase = $(select).val();
		            	break;
	            }						
	        });

			$.ajax({
        		url: '{{ route("frontend.ninjas.combo") }}',
        		method: 'GET',
        		data: data,
        		success: function(result) {
            		$('#combo span').html(result);
        		},
        		complete: function() {
        			$('.loading').toggleClass('hide');
        		}
    		});
		});

		$('.main').on('change', function() {
			$('.loading').toggleClass('hide');
			//$('.mistery').select2({data: null});
			var id = $(this).val();
			var baseurl = '{{ config("app.url") }}';
			$.ajax({
        		url: baseurl+"/ninja/"+id+"/skills",
        		method: 'GET',
        		success: function(result) {
        			$(".mistery").html("<option value=''>{{ trans('validation.attributes.frontend.mistery') }}</option>"); 
            		$('.mistery').select2({
                		data: result.misteries
                	});   
            		$(".standard").html("<option value=''>{{ trans('validation.attributes.frontend.standard') }}</option>"); 
            		$('.standard').select2({
                		data: result.standards
                	}); 
            		$(".chase").html("<option value=''>{{ trans('validation.attributes.frontend.chase') }}</option>"); 
            		$('.chase').select2({
                		data: result.chases
                	});              	            		
        		},
        		complete: function() {
        			$('.loading').toggleClass('hide');
        		}
    		});
		});
    </script>
@stop