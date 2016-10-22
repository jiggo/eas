/**
 * Load multiple json files, with progress.
 *
 * Example usage:
 *
 * jQuery.getMultipleJSON('file1.json', 'file2.json')
 *   .progress(function(percent, count, total){})
 *   .fail(function(jqxhr, textStatus, error){})
 *   .done(function(file1, file2){})
 * ;
 */
$.getMultipleJSON = function(){
  var 
    num = 0,
    def = $.Deferred(),
  	map = []
  	returnData = [];
  
  	map = $.map(arguments[0], function(jsonfile){    	
    	return $.getJSON(jsonfile).then(function(){
    		return arguments;
    	});
    });
  
  
  	$.when.apply($, map)
  		.fail(function(){ def.rejectWith(def, arguments); })
  		.done(function(){
  			$.each(arguments, function(index, response){  		
  				returnData.push(response[0]);
  			});  			
  			def.resolveWith(def, [returnData]);  			
  		});  		
  	return def;
};

//////////////////////////////////////////////////////////////

function jsonLoop(baseArray) {
	$.getMultipleJSON(baseArray)
	.done(function(data){
		 ninjas = data;
		 
		 $.each( ninjas, function( ninja_key, ninja ) {

			  console.log("======================="+ninja.name +"=========================\n");	
			  console.log("======================= Mistery =========================\n");
			  considered = [];
			  high_combo_queue = [];
			  combos = 1;			  
			  hits = 0;
			  if(typeof ninja.mistery != 'undefined') {				   
				  path[ninja_key] = $.merge([ninja.name], findNext(ninja, ninja.mistery));				 				 			  
			  }
			  if(hits >= 10) {
				  $.each( high_combo_queue, function( key, value ) {
					  combos++;
					  console.log("Triggered high_combo from: " +ninjas[value.ninja_key].name+" ["+ninjas[value.ninja_key].chases[value.chase_key]+"]");
				  });
			  }
			  //console.log("Hits: "+hits+"\n");
			  console.log("Combos: "+(combos)+"\n");
			  if(combos > highest_combo)
					highest_combo = combos;
			  
			  console.log("======================= Standard =========================\n");
			  considered = [];
			  high_combo_queue = [];
			  combos = 1;
			  hits = 0;
			  if(typeof ninja.standard != 'undefined') {
				  $.merge([ninja.name], findNext(ninja, ninja.standard)); 
			  }			  
	
			  if(hits >= 10) {
				  $.each( high_combo_queue, function( key, value ) {
					  combos++;					  
					  console.log("Triggered high_combo from: " +ninjas[value.ninja_key].name+" ["+ninjas[value.ninja_key].chases[value.chase_key]+"]");
				  });
			  }
			  //console.log("Hits: "+hits+"\n");
			  console.log("Combos: "+(combos)+"\n");
			  if(combos > highest_combo)
					highest_combo = combos;
		  });
		 
		 $('#highest_combo span').html(highest_combo);
		 if(i < baseArray.length) {
			 //console.log('here');
			 i++;
			 baseArray.rotate(1);
			 jsonLoop(baseArray);
		 }

	});
}

var main = first = second = third = summon = "";
var i = 0;
var items = [];
var ninjas;
var path = [];
var considered = [];
var high_combo_queue = [];
var hits = 0;
var combos = 1;
var highest_combo = 1;
var very_highest_combo = 1;

$('select').on('change', function() {
	i = 0;
	highest_combo = 1;
	switch($(this).attr("name")) {
		case 'main':
			main = 'characters/'+$(this).val()+'.json';
			break;
		case 'first':
			first = 'characters/'+$(this).val()+'.json';
			break;
		case 'second':
			second = 'characters/'+$(this).val()+'.json';
			break;
		case 'third':
			third = 'characters/'+$(this).val()+'.json';
			break;
		case 'summon':
			summon = 'characters/'+$(this).val()+'.json';
			break;
	}
	
	var baseArray = [main, first, second, third, summon];

	jsonLoop(baseArray);
			
});


function findNext(current, attack) {	

	var toReturn = [];
	var summonTimes = 0;
	if(attack.creates.length == 0) {
		return toReturn;
	}
	
	// Loop over ninjas
	$.each( ninjas, function( ninja_key, ninja ) {
		//if(current.name != ninja.name) {
			// Loop over input's creations
			$.each( attack.creates, function( create_key, create ) {				
				// Loop over ninja's chases
				$.each( ninja.chases, function( chase_key, chase ) {
					// Loop over ninja's chase pursuits
					$.each( chase.pursuits, function( pursuit_key, pursuit ) {						
						// If this chase is yet not considered
						if(!isConsidered(ninja_key, chase_key)) {
							//If input creation equals ninja chase pursuit or is high_combo
							if(create == pursuit) {
								combos++;
								console.log("Found combo: from " +current.name+" ["+create+"] - ["+pursuit+"] "+ninja.name);
								if((typeof ninja.type != 'undefined' && ninja.type == 'yellow' && summonTimes > 2) || typeof ninja.type == 'undefined')
									considered.push({
										ninja_key: ninja_key,
										chase_key: chase_key
									});
								if(typeof ninja.type != 'undefined' && ninja.type == 'yellow' && summonTimes < 2)
									summonTimes++;
								
								toReturn.push(ninja.name);	
								if(ninja_key == 0)
									hits += attack.hits;
								
								hits += chase.hits;
								$.merge(toReturn,findNext(ninja, chase));
								
								return false;
							}	
							
							if(pursuit == "high_combo") {
								high_combo_queue.push({
									ninja_key: ninja_key,
									chase_key: chase_key
								});
								considered.push({
									ninja_key: ninja_key,
									chase_key: chase_key
								});
							}
						}
					});	
					if(toReturn.length > 0)
						return false;
				});
				if(toReturn.length > 0)
					return false;
			});			
		//}		
		if(toReturn.length > 0)
			return false;
	});	
	return toReturn;
}

function isConsidered(ninja_key, chase_key) {
	var toReturn = false;
	$.each(considered, function(cons_key, cons_value) {

		if(cons_value.ninja_key == ninja_key && cons_value.chase_key == chase_key) {
			toReturn = true;
			return false;
		}
	});
	return toReturn;	
}

Array.prototype.rotate = (function() {
    var unshift = Array.prototype.unshift,
        splice = Array.prototype.splice;

    return function(count) {
        var len = this.length >>> 0,
            count = count >> 0;

        unshift.apply(this, splice.call(this, count % len, len));
        return this;
    };
})();
