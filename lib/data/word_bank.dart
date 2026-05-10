import 'package:flutter/material.dart';

class WordCategory {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final List<String> easy;
  final List<String> medium;
  final List<String> hard;
  final bool isCustom;

  const WordCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.easy,
    required this.medium,
    required this.hard,
    this.isCustom = false,
  });

  /// Returns words filtered by difficulty.
  /// 'easy' => easy only, 'medium' => medium only, 'hard' => hard only, 'all' => everything
  List<String> getWords(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return List<String>.from(easy);
      case 'medium':
        return List<String>.from(medium);
      case 'hard':
        return List<String>.from(hard);
      default:
        return [...easy, ...medium, ...hard];
    }
  }
}

class WordBank {
  // ─────────────────────────────────────────────────────────────────────────────
  // DEVELOPERS: To add new categories, add a new WordCategory entry below.
  // To add words to an existing category, find it by its 'id' and add to the
  // easy / medium / hard list. The UI will automatically reflect your changes.
  // ─────────────────────────────────────────────────────────────────────────────
  static const List<WordCategory> defaultCategories = [
    WordCategory(
      id: 'food',
      name: 'Food',
      emoji: '🍕',
      color: Color(0xFFFF6B6B),
      easy: ['Pizza', 'Apple', 'Bread', 'Cake', 'Ice Cream', 'Banana', 'Sandwich', 'Milk', 'Cookie', 'Cheese'],
      medium: ['Spaghetti', 'Hamburger', 'Popcorn', 'Salad', 'Muffin', 'Taco', 'Yogurt', 'Cereal', 'Peanut Butter', 'Chicken'],
      hard: ['Croissant', 'Quiche', 'Sushi', 'Ravioli', 'Guacamole', 'Eggplant', 'Avocado', 'Falafel', 'Pomegranate', 'Wasabi'],
    ),
    WordCategory(
      id: 'animals',
      name: 'Animals',
      emoji: '🐾',
      color: Color(0xFF4ECDC4),
      easy: ['Dog', 'Cat', 'Cow', 'Fish', 'Horse', 'Duck', 'Bird', 'Pig', 'Rabbit', 'Lion'],
      medium: ['Elephant', 'Giraffe', 'Kangaroo', 'Panda', 'Penguin', 'Zebra', 'Bear', 'Monkey', 'Snake', 'Dolphin'],
      hard: ['Armadillo', 'Platypus', 'Narwhal', 'Chameleon', 'Wombat', 'Axolotl', 'Sloth', 'Tarantula', 'Iguana', 'Hedgehog'],
    ),
    WordCategory(
      id: 'movies_tv',
      name: 'Movies & TV',
      emoji: '🎬',
      color: Color(0xFF9B59B6),
      easy: ['Frozen', 'Toy Story', 'Spider-Man', 'Minions', 'Batman', 'Cars', 'Moana', 'Shrek', 'Harry Potter', 'Star Wars'],
      medium: ['Jurassic Park', 'Finding Nemo', 'Black Panther', 'Aladdin', 'Lion King', 'Home Alone', 'E.T.', 'Cinderella', 'Encanto', 'Up'],
      hard: ['Inception', 'Casablanca', 'The Godfather', 'Parasite', 'Interstellar', "Schindler's List", 'Amélie', 'Jaws', 'Titanic', 'La La Land'],
    ),
    WordCategory(
      id: 'sports',
      name: 'Sports & Games',
      emoji: '⚽',
      color: Color(0xFF27AE60),
      easy: ['Soccer', 'Basketball', 'Baseball', 'Football', 'Tennis', 'Hockey', 'Golf', 'Swimming', 'Running', 'Volleyball'],
      medium: ['Badminton', 'Bowling', 'Rugby', 'Skateboarding', 'Surfing', 'Lacrosse', 'Karate', 'Gymnastics', 'Archery', 'Dodgeball'],
      hard: ['Polo', 'Curling', 'Fencing', 'Equestrian', 'Biathlon', 'Triathlon', 'Javelin', 'Bocce', 'Squash', 'Cricket'],
    ),
    WordCategory(
      id: 'places',
      name: 'Places',
      emoji: '🗺️',
      color: Color(0xFF3498DB),
      easy: ['School', 'Park', 'Beach', 'Home', 'Zoo', 'Farm', 'Playground', 'Mall', 'Hospital', 'Library'],
      medium: ['City Hall', 'Stadium', 'Airport', 'Theater', 'Aquarium', 'Museum', 'Restaurant', 'Castle', 'Mountain', 'Bridge'],
      hard: ['Pyramids', 'Eiffel Tower', 'Great Wall', 'Taj Mahal', 'Colosseum', 'Machu Picchu', 'Stonehenge', 'Sydney Opera House', 'Statue of Liberty', 'Mount Everest'],
    ),
    WordCategory(
      id: 'jobs',
      name: 'Jobs & Professions',
      emoji: '👨‍💼',
      color: Color(0xFFE67E22),
      easy: ['Teacher', 'Doctor', 'Chef', 'Farmer', 'Nurse', 'Firefighter', 'Police Officer', 'Singer', 'Athlete', 'Pilot'],
      medium: ['Librarian', 'Engineer', 'Lawyer', 'Dancer', 'Mechanic', 'Scientist', 'Actor', 'Author', 'Soldier', 'Baker'],
      hard: ['Archaeologist', 'Astronomer', 'Mathematician', 'Fashion Designer', 'Diplomat', 'Geologist', 'Biologist', 'Sculptor', 'Politician', 'Architect'],
    ),
    WordCategory(
      id: 'objects',
      name: 'Objects & Things',
      emoji: '🎒',
      color: Color(0xFFE74C3C),
      easy: ['Ball', 'Chair', 'Book', 'Phone', 'Bed', 'Table', 'Shoes', 'Hat', 'Pen', 'Clock'],
      medium: ['Backpack', 'Camera', 'Guitar', 'Bicycle', 'Umbrella', 'Mirror', 'Radio', 'Blanket', 'Suitcase', 'Microwave'],
      hard: ['Telescope', 'Typewriter', 'Microscope', 'Projector', 'Compass', 'Thermometer', 'Accordion', 'Saxophone', 'Sewing Machine', 'Drone'],
    ),
    WordCategory(
      id: 'vehicles',
      name: 'Vehicles',
      emoji: '🚗',
      color: Color(0xFF1ABC9C),
      easy: ['Car', 'Bus', 'Bike', 'Boat', 'Truck', 'Train', 'Plane', 'Taxi', 'Van', 'Scooter'],
      medium: ['Helicopter', 'Motorcycle', 'Sailboat', 'Tractor', 'Submarine', 'Jeep', 'Limousine', 'Hot Air Balloon', 'Skateboard', 'Rocket'],
      hard: ['Segway', 'Monorail', 'Rickshaw', 'Gondola', 'Hovercraft', 'Cable Car', 'Zeppelin', 'Tuk Tuk', 'Snowmobile', 'Amphibious Vehicle'],
    ),
    WordCategory(
      id: 'holidays',
      name: 'Holidays',
      emoji: '🎉',
      color: Color(0xFFF39C12),
      easy: ['Birthday', 'Christmas', 'Halloween', 'Easter', 'New Year', 'Thanksgiving', 'Wedding', 'Graduation', "Valentine's Day", 'Party'],
      medium: ['Fireworks', 'Parade', 'Pumpkin', 'Santa Claus', 'Hanukkah', 'Costume', 'Cake', 'Gift', 'Balloon', 'Turkey'],
      hard: ['Piñata', 'Diwali', 'Ramadan', 'Kwanzaa', 'Lantern Festival', 'Oktoberfest', 'Mardi Gras', 'Passover', 'Holi', 'Cinco de Mayo'],
    ),
    WordCategory(
      id: 'school',
      name: 'School & Learning',
      emoji: '📚',
      color: Color(0xFF8E44AD),
      easy: ['Teacher', 'Desk', 'Book', 'Pencil', 'Eraser', 'Notebook', 'Ruler', 'Backpack', 'Lunch', 'Bus'],
      medium: ['Calculator', 'Globe', 'Blackboard', 'Test', 'Science', 'History', 'Dictionary', 'Marker', 'Recess', 'Homework'],
      hard: ['Microscope', 'Thesis', 'Graduation', 'Laboratory', 'Debate', 'Scholarship', 'Periodic Table', 'Geometry', 'Physics', 'Biology'],
    ),
    WordCategory(
      id: 'silly',
      name: 'Silly & Random',
      emoji: '🤪',
      color: Color(0xFFFF6B9D),
      easy: ['Banana Peel', 'Unicorn', 'Slime', 'Chicken Nugget', 'Bubble', 'Robot', 'Pickle', 'Mustache', 'Toilet', 'Sock'],
      medium: ['Rubber Chicken', 'Disco Ball', 'Llama', 'Kazoo', 'Waffle', 'Flamingo', 'Donut', 'Pirate', 'Dinosaur Costume', 'Taco Truck'],
      hard: ['Whoopee Cushion', 'Platypus', 'Loch Ness Monster', 'Yeti', 'Marshmallow Cannon', 'Giant Rubber Duck', 'Sasquatch', 'Narwhal', 'UFO', 'Time Machine'],
    ),
    WordCategory(
      id: 'fantasy',
      name: 'Fantasy & Myths',
      emoji: '🐉',
      color: Color(0xFF6C5CE7),
      easy: ['Dragon', 'Fairy', 'Wizard', 'Giant', 'Mermaid', 'Troll', 'Elf', 'Unicorn', 'Witch', 'Knight'],
      medium: ['Griffin', 'Phoenix', 'Centaur', 'Minotaur', 'Pegasus', 'Cyclops', 'Goblin', 'Genie', 'Werewolf', 'Vampire'],
      hard: ['Chimera', 'Kraken', 'Basilisk', 'Hydra', 'Leviathan', 'Banshee', 'Sphinx', 'Thunderbird', 'Golem', 'Djinn'],
    ),
    WordCategory(
      id: 'technology',
      name: 'Technology',
      emoji: '💻',
      color: Color(0xFF00B4D8),
      easy: ['Phone', 'Laptop', 'TV', 'Headphones', 'Camera', 'Tablet', 'Mouse', 'Keyboard', 'Watch', 'Remote'],
      medium: ['Drone', 'Printer', 'Microphone', 'Projector', 'Smartwatch', 'Video Game', 'Calculator', 'Telescope', 'Robot', 'Flashlight'],
      hard: ['3D Printer', 'Virtual Reality', 'Quantum Computer', 'Satellite', 'Supercomputer', 'Nanobot', 'Hoverboard', 'AI Assistant', 'Cryptominer', 'Hologram'],
    ),
    WordCategory(
      id: 'nature',
      name: 'Nature & Outdoors',
      emoji: '🌿',
      color: Color(0xFF52B788),
      easy: ['Tree', 'Rock', 'River', 'Sun', 'Moon', 'Flower', 'Grass', 'Mountain', 'Cloud', 'Leaf'],
      medium: ['Volcano', 'Glacier', 'Canyon', 'Desert', 'Jungle', 'Waterfall', 'Ocean', 'Storm', 'Rainbow', 'Cave'],
      hard: ['Aurora Borealis', 'Tsunami', 'Earthquake', 'Meteor', 'Eclipse', 'Black Hole', 'Sandstorm', 'Tornado', 'Coral Reef', 'Fossil'],
    ),
    WordCategory(
      id: 'music',
      name: 'Music & Entertainment',
      emoji: '🎵',
      color: Color(0xFFFF9F43),
      easy: ['Guitar', 'Piano', 'Song', 'Dance', 'Singer', 'Drum', 'Radio', 'Movie', 'Game', 'Stage'],
      medium: ['Violin', 'Trumpet', 'DJ', 'Orchestra', 'Actor', 'Musical', 'Karaoke', 'Popcorn', 'Audience', 'Costume'],
      hard: ['Didgeridoo', 'Harpsichord', 'Theremin', 'Sitar', 'Bagpipes', 'Sousaphone', 'Ballet', 'Opera', 'Mime', 'Shakespeare'],
    ),
  ];
}
