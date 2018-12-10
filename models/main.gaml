/**
* Name: main
* Author: rasif
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model main

global{
	
	// Desires
	predicate drink_desire <- new_predicate("drink") with_priority 2;
	predicate info_desire <- new_predicate("info") with_priority 1;
	predicate bank_desire <- new_predicate("bank") with_priority 2;
	predicate football_desire <- new_predicate("football") with_priority 1;
	predicate music_desire <- new_predicate("music") with_priority 1;
	predicate pee_desire <- new_predicate("pee") with_priority 1;
	predicate eat_desire <- new_predicate("eat") with_priority 2;
	predicate socialize_desire <- new_predicate("socialize_desire")  with_priority 1;
	
	//Emotions
	emotion happy <- new_emotion("happy");
	emotion annoy <- new_emotion("annoy");
	
	// Information
	point ICENTER_location <- {20,20};
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
	
	// constants
	float max_drinking <- 70.0;
	float max_hunger <- 1000.0;
	float max_thirst <- 1000.0;
	float max_money <- 1000.0;
	float min_drinking <- 30.0;
	float min_hunger <- 500.0;
	float min_thirst <- 500.0;
	float min_money <- 500.0;
	
	// variables
	int global_happiness;
	int global_sadness;
	
	
	init{
		create participant number: 50;
		create bathroom number: 1;
		create bank number: 1;
		create field number: 1;
		create shop number: 1;
		create stage number: 1;
		create icenter number:1;
		
		global_happiness <- 0;
		global_sadness <- 0;
	}
	
	// reflexes
	reflex print_emotions{
		write "Happiness: " + global_happiness + " Sadness: " + global_sadness;
		global_sadness <- 0;
		global_happiness <- 0;
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
	predicate my_preference;
	
	// Constants
	float viewdist <- 0.1;
	int max_wandering_time <- 5;
	int wandering_for;
	float happy_contingent <- 0.45;
	
	// Virtual Actions
	action update_desire virtual:true;
	action on_served virtual:true;
	action on_waiting virtual:true;
	action out_of_money virtual:true;
	
	// Reflexes
	
	
	// Actions
	action verify_target{
		predicate intention_now <- get_current_intention();
		bool needs_update <- false;
		
		if target=theBathroom and intention_now != theBathroom.motive{
			needs_update <- true;
		} 
		else if target=theBank and intention_now != theBank.motive{
			needs_update <- true;
		}
		else if target=theField and intention_now != theField.motive{
			needs_update <- true;
		}
		else if target=theShop and intention_now != theShop.motive{
			if intention_now != drink_desire{ // since there are two motives for shop
				needs_update <- true;
			}
		}
		else if target=theStage and intention_now != theStage.motive{
			needs_update <- true;
		}
		else if target=theIcenter and intention_now != theIcenter.motive{
			needs_update <- true;
		} else if target = nil{
			needs_update <- true;
		}
		
		if needs_update{
//			write "We have a problem: " + target + " " + intention_now;
//			do remove_intention(intention_now, true);
			do update_desire;
		}
	}
	
}

species building {
	list<human> visitors;
	list<human> serving;
	
	int max_service;
	int time_for_serving;
	int price;
	
	predicate motive;
}

// Childern
species participant parent:human {
	
	init{
		drunk_level <- rnd(0.0, 100.0);
		money_level <- rnd(min_money, max_money);
		hunger_level <- rnd(0.0, 100.0);
		
		original_money_level <- money_level;
		
		drunk_threshold <- rnd(min_drinking, max_drinking);
		thirst_threshold <- rnd(min_thirst, max_thirst);
		hunger_threshold <- rnd(min_hunger, max_hunger);	
		
		drunk_delta <- rnd(10.0, 20.0);
		thirst_delta <- rnd(5.0, 10.0);
		hunger_delta <- rnd(5.0, 10.0);
		
		sport_to_music_prob <- rnd(0.2, 0.8);
		
		speed <- 1.0;
		mycolor <- #white;
		
		target <- nil;
		
		served_time <- 0;
		waiting_time <- 0;
		serving_time_patience <- rnd(2,5);
		waiting_time_patience <- rnd(2,5);
		info_required <- nil;
		wandering_for <- 0;
		
		use_social_architecture <- true;
		use_emotions_architecture <- true;
		
		add theBank to: Memory;
	}
	
	//Actions
	action update_desire{
		if money_level < 250.0{
			do add_desire(bank_desire);
		}
		
		else if thirst_level > thirst_threshold{
			do add_desire(drink_desire);
		}
		
		else if hunger_level > hunger_threshold{
			do add_desire(eat_desire);
		}
		
		else if drunk_level > drunk_threshold{
			do add_desire(pee_desire);
		}
		
		else if flip(sport_to_music_prob){
			do add_desire(football_desire);
		}
		else {
			do add_desire(music_desire);	
		}
		
//		do add_emotion emotion:happy;
	}
	
	action on_served{
//		 do clear_intentions;
//		do clear_desires;
		target <- nil;
		
		// Emotions
		if served_time > serving_time_patience{
			do add_emotion(annoy);
			do remove_emotion(happy);
		}
		else{
			do add_emotion(happy);
			do remove_emotion(annoy);
		}
		
		waiting_time <- 0;
		served_time <- 0;
		
		do update_desire;
	}
	
	action on_waiting{
		if waiting_time > waiting_time_patience{
			do add_emotion(annoy);
			do remove_emotion(happy);
		}
	}
	
	action out_of_money{
//		write "dont have the money";
		predicate intention_now <- get_current_intention();
		do current_intention_on_hold;
		do add_subintention predicate: intention_now subintentions: bank_desire add_as_desire: true;
		do add_desire(bank_desire);
		do update_desire;
	}
	
	//Reflexes
	reflex basic_move{
//		write " " + current_plan + " " + get_current_intention() + " " + thirst_level 
//			+ " " + hunger_level + " " + money_level + " " + target;
		do verify_target;
		if self.target != nil{
			wandering_for <- 0;
			if self.target.location distance_to self.location < 3{
				bool have_money <- true;
				ask self.target{
					if myself.money_level > self.price*2.0{
						if !(self.visitors contains myself){
							add myself to: self.visitors;	
						}
					} else{
						have_money <- false;
					}
				}

				if !have_money{
					do out_of_money;
				}

			} else{
				do goto target:self.target.location speed:self.speed;
//				write "moving";
			}
		} else{
			
			if wandering_for > max_wandering_time{
				do remove_desire(get_current_intention());
			}
			
			do update_desire;
			do wander;
			wandering_for <- wandering_for + 1;
//			write "wandering";
		}
		
		self.thirst_level <- self.thirst_level + self.thirst_delta;
		self.hunger_level <- self.hunger_level + self.hunger_delta;
	}

	 reflex GetInfoLocation when: info_required != nil{
	 	self.target <- theIcenter;
	 }
	 
	 reflex update_intention{
		if get_current_intention() != socialize_desire and get_current_intention() != nil{
			my_preference <- get_current_intention();
		}
	}
	
	reflex forget_everything when: drunk_level > (min_drinking + ((max_drinking-min_drinking)/2.0)){
		if flip(0.001){
			self.Memory <- [];
		}
	}
	
	reflex emotional_spectrum{
		if has_emotion(happy){
			global_happiness <- global_happiness + 1;
		} else if has_emotion(annoy){
			global_sadness <- global_sadness + 1;
		}
	}
	
	//Plans
	plan share_information_to_people intention: socialize_desire{
		loop s over:social_link_base{
			if get_liking(s) > 0.5{
				human friend <- get_agent(s);
				predicate target_desire <- nil;
				if friend.location distance_to location < 0.3 and friend != self{
//					write "How yu doin?";
					ask friend{
						float drinking_capacity <- (abs(self.drunk_threshold - myself.drunk_threshold))/(max_drinking-min_drinking);
						float hunger_capacity <- abs(self.hunger_threshold - myself.hunger_threshold)/(max_hunger-min_hunger);
						float sports_taste <- abs(self.sport_to_music_prob - myself.sport_to_music_prob);
						float thirst_capacity <- abs(self.thirst_threshold - myself.thirst_threshold)/(max_thirst-min_thirst);
						float social_status <- abs(self.original_money_level - myself.original_money_level)/(max_money-min_money);
						
						float score <- (drinking_capacity + hunger_capacity + sports_taste + thirst_capacity + social_status)/5.0;
//						if self.my_preference != myself.my_preference{
						if score < 0.3{
//							write "I love you";
							
							target_desire <- self.my_preference;
							
							do remove_desire(get_current_intention());
							do clear_desires();
							do clear_intentions();
							do add_desire(target_desire);
							
							self.thirst_level <- 0.0;
							self.drunk_level <- 0.0;
							self.hunger_level <- 0.0;
							self.money_level <- self.original_money_level;
							
							myself.thirst_level <- 0.0;
							myself.drunk_level <- 0.0;
							myself.hunger_level <- 0.0;
							myself.money_level <- myself.original_money_level;
							
							rgb new_color <- rgb(rnd(0,255), rnd(0,255), rnd(0,255));
							myself.mycolor <- new_color;
							self.mycolor <- new_color;
							
							do add_emotion(happy);
							do remove_emotion(annoy);
						}
						
						if target_desire != nil and get_liking(s) > 0.0{
							do remove_desire(get_current_intention());
							do clear_desires();
							do clear_intentions();
							do add_desire(target_desire);
							do add_emotion(happy);
//							write "updating desire";
						}
//						write "Our Preferences: " + self.my_preference + " " + myself.my_preference;
					}
					break;
				}
			}
		}
		
//		do remove_intention(socialize_desire, true);
		do remove_desire(socialize_desire);
	}

//	plan GoToIcenter intention: info_desire{
//		self.target <- theIcenter;
//	}
	
	plan GoForDrink intention: drink_desire{
		if Memory contains theShop{
			self.target <- theShop;	
		} else{
			do current_intention_on_hold;
			do add_subintention predicate: drink_desire subintentions: info_desire add_as_desire: true;
			info_required <- drink_desire;
		}
	}
	
	plan GoForFood intention: eat_desire{
		if Memory contains theShop{
			self.target <- theShop;	
		} else{
			do current_intention_on_hold;
			do add_subintention predicate: eat_desire subintentions: info_desire add_as_desire: true;
			info_required <- eat_desire;
		}
	}
	
	plan GoForMoney intention: bank_desire{
		if Memory contains theBank{
			self.target <- theBank;	
		} else{
			do current_intention_on_hold;
			do add_subintention predicate: bank_desire subintentions: info_desire add_as_desire: true;
			info_required <- bank_desire;
		}
	}
	
	plan GoForPee intention: pee_desire{
		if Memory contains theBathroom{
			self.target <- theBathroom;	
		} else{
			do current_intention_on_hold;
			do add_subintention predicate: pee_desire subintentions: info_desire add_as_desire: true;
			info_required <- pee_desire;
		}
	}
	
	plan GoForMusic intention: music_desire{
		if Memory contains theStage{
			self.target <- theStage;	
		} else{
			do current_intention_on_hold;
			do add_subintention predicate: music_desire subintentions: info_desire add_as_desire: true;
			info_required <- music_desire;
		}
	}
	
	plan GoForSports intention: football_desire{
		if Memory contains theField{
			self.target <- theField;	
		} else{
			do current_intention_on_hold;
			do add_subintention predicate: football_desire subintentions: info_desire add_as_desire: true;
			info_required <- football_desire;
		}
	}
	
	// Perception
	perceive target:participant in:viewdist {
		float like <- 1.0;
		float familiar <- 0.0;
		float dom <- rnd(-0.9,0.9);
		if self.get_current_intention() != myself.get_current_intention(){
			like <- like - rnd(0.2, 0.6);
		}
		else{
			familiar <- rnd(0.5, 1.0);
		}
		like <- like - (abs(self.drunk_level - myself.drunk_level)/100.0);
		
		social_link link <- new_social_link(myself, like, dom, 0.0, familiar);
		bool link_exists <- false;
		loop b over: social_link_base{
			if get_agent(b) = self{
				link_exists <- true;
				do remove_social_link social_link: b;
				break;
			}
		}
		
		do add_social_link(link);
		
		if self.get_emotion = happy{
			if flip(happy_contingent){
				ask myself{
					do add_emotion(happy);
					do remove_emotion(annoy);
				}
			}
		}
		
//		write "I am socializing with: " + like + " " + dom + " " + familiar;
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
		price <- 0;
		motive <- pee_desire;
	}
	
	reflex recieve_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
			add next_customer to: serving;
			ask next_customer{
				do on_waiting;
			}
		} else{
			loop p over:visitors{
				ask p{
					self.waiting_time <- waiting_time + 1;
					do add_desire predicate:socialize_desire;
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
				do add_desire predicate:socialize_desire;
			}
			
			if customer_serving_time > self.time_for_serving{
				ask customer{
//					do remove_intention(pee_desire, true);
//					do remove_intention(socialize_desire, true);
					do remove_desire(pee_desire);
					do remove_desire(socialize_desire);
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
		motive <- bank_desire;
	}
	
	reflex receive_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
			add next_customer to: serving;
			ask next_customer{
				do on_waiting;
			}
		} else{
			loop p over:visitors{
				ask p{
					self.waiting_time <- waiting_time + 1;
					do add_desire predicate:socialize_desire;
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
				do add_desire predicate:socialize_desire;
			}
			
			if customer_serving_time > self.time_for_serving{
				ask customer{
//					do remove_intention(bank_desire, true);
//					do remove_intention(socialize_desire, true);
					do remove_desire(bank_desire);
					do remove_desire(socialize_desire);
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
	
	list<human> players;
	int max_poeple_playing <- 6;
	int play_cycles <- 30;
	
	init{
		theField <- self;
		location <- FOOTBALL_location;
		max_service <- 5;
		time_for_serving <- 5;
		price <- 25;
		motive <- football_desire;
	}
	
//	reflex clear_playing when: length(players) = max_poeple_playing and mod(cycle,play_cycles) = 0{
//		
//	}
	
	reflex recieve_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
			add next_customer to: serving;
			ask next_customer{
				do on_waiting;
			}
			if length(players) <= max_poeple_playing and mod(cycle,play_cycles) != 0{
				add next_customer to: players;
			}
		} else{
			loop p over:visitors{
				ask p{
					self.waiting_time <- waiting_time + 1;
					do add_desire predicate:socialize_desire;
				}
			}
		}
	}
	
	reflex serve_customers when: length(serving) > 0 and length(players) = max_poeple_playing{
		list<human> customers_served;
		loop customer over: serving{
			if !(players contains customer){
				int customer_serving_time <- 0;
				ask customer{
					self.served_time <- self.served_time + 1;
					customer_serving_time <- self.served_time;
					do add_desire predicate:socialize_desire;
				}
				
				if customer_serving_time > self.time_for_serving{
					ask customer{
						do remove_desire(football_desire);
						do remove_desire(socialize_desire);
						self.money_level <- self.money_level - myself.price;
						do on_served;
						add customer to: customers_served;
					}
				}	
			} else if mod(cycle,play_cycles) = 0{
				ask customer{
					do remove_desire(football_desire);
					do remove_desire(socialize_desire);
					self.money_level <- self.money_level - myself.price;
					do on_served;
					add customer to: customers_served;
				}
			}
		}
		
		loop p over: customers_served{
			
			// If player
			if players contains p{
				if flip(0.75){
					ask p{
						do add_emotion(happy);
						do remove_emotion(annoy);
					}
				} else{
					ask p{
						do add_emotion(annoy);
						do remove_emotion(happy);
					}
				}
				remove p from:players;	
			} 
			
			// If audience
			else{
				if flip(0.5){
					ask p{
						do add_emotion(happy);
						do remove_emotion(annoy);
					}
				} else{
					ask p{
						do add_emotion(annoy);
						do remove_emotion(happy);
					}
				}
			}
			remove p from: serving;
		}
	}
}

species shop parent: building{
	
	init{
		location <- SHOP_location;
		max_service <- 5;
		time_for_serving <- 2;
		price <- 30;
		motive <- eat_desire;
		theShop <- self;
	}
	
	reflex recieve_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
			add next_customer to: serving;
			ask next_customer{
				do on_waiting;
			}
		} else{
			loop p over:visitors{
				ask p{
					self.waiting_time <- waiting_time + 1;
					do add_desire predicate:socialize_desire;
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
				do add_desire predicate:socialize_desire;
			}
			
			if customer_serving_time > self.time_for_serving{
				ask customer{
					//self.//target <- nil;
//					do remove_intention(socialize_desire, true);
					do remove_desire(socialize_desire);
//					write "My intentions: " + self.get_current_intention();
					if self.get_current_intention() = eat_desire and self.money_level > myself.price{
//						do remove_intention(eat_desire, true);
						do remove_desire(eat_desire);
						self.hunger_level <- 0.0;
						self.money_level <- self.money_level - myself.price;
					} else if self.get_current_intention() = drink_desire and self.money_level > (myself.price*2){
//						do remove_intention(drink_desire, true);
						do remove_desire(drink_desire);
						self.thirst_level <- 0.0;
						self.drunk_level <- self.drunk_level + self.drunk_delta;
						self.money_level <- self.money_level - (myself.price*2);
					} else{
						do out_of_money;
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
		price <- 50;
		motive <- music_desire;
	}
	
	reflex receive_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- visitors[0];
			remove visitors[0] from: visitors;
			add next_customer to: serving;
			ask next_customer{
				do on_waiting;
			}
		} else{
			loop p over:visitors{
				ask p{
					self.waiting_time <- waiting_time + 1;
					do add_desire predicate:socialize_desire;
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
				do add_desire predicate:socialize_desire;
			}
			
			if customer_serving_time > self.time_for_serving{
				ask customer{
//					do remove_intention(music_desire, true);
//					do remove_intention(socialize_desire, true);
					do remove_desire(music_desire);
					do remove_desire(socialize_desire);
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
		motive <- info_desire;
	}
	
	reflex receive_customers when: length(visitors) > 0{
		if length(serving) <= max_service{
			human next_customer <- first(visitors);
			remove next_customer from: visitors;
			add next_customer to: serving;
			ask next_customer{
				do on_waiting;
			}
		} else{
			loop p over:visitors{
				ask p{
					self.waiting_time <- waiting_time + 1;
					do add_desire predicate:socialize_desire;
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
				do add_desire predicate:socialize_desire;
			}
			
			if customer_serving_time > self.time_for_serving{
				ask customer{
//					do remove_intention(info_desire, true);
//					do remove_intention(socialize_desire, true);
					do remove_desire(info_desire);
					do remove_desire(socialize_desire);
					self.money_level <- self.money_level - myself.price;
					
					if self.info_required = drink_desire{
						add theShop to: self.Memory;
					} else if self.info_required = eat_desire{
						add theShop to: self.Memory;
					} else if self.info_required = bank_desire{
						add theBank to: self.Memory;
					} else if self.info_required = football_desire{
						add theField to: self.Memory;
					} else if self.info_required = music_desire{
						add theStage to: self.Memory;
					} else if self.info_required = pee_desire{
						add theBathroom to: self.Memory;
					} else {
//						write "No Info Required";
					}
					
//					write "Info Obtained: " + self.info_required;
					do add_desire(self.info_required);
					self.info_required <- nil;
					do on_served;
					add customer to: customers_served;
					do wander;
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
