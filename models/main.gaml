/**
* Name: main
* Author: rasif
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model main

global{
	
	// Desires
	predicate drink_desire <- new_predicate("drink") with_priority 3;
	predicate info_desire <- new_predicate("info") with_priority 1;
	predicate bank_desire <- new_predicate("bank") with_priority 1;
	predicate football_desire <- new_predicate("football") with_priority 1;
	predicate music_desire <- new_predicate("music") with_priority 1;
	predicate pee_desire <- new_predicate("pee") with_priority 4;
	predicate eat_desire <- new_predicate("eat") with_priority 2;
	
	// Information
	point ICENTER_location <- {50,50};
	point STAGE_location <- {50, 75};
	point BANK_location <- {75, 75};
	point SHOP_location <- {75, 50};
	point FOOTBALL_location <- {10, 50};
	point PEE_location <- {75 , 10};
	
	//Buildings
	bathroom theBathroom;
	bank theBank;
	field theField;
	shop theShop;
	stage theStage;
	
	init{
		create participant number: 10;
		create bathroom number: 1;
	}
}

// PARENTS
species human skills: [moving] control: simple_bdi{
	
	// Levels
	float drunk_level;
	float thirst_level;
	float money_level;
	float hunger_level;
	
	// Thresholds
	float drunk_threshold;
	float thirst_threshold;
	float hunger_threshold;
	
	// delta changes
	float drunk_delta;
	float thirst_delta;
	float hunger_delta;
	
	//Preference
	float sport_to_music_prob;
	
	rgb mycolor;
	building target;
	float speed;
}

species building {
	list<human> visitors;
	list<human> serving;
	
	int max_service;
}

// Childern
species participant parent:human{
	
	init{
		drunk_level <- rnd(0.0, 100.0);
		money_level <- rnd(0.0, 100.0);
		hunger_level <- rnd(0.0, 100.0);
		
		drunk_threshold <- rnd(40.0, 70.0);
		thirst_threshold <- rnd(40.0, 70.0);
		hunger_threshold <- rnd(40.0, 70.0);	
		
		drunk_delta <- rnd(5.0, 10.0);
		thirst_delta <- rnd(5.0, 10.0);
		hunger_delta <- rnd(5.0, 10.0);
		
		sport_to_music_prob <- rnd(0.2, 0.8);
		
		speed <- rnd(0.3,1.0);
		mycolor <- #blue;
		
		float viewdist <- 1.0;
		target <- nil;
	}
	
	//Actions
	action update_desire{
		if thirst_level > thirst_threshold{
			do add_desire(drink_desire);
		}
		
		if drunk_level > drunk_threshold{
			do add_desire(pee_desire);
		}
		
		if money_level < 10.0{
			do add_desire(bank_desire);
		}
		
		if flip(sport_to_music_prob){
			do add_desire(football_desire);
		} 
		
		else if !flip(sport_to_music_prob) {
			do add_desire(music_desire);
		}
	}
	
	//Reflexes
	reflex basic_move{
		if target != nil{
			if target.location distance_to location < 3{
				ask target{
					if !(visitors contains myself){
						add myself to: visitors;	
					}
				}
			} else{
				do goto target:target.location speed:speed;
			}
		} else{
			do wander;
			thirst_level <- thirst_level + thirst_delta;
			hunger_level <- hunger_level + hunger_delta;
			do update_desire;
		}
	}
	
	//Plans
	plan GoForDrink intention: drink_desire or eat_desire{
		target <- theShop;
	}
	
	plan GoForMoney intention: bank_desire{
		target <- theBank;
	}
	
	plan GoForPee intention: pee_desire{
		target <- theBathroom;
	}
	
	plan GoForMusic intention: music_desire{
		target <- theStage;
	}
	
	plan GoForSports intention: football_desire{
		target <- theField;
	}
	
	aspect default {
	        draw circle(1) color: mycolor border: #black;
	}
}

species bathroom parent: building{
	
	init{
		theBathroom <- self;
		location <- PEE_location;
		max_service <- 5;
	}
	
	reflex relish_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
			ask next_customer{
				target <- nil;
			}
		}
	}
}

species bank parent: building{
	
	init{
		theBank <- self;
		location <- BANK_location;
		max_service <- 5;
	}
	
	reflex relish_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
		}
	}
}

species field parent: building{
	
	init{
		theField <- self;
		location <- FOOTBALL_location;
		max_service <- 5;
	}
	
	reflex relish_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
		}
	}
}

species shop parent: building{
	
	init{
		theShop <- self;
		location <- SHOP_location;
		max_service <- 5;
	}
	
	reflex relish_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
		}
	}
}

species stage parent: building{
	
	init{
		theStage <- self;
		location <- STAGE_location;
		max_service <- 5;
	}
	
	reflex relish_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
		}
	}
}

experiment stage_info type: gui {
    output {
        display main_display {
            species participant aspect:default;
            
            graphics 'buildings'{
				draw box(2,2,0) color: #yellow at: ICENTER_location;
				draw box(2,2,0) color: #purple at: STAGE_location;
				draw box(2,2,0) color: #grey at: BANK_location;
				draw box(2,2,0) color: #orange at: SHOP_location;
				draw box(2,2,0) color: #green at: FOOTBALL_location;
				draw box(2,2,0) color: #brown at: PEE_location;
				
			}
        }
    }
}
