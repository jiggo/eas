@extends('frontend.layouts.master')

@section('after-styles-end')
    {{ Html::style("css/backend/plugin/datatables/dataTables.bootstrap.min.css") }}
@stop

@section('content')
	<style>
		.panel-body.source {
			max-height: 500px;
			overflow-y: scroll;
		}
		
		#dest_fixed, #dest_variable, #main, #summon {
			height: 220px;
			overflow-y: scroll;
		}
		
		.ui-widget-content {
			margin: 10px 0;
			padding: 5px;
		}
		
	</style>
    <div class="row">

		<div class="col-md-10 col-md-offset-1">
		
			<div class="row">
				<div class="col-md-4">
				    <div class="panel panel-default">
		                <div class="panel-heading">Drag ninjas from here</div>
		                
		                <div class="panel-body source ui-helper-clearfix">
		                	<ul id="source" class="source ui-helper-reset ui-helper-clearfix">
		                		@foreach($ninjas as $id => $ninja)
		                			<li class="ui-widget-content ui-corner-tr" data-ninjaid="{{$id}}">{{$ninja}}</li>
		                		@endforeach
		                	</ul>
		                </div>
		            </div>
	            </div>
	            
	            <div class="col-md-4">
		            <div class="panel panel-default">
		                <div class="panel-heading">Fixed Ninjas </div>
		                		                
		                <div id="dest_fixed" class="panel-body ui-state-default dest">		                			               
		                </div>
		            </div>
	            </div>
	            
	            <div class="col-md-4">
		            <div class="panel panel-default">
		                <div class="panel-heading">Main </div>
		                		                
		                <div id="main" class="panel-body">	
				            <div class="form-group row">
		                        <div class="col-md-12">
		                            {{ Form::select('main', $mains, [], ['class' => 'form-control main', 'placeholder' => trans('validation.attributes.frontend.main')]) }}
		                        </div><!--col-md-8-->
		                    </div><!--form-group row-->
		                    
		                    <div class="form-group row">
		                        <div class="col-md-12">
		                            {{ Form::select('mistery', [], [], ['class' => 'form-control mistery', 'placeholder' => trans('validation.attributes.frontend.mistery')]) }}
		                        </div><!--col-md-8-->
		                    </div><!--form-group row-->
		                    <div class="form-group row">
		                        <div class="col-md-12">
		                            {{ Form::select('standard', [], [], ['class' => 'form-control standard', 'placeholder' => trans('validation.attributes.frontend.standard')]) }}
		                        </div><!--col-md-8-->
		                    </div><!--form-group row-->
		                    <div class="form-group row">
		                        <div class="col-md-12">
		                            {{ Form::select('chase', [], [], ['class' => 'form-control chase', 'placeholder' => trans('validation.attributes.frontend.chase')]) }}
		                        </div><!--col-md-8-->
		                    </div><!--form-group row-->	                			               
		                </div>
		            </div>
	            </div>
	            
	            <div class="col-md-4">
		            <div class="panel panel-default">
		                <div class="panel-heading">Variable Ninjas </div>
		                		                
		                <div id="dest_variable" class="panel-body ui-state-default dest">		                			               
		                </div>
		            </div>
	            </div>
	            
	            <div class="col-md-4">
		            <div class="panel panel-default">
		                <div class="panel-heading">Summon </div>
		                		                
		                <div id="summon" class="panel-body">		
			                <div class="form-group row">
		                        <div class="col-md-12">
		                            {{ Form::select('summon', $summons, [], ['class' => 'form-control summon', 'placeholder' => trans('validation.attributes.frontend.summon')]) }}
		                        </div><!--col-md-8-->
		                    </div><!--form-group row-->                			               
		                </div>
		            </div>
	            </div>
	            
            </div>
            
            <div class="form-group">
            	<button class="calculate-team btn btn-primary">Calculate teams</button>
            </div>
            <div class="panel panel-default">  
            	<div class="panel-heading"><i class="fa fa-home"></i> Teams </div> 
            	<div class="panel-body">
                    <div class="table-responsive">
		                <table id="teams-table" class="table table-condensed table-hover">
		                    <thead>
		                        <tr>
		                            <th style="width:20%;">{{ trans('labels.backend.ninjas.table.team') }}</th>		                            
		                            <th>{{ trans('labels.backend.ninjas.table.life') }}</th>
		                            <th>{{ trans('labels.backend.ninjas.table.attack') }}</th>
		                            <th>{{ trans('labels.backend.ninjas.table.defense') }}</th>
		                            <th>{{ trans('labels.backend.ninjas.table.ninjutsu') }}</th>
		                            <th>{{ trans('labels.backend.ninjas.table.resistance') }}</th>
		                            <th style="width:10%;">{{ trans('labels.backend.ninjas.table.combo') }}</th>
		                            <th>{{ trans('labels.general.actions') }}</th>
		                        </tr>
		                    </thead>
		                </table>
		            </div><!--table-responsive-->
		    	</div>
		   	</div>
		   	<!-- 
			<div class="panel panel-default">
                <div class="panel-heading"><i class="fa fa-home"></i> Calculate Combo </div>
                
                <div class="panel-body">
                	<div class="form-group row">
                        {{ Form::label('main', trans('validation.attributes.frontend.main'), ['class' => 'col-md-3 control-label']) }}
                        <div class="col-md-8">
                            {{ Form::select('main', $mains, [], ['class' => 'form-control main', 'placeholder' => trans('validation.attributes.frontend.main')]) }}
                        </div>
                    </div>
                    
                    <div class="form-group row">
                        {{ Form::label('mistery', trans('validation.attributes.frontend.mistery'), ['class' => 'col-md-3 control-label']) }}
                        <div class="col-md-8">
                            {{ Form::select('mistery', [], [], ['class' => 'form-control mistery', 'placeholder' => trans('validation.attributes.frontend.mistery')]) }}
                        </div>
                    </div>
                    <div class="form-group row">
                        {{ Form::label('standard', trans('validation.attributes.frontend.standard'), ['class' => 'col-md-3 control-label']) }}
                        <div class="col-md-8">
                            {{ Form::select('standard', [], [], ['class' => 'form-control standard', 'placeholder' => trans('validation.attributes.frontend.standard')]) }}
                        </div>
                    </div>
                    <div class="form-group row">
                        {{ Form::label('chase', trans('validation.attributes.frontend.chase'), ['class' => 'col-md-3 control-label']) }}
                        <div class="col-md-8">
                            {{ Form::select('chase', [], [], ['class' => 'form-control chase', 'placeholder' => trans('validation.attributes.frontend.chase')]) }}
                        </div>
                    </div>
                    <div class="form-group row">
                        {{ Form::label('ninja1', trans('validation.attributes.frontend.ninja1'), ['class' => 'col-md-3 control-label']) }}
                        <div class="col-md-8">
                            {{ Form::select('ninja1', $ninjas, [], ['class' => 'form-control ninja', 'placeholder' => trans('validation.attributes.frontend.ninja1')]) }}
                        </div>
                    </div>
                    
                    <div class="form-group row">
                        {{ Form::label('ninja2', trans('validation.attributes.frontend.ninja2'), ['class' => 'col-md-3 control-label']) }}
                        <div class="col-md-8">
                            {{ Form::select('ninja2', $ninjas, [], ['class' => 'form-control ninja', 'placeholder' => trans('validation.attributes.frontend.ninja2')]) }}
                        </div>
                    </div>
                    
                    <div class="form-group row">
                        {{ Form::label('ninja3', trans('validation.attributes.frontend.ninja3'), ['class' => 'col-md-3 control-label']) }}
                        <div class="col-md-8">
                            {{ Form::select('ninja3', $ninjas, [], ['class' => 'form-control ninja', 'placeholder' => trans('validation.attributes.frontend.ninja3')]) }}
                        </div>
                    </div>
                                        
                    <div class="form-group row">
                        {{ Form::label('summon', trans('validation.attributes.frontend.summon'), ['class' => 'col-md-3 control-label']) }}
                        <div class="col-md-8">
                            {{ Form::select('summon', $summons, [], ['class' => 'form-control summon', 'placeholder' => trans('validation.attributes.frontend.summon')]) }}
                        </div>
                    </div>
                    <div class="form-group">
                    	<button class="calculate-combo btn btn-primary">Calculate combo</button>
                    </div>
                    <h2 id="combo">Max combo: <span>0</span></h2>    
                </div>
            </div>
             -->

		</div>
    </div><!--row-->
    <div class="loading hide"><div class="inner-loading"><i class="fa fa-circle-o-notch fa-spin fa-4x"></i><div id="progress"></div></div></div>
@endsection

@section('after-scripts-end')
    {{ Html::script("js/backend/plugin/datatables/jquery.dataTables.min.js") }}
    {{ Html::script("js/backend/plugin/datatables/dataTables.bootstrap.min.js") }}
    <script>
    	var t;
    	
		$(document).ready(function() {
	    	t = $('#teams-table').DataTable({
		    	orderMulti: true
	    	});
		});
		$( function() {
	 
		    // There's the source and the dest
	    	var $source = $( "#source" ),
	    		$dest_fixed = $('#dest_fixed'),
	    		$dest_variable = $('#dest_variable');
	
	    	// Let the source items be draggable
	        $( "li", $source ).draggable({
	          cancel: "a.ui-icon", // clicking an icon won't initiate dragging
	          revert: "invalid", // when not dropped, the item will revert back to its initial position
	          containment: "document",
	          helper: "clone",
	          cursor: "move"
	        });
	
	     	// Let the dest be droppable, accepting the source items
	        $dest_fixed.droppable({
	          accept: "#source > li, #dest_variable > ul > li",
	          classes: {
	            "ui-droppable-active": "ui-state-highlight"
	          },
	          drop: function( event, ui ) {
	            selectNinja( $(event.target), ui.draggable );
	          }
	        });
	     	// Let the dest be droppable, accepting the source items
	        $dest_variable.droppable({
	          accept: "#source > li, #dest_fixed > ul > li",
	          classes: {
	            "ui-droppable-active": "ui-state-highlight"
	          },
	          drop: function( event, ui ) {
	        	 selectNinja( $(event.target), ui.draggable );
	          }
	        });
	        
	     	// Let the source be droppable as well, accepting items from the dest
	        $source.droppable({
	          accept: ".dest li",
	          classes: {
	            "ui-droppable-active": "custom-state-active"
	          },
	          drop: function( event, ui ) {
	            unselectNinja( ui.draggable );
	          }
	        });
	
	        function selectNinja( $target, $item ) {
	            $item.fadeOut(function() {
	              var $list = $( "ul", $target ).length ?
	                $( "ul", $target ) :
	                $( "<ul class='source ui-helper-reset'/>" ).appendTo( $target );
		                
	              $item.appendTo( $list ).fadeIn();
	                
	            });
	        }
	
	        function unselectNinja( $item ) {
	            $item.fadeOut(function() {
	              $item               
	                .appendTo( $source )
	                .fadeIn();
	            });
	        }
            
		});

		$('.calculate-team').on('click', function() {
			var data = {fixed: [], variable: [], main: {}, summon: {}};	
			t.clear();
			$('.loading').toggleClass('hide');
			$.each($('#dest_fixed li'), function(key, elem) {
	            data.fixed.push($(elem).attr('data-ninjaid'));		
	        });
	        var summon = $('select[name="summon"]').val();
	        if(summon != '')
	        	data.summon = summon;	        
			
			var main =  $('select[name="main"]').val();
			if(main != '') {
				data.main.id =  $('select[name="main"]').val();
				data.main.mistery = $('select[name="mistery"]').val();
				data.main.standard = $('select[name="standard"]').val();
				data.main.chase = $('select[name="chase"]').val();
			}
			
			$.each($('#dest_variable li'), function(key, elem) {
	            data.variable.push($(elem).attr('data-ninjaid'));		
	        });
			$.ajax({
        		url: '{{ route("frontend.ninjas.team") }}',
        		method: 'GET',
        		data: data,
        		success: function(result) {
            		$.each(result, function(key, value) {
                		var team = '',
                			life = 0,
                			attack = 0,
                			defense = 0,
                			ninjutsu = 0,
                			resistance = 0;
            			$.each(value.team, function(key, ninja) {
        					team += ninja.name+ '<br />';
        					life += ninja.life;
        					attack += ninja.attack;
        					defense += ninja.defense;
        					ninjutsu += ninja.ninjutsu;
        					resistance += ninja.resistance; 
            			});

            			t.row.add( [
           			             team,
           			          	 life,
           			          	 attack,
           			             defense,
           			             ninjutsu,
           			             resistance,
           			             value.combo,
           			             ''
           			         ] ).draw( false );
            		});
            		t.draw();
        		},
        		error: function(error) {            		
            		alert(error.responseText);
        		},
        		complete: function() {
        			$('.loading').toggleClass('hide');
        		}
    		});
		});
		
		$('.calculate-combo').on('click', function() {
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