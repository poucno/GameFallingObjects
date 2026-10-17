class_name QuestionDatabase
extends RefCounted

## Database of trivia questions with correct answers and distractors

static var all_questions: Array[Dictionary] = [
	# --- Space & Science ---
	{
		"question": "What planet is known as the 'Red Planet'?",
		"category": "Space",
		"answer": "Mars",
		"distractors": ["Venus", "Jupiter", "Saturn", "Mercury"]
	},
	{
		"question": "What is the chemical formula for water?",
		"category": "Science",
		"answer": "H2O",
		"distractors": ["CO2", "NaCl", "O2", "CH4"]
	},
	{
		"question": "Which gas do plants absorb from the atmosphere for photosynthesis?",
		"category": "Science",
		"answer": "Carbon Dioxide",
		"distractors": ["Oxygen", "Nitrogen", "Hydrogen", "Argon"]
	},
	{
		"question": "What is the closest star to Earth?",
		"category": "Space",
		"answer": "Sun",
		"distractors": ["Proxima Centauri", "Sirius", "Polaris", "Betelgeuse"]
	},
	{
		"question": "What force pulls objects toward the center of the Earth?",
		"category": "Science",
		"answer": "Gravity",
		"distractors": ["Magnetism", "Friction", "Inertia", "Tension"]
	},
	{
		"question": "What is the hardest natural substance on Earth?",
		"category": "Science",
		"answer": "Diamond",
		"distractors": ["Gold", "Iron", "Quartz", "Titanium"]
	},
	{
		"question": "Which planet is the largest in our solar system?",
		"category": "Space",
		"answer": "Jupiter",
		"distractors": ["Saturn", "Neptune", "Uranus", "Earth"]
	},

	# --- Animals & Nature ---
	{
		"question": "What is the largest living mammal on Earth?",
		"category": "Animals",
		"answer": "Blue Whale",
		"distractors": ["African Elephant", "Giraffe", "Hippopotamus", "Great White Shark"]
	},
	{
		"question": "Which flightless bird is native to Antarctica?",
		"category": "Animals",
		"answer": "Penguin",
		"distractors": ["Ostrich", "Emu", "Kiwi", "Dodo"]
	},
	{
		"question": "How many arms does a typical octopus have?",
		"category": "Animals",
		"answer": "Eight",
		"distractors": ["Six", "Ten", "Twelve", "Four"]
	},
	{
		"question": "What do honeybees collect from flowers to make honey?",
		"category": "Nature",
		"answer": "Nectar",
		"distractors": ["Pollen", "Sap", "Water", "Petals"]
	},
	{
		"question": "What animal is known as the 'Ship of the Desert'?",
		"category": "Animals",
		"answer": "Camel",
		"distractors": ["Horse", "Llama", "Donkey", "Zebra"]
	},
	{
		"question": "Which big cat is the fastest land animal?",
		"category": "Animals",
		"answer": "Cheetah",
		"distractors": ["Lion", "Leopard", "Tiger", "Jaguar"]
	},

	# --- Geography ---
	{
		"question": "What is the capital city of France?",
		"category": "Geography",
		"answer": "Paris",
		"distractors": ["Rome", "Madrid", "Berlin", "London"]
	},
	{
		"question": "Which is the longest river in the world?",
		"category": "Geography",
		"answer": "Nile",
		"distractors": ["Amazon", "Mississippi", "Danube", "Yangtze"]
	},
	{
		"question": "What country is famous for the Great Barrier Reef?",
		"category": "Geography",
		"answer": "Australia",
		"distractors": ["Brazil", "South Africa", "Indonesia", "New Zealand"]
	},
	{
		"question": "On which continent is Mount Everest located?",
		"category": "Geography",
		"answer": "Asia",
		"distractors": ["Europe", "Africa", "South America", "North America"]
	},
	{
		"question": "What is the largest ocean in the world?",
		"category": "Geography",
		"answer": "Pacific",
		"distractors": ["Atlantic", "Indian", "Arctic", "Southern"]
	},
	{
		"question": "What is the capital city of Italy?",
		"category": "Geography",
		"answer": "Rome",
		"distractors": ["Milan", "Florence", "Venice", "Naples"]
	},
	{
		"question": "Which country is home to the ancient pyramids of Giza?",
		"category": "Geography",
		"answer": "Egypt",
		"distractors": ["Greece", "Mexico", "Peru", "Turkey"]
	},

	# --- Everyday Knowledge & Food ---
	{
		"question": "What color do you get when you mix yellow and blue?",
		"category": "Art",
		"answer": "Green",
		"distractors": ["Purple", "Orange", "Brown", "Red"]
	},
	{
		"question": "How many days are there in a standard leap year?",
		"category": "Trivia",
		"answer": "366",
		"distractors": ["365", "364", "360", "367"]
	},
	{
		"question": "Which fruit is yellow, peelable, and rich in potassium?",
		"category": "Food",
		"answer": "Banana",
		"distractors": ["Lemon", "Apple", "Mango", "Pineapple"]
	},
	{
		"question": "What is frozen water called?",
		"category": "Science",
		"answer": "Ice",
		"distractors": ["Steam", "Fog", "Cloud", "Dew"]
	},
	{
		"question": "What is the primary ingredient in guacamole?",
		"category": "Food",
		"answer": "Avocado",
		"distractors": ["Tomato", "Cucumber", "Lime", "Pepper"]
	},
	{
		"question": "How many sides does a hexagon have?",
		"category": "Math",
		"answer": "Six",
		"distractors": ["Five", "Eight", "Seven", "Four"]
	},
	{
		"question": "Which musical instrument features 88 keys?",
		"category": "Music",
		"answer": "Piano",
		"distractors": ["Harpsichord", "Accordion", "Organ", "Synthesizer"]
	},

	# --- Technology & General ---
	{
		"question": "Which programming language uses indentation for blocks and 'def' for functions?",
		"category": "Technology",
		"answer": "Python",
		"distractors": ["JavaScript", "C++", "Java", "Ruby"]
	},
	{
		"question": "What does CPU stand for in computer hardware?",
		"category": "Technology",
		"answer": "Processor",
		"distractors": ["Display", "Storage", "Memory", "Battery"]
	},
	{
		"question": "What currency is officially used in Japan?",
		"category": "World",
		"answer": "Yen",
		"distractors": ["Won", "Yuan", "Dollar", "Euro"]
	},
	{
		"question": "What is the fastest vehicle travel sound speed called?",
		"category": "Science",
		"answer": "Supersonic",
		"distractors": ["Hypnotic", "Subsonic", "Ultrasonic", "Megasonic"]
	},
	{
		"question": "What shape is commonly used for a stop sign?",
		"category": "Trivia",
		"answer": "Octagon",
		"distractors": ["Hexagon", "Circle", "Pentagon", "Square"]
	},
	{
		"question": "Which metal is liquid at room temperature?",
		"category": "Science",
		"answer": "Mercury",
		"distractors": ["Silver", "Lead", "Tin", "Copper"]
	},
	{
		"question": "Which season follows winter?",
		"category": "General",
		"answer": "Spring",
		"distractors": ["Summer", "Autumn", "Monsoon", "Fall"]
	},
	{
		"question": "What is the boiling point of pure water in Celsius?",
		"category": "Science",
		"answer": "100",
		"distractors": ["90", "120", "212", "80"]
	}
]

var _deck: Array[Dictionary] = []
#var _used_indices: Array[int] = []

func _init() -> void:
	reset()

func reset() -> void:
	_deck.clear()
	for q in all_questions:
		_deck.append(q.duplicate(true))
	_deck.shuffle()

func get_next_question() -> Dictionary:
	if _deck.is_empty():
		reset()
	return _deck.pop_front()

