/**
* Name: main
* Author: rasif
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model main

global{
	
	// Desires
	predicate drink_desire <- new_predicate("drink") with_priority 1;
	predicate info_desire <- new_predicate("info") with_priority 1;
	predicate bank_desire <- new_predicate("bank") with_priority 1;
	predicate football_desire <- new_predicate("football") with_priority 1;
	predicate music_desire <- new_predicate("music") with_priority 1;
	predicate pee_desire <- new_predicate("pee") with_priority 1;
	predicate eat_desire <- new_predicate("eat") with_priority 1;
	
	// Information
	point ICENTER_location <- {10,10};
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
	icenter theIcenter;
	
	init{
		create participant number: 10;
		create bathroom number: 1;
		create bank number: 1;
		create field number: 1;
		create shop number: 1;
		create stage number: 1;
		create icenter number:1;
	}
}

// PARENTS
species human skills: [moving] control: simple_bdi{
	
	// Levels
	float drunk_level;
	float thirst_level;
	float money_level;
	float hunger_level;
	
	float original_money_level;
	
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
	
	// Variables
	rgb mycolor;
	building target;
	float speed;
	int served_time;
	int waiting_time;
	int serving_time_patience;
	int waiting_time_patience;
	list<building> Memory;
	predicate info_required;
	
	// Virtual Actions
	action update_desire virtual:true;
	action on_served virtual:true;
	action on_waiting virtual:true;
}

species building {
	list<human> visitors;
	list<human> serving;
	
	int max_service;
	int time_for_serving;
	int price;
	
}

// Childern
species participant parent:human{
	
	init{
		drunk_level <- rnd(0.0, 100.0);
		money_level <- rnd(50.0, 100.0);
		hunger_level <- rnd(0.0, 100.0);
		
		original_money_level <- money_level;
		
		drunk_threshold <- rnd(50.0, 70.0);
		thirst_threshold <- rnd(50.0, 70.0);
		hunger_threshold <- rnd(50.0, 70.0);	
		
		drunk_delta <- rnd(10.0, 20.0);
		thirst_delta <- rnd(10.0, 20.0);
		hunger_delta <- rnd(10.0, 20.0);
		
		sport_to_music_prob <- rnd(0.2, 0.8);
		
		speed <- rnd(0.3,1.0);
		mycolor <- #blue;
		
		target <- nil;
		
		served_time <- 0;
		waiting_time <- 0;
		serving_time_patience <- rnd(2,5);
		waiting_time_patience <- rnd(2,5);
		info_required <- nil;
	}
	
	//Actions
	action update_desire{
		if thirst_level > thirst_threshold{
			do add_desire(drink_desire);
		}
		
		if hunger_level > hunger_threshold{
			do add_desire(eat_desire);
		}
		
		if drunk_level > drunk_threshold{
			do add_desire(pee_desire);
		}
		
		if money_level < 50.0{
			do add_desire(bank_desire);
		}
		
		if flip(sport_to_music_prob){
			do add_desire(football_desire);
		}
		else {
			do add_desire(music_desire);	
		}
	}
	
	action on_served{
		waiting_time <- 0;
		served_time <- 0;
		do clear_intentions;
//		do clear_desires;
		target <- nil;
		do update_desire;
	}
	
	action on_waiting{
		
	}
	
	//Reflexes
	reflex basic_move{
//		write " " + current_plan + " " + get_current_intention() + " " + thirst_level + " " + hunger_level;
		if self.target != nil{
			if self.target.location distance_to self.location < 3{
				ask self.target{
					if !(self.visitors contains myself){
						add myself to: self.visitors;	
					}
				}
			} else{
				do goto target:self.target.location speed:self.speed;
			}
		} else{
			self.thirst_level <- self.thirst_level + self.thirst_delta;
			self.hunger_level <- self.hunger_level + self.hunger_delta;
			do update_desire;
			do wander;
		}
	}
	
	//Plans
	plan GoForInfo intention: info_desire{
		self.target <- theIcenter;
	}
	
	reflex GetInfoLocation when: info_required != nil{
		self.target <- theIcenter;
	}
	
	plan GoForDrink intention: drink_desire{
		if Memory contains theShop{
			self.target <- theShop;	
		} else if info_required = nil{
			do current_intention_on_hold;
			do add_subintention predicate: drink_desire subintentions: info_desire;
			info_required <- drink_desire;
		}
	}
	
	plan GoForFood intention: eat_desire{
		if Memory contains theShop{
			self.target <- theShop;	
		} else if info_required = nil{
			do current_intention_on_hold;
			do add_subintention predicate: eat_desire subintentions: info_desire;
			info_required <- eat_desire;
		}
	}
	
	plan GoForMoney intention: bank_desire{
		if Memory contains theBank{
			self.target <- theBank;	
		} else if info_required = nil{
			do current_intention_on_hold;
			do add_subintention predicate: bank_desire subintentions: info_desire;
			info_required <- bank_desire;
		}
	}
	
	plan GoForPee intention: pee_desire{
		if Memory contains theBathroom{
			self.target <- theBathroom;	
		} else if info_required = nil{
			do current_intention_on_hold;
			do add_subintention predicate: pee_desire subintentions: info_desire;
			info_required <- pee_desire;
		}
	}
	
	plan GoForMusic intention: music_desire{
		if Memory contains theStage{
			self.target <- theStage;	
		} else if info_required = nil{
			do current_intention_on_hold;
			do add_subintention predicate: music_desire subintentions: info_desire;
			info_required <- music_desire;
		}
	}
	
	plan GoForSports intention: football_desire{
		if Memory contains theField{
			self.target <- theField;	
		} else if info_required = nil{
			do current_intention_on_hold;
			do add_subintention predicate: football_desire subintentions: info_desire;
			info_required <- football_desire;
		}
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
		time_for_serving <- 2;
		price <- 1;
	}
	
	reflex recieve_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
			add next_customer to: serving;
		} else{
			loop p over:visitors{
				ask p{
					self.waiting_time <- waiting_time + 1;
					//self.//target <- nil;
				}
			}
		}
	}
	
	reflex serve_customers when: length(serving) > 0{
		list<human> customers_served;
		loop customer over: serving{
			int customer_serving_time <- 0;
			ask customer{
				self.served_time <- self.served_time + 1;
				customer_serving_time <- self.served_time;
			}
			
			if customer_serving_time > self.time_for_serving{
				ask customer{
					do remove_intention(pee_desire, true);
					//target <- nil;
					self.drunk_level <- self.drunk_level*0.75;
					self.money_level <- self.money_level - myself.price;
					do on_served;
					add customer to: customers_served;
				}
			}
		}
		
		loop p over: customers_served{
			remove p from: serving;
		}
	}
}

species bank parent: building{
	
	init{
		theBank <- self;
		location <- BANK_location;
		max_service <- 5;
		time_for_serving <- 2;
		price <- 0;
	}
	
	reflex receive_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
			add next_customer to: serving;
		} else{
			loop p over:visitors{
				ask p{
					self.waiting_time <- waiting_time + 1;
					//self.//target <- nil;
				}
			}
		}
	}
	
	reflex serve_customers when: length(serving) > 0{
		list<human> customers_served;
		loop customer over: serving{
			int customer_serving_time <- 0;
			ask customer{
				self.served_time <- self.served_time + 1;
				customer_serving_time <- self.served_time;
			}
			
			if customer_serving_time > self.time_for_serving{
				ask customer{
					do remove_intention(bank_desire, true);
					//target <- nil;
					self.money_level <- original_money_level;
					self.money_level <- self.money_level - myself.price;
					do on_served;
					add customer to: customers_served;
				}
			}
		}
		
		loop p over: customers_served{
			remove p from: serving;
		}
	}
}

species field parent: building{
	
	init{
		theField <- self;
		location <- FOOTBALL_location;
		max_service <- 5;
		time_for_serving <- 5;
		price <- 15;
	}
	
	reflex recieve_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
			add next_customer to: serving;
		} else{
			loop p over:visitors{
				ask p{
					self.waiting_time <- waiting_time + 1;
					//self.//target <- nil;
				}
			}
		}
	}
	
	reflex serve_customers when: length(serving) > 0{
		list<human> customers_served;
		loop customer over: serving{
			int customer_serving_time <- 0;
			ask customer{
				self.served_time <- self.served_time + 1;
				customer_serving_time <- self.served_time;
			}
			
			if customer_serving_time > self.time_for_serving{
				ask customer{
					do remove_intention(football_desire, true);
					//target <- nil;
					self.money_level <- self.money_level - myself.price;
					do on_served;
					add customer to: customers_served;
				}
			}
		}
		
		loop p over: customers_served{
			remove p from: serving;
		}
	}
}

species shop parent: building{
	
	init{
		theShop <- self;
		location <- SHOP_location;
		max_service <- 5;
		time_for_serving <- 2;
		price <- 5;
	}
	
	reflex recieve_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
			add next_customer to: serving;
		} else{
			loop p over:visitors{
				ask p{
					self.waiting_time <- waiting_time + 1;
					//self.//target <- nil;
				}
			}
		}
	}
	
	reflex serve_customers when: length(serving) > 0{
		list<human> customers_served;
		loop customer over: serving{
			int customer_serving_time <- 0;
			ask customer{
				self.served_time <- self.served_time + 1;
				customer_serving_time <- self.served_time;
			}
			
			if customer_serving_time > self.time_for_serving{
				ask customer{
					//self.//target <- nil;
					if self.get_current_intention = eat_desire{
						do remove_intention(eat_desire, true);
						self.hunger_level <- 0.0;
						self.money_level <- self.money_level - myself.price;
					} else{
						do remove_intention(drink_desire, true);
						self.thirst_level <- 0.0;
						self.drunk_level <- self.drunk_level + self.drunk_delta;
						self.money_level <- self.money_level - (myself.price*2);
					}
					do on_served;
					add customer to: customers_served;
				}
			}
		}
		
		loop p over: customers_served{
			remove p from: serving;
		}
	}
}

species stage parent: building{
	
	init{
		theStage <- self;
		location <- STAGE_location;
		max_service <- 5;
		price <- 6;
	}
	
	reflex recieve_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
			add next_customer to: serving;
		} else{
			loop p over:visitors{
				ask p{
					self.waiting_time <- waiting_time + 1;
					//self.//target <- nil;
				}
			}
		}
	}
	
	reflex serve_customers when: length(serving) > 0{
		list<human> customers_served;
		loop customer over: serving{
			int customer_serving_time <- 0;
			ask customer{
				self.served_time <- self.served_time + 1;
				customer_serving_time <- self.served_time;
			}
			
			if customer_serving_time > self.time_for_serving{
				ask customer{
					do remove_intention(music_desire, true);
					//target <- nil;
					self.money_level <- self.money_level - myself.price;
					do on_served;
					add customer to: customers_served;
				}
			}
		}
		
		loop p over: customers_served{
			remove p from: serving;
		}
	}
}

species icenter parent: building{
	
	init{
		theIcenter <- self;
		location <- ICENTER_location;
		max_service <- 5;
		price <- 0;
	}
	
	reflex recieve_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
			add next_customer to: serving;
		} else{
			loop p over:visitors{
				ask p{
					self.waiting_time <- waiting_time + 1;
					//self.//target <- nil;
				}
			}
		}
	}
	
	reflex serve_customers when: length(serving) > 0{
		list<human> customers_served;
		loop customer over: serving{
			int customer_serving_time <- 0;
			ask customer{
				self.served_time <- self.served_time + 1;
				customer_serving_time <- self.served_time;
			}
			
			if customer_serving_time > self.time_for_serving{
				ask customer{
					do remove_intention(info_desire, true);
					do remove_desire(info_desire);
					self.money_level <- self.money_level - myself.price;
					
					if self.info_required = drink_desire{
						add theShop to: self.Memory;
						target <- theShop;
					} else if self.info_required = eat_desire{
						add theShop to: self.Memory;
						target <- theShop;
					} else if self.info_required = bank_desire{
						add theBank to: self.Memory;
						target <- theBank;
					} else if self.info_required = football_desire{
						add theField to: self.Memory;
						target <- theField;
					} else if self.info_required = music_desire{
						add theStage to: self.Memory;
						target <- theStage;
					} else if self.info_required = pee_desire{
						add theBathroom to: self.Memory;
						target <- theBathroom;
					}
					
					do add_desire(self.info_required);
					self.info_required <- nil;
					do on_served;
					add customer to: customers_served;
				}
			}
		}
		
		loop p over: customers_served{
			remove p from: serving;
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
