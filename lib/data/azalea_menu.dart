class MenuListing {
  const MenuListing({
    required this.section,
    required this.name,
    required this.description,
    required this.priceCents,
    this.minimumQuantity = 1,
    this.priceUnit = 'unspecified',
    this.priceMaxCents,
  });

  final String section;
  final String name;
  final String description;
  final int priceCents;
  final int? priceMaxCents;
  final int minimumQuantity;
  final String priceUnit;

  int get minimumOrderEstimateCents => priceCents * minimumQuantity;
}

const azaleaWebsiteUrl = 'https://azaleamarket.com/';
const azaleaCateringMenuUrl =
    'https://order.tryotter.com/s/catering/25-peachtree-st%2C-atlanta%2C-ga-30303%2C-usa-atlanta/e5da3d43-85a1-4d54-ac2e-076f4b12173b';
const azaleaAddress = '25 Peachtree St NW, Atlanta, GA 30303';
const azaleaCateringSections = [
  'Box Meals',
  'Buffet',
  'Platters',
  'Large Salad',
  'Large Sides',
  'Beverages',
  'Appetizers',
];

// Local snapshot of the menu linked from Azalea's order page, checked Oct 24, 2026.
// Prices and serving/minimum-order notes are transcribed from the visible listing.
const azaleaCateringMenu = <MenuListing>[
  MenuListing(
    section: 'Box Meals',
    name: 'Box Breakfast',
    description:
        'Choice of breakfast burrito or sandwich, cut fruit (minimum 10).',
    priceCents: 1200,
    minimumQuantity: 10,
    priceUnit: 'each',
  ),
  MenuListing(
    section: 'Box Meals',
    name: 'Box Lunch',
    description: 'Choice of sandwich or salad, side, and fresh baked chocolate chip cookie (minimum 10).',
    priceCents: 1500,
    minimumQuantity: 10,
    priceUnit: 'each',
  ),
  MenuListing(
    section: 'Buffet',
    name: 'Meat & Three Buffet',
    description:
        r'$16 per person; choice of protein and three sides (minimum 10).',
    priceCents: 1600,
    minimumQuantity: 10,
    priceUnit: 'per person',
  ),
  MenuListing(
    section: 'Buffet',
    name: 'Breakfast Buffet',
    description: 'Scrambled eggs, Southwest quinoa, smashed avocado, green chili, and pickled onion (minimum 10).',
    priceCents: 1200,
    minimumQuantity: 10,
    priceUnit: 'per person',
  ),
  MenuListing(
    section: 'Platters',
    name: 'Pizza',
    description: 'Choice of 4 pizzas; feeds 8–10.',
    priceCents: 5500,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Platters',
    name: 'Sandwich Platter',
    description: 'Choice of three sandwiches; feeds 10.',
    priceCents: 8000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Platters',
    name: 'Family Style Pasta',
    description:
        'Choice of pasta, sauce, protein, and vegetables (minimum 10 people).',
    priceCents: 8000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Platters',
    name: 'Pastry Platter',
    description: 'Assortment of muffins, danishes, and bagels; feeds 10.',
    priceCents: 5000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Platters',
    name: 'Crudite Platter',
    description: 'Carrot, celery, zucchini, cucumber, cherry tomato, chipotle ranch, and roasted red pepper hummus; feeds 10.',
    priceCents: 6000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Platters',
    name: 'Charcuterie Platter',
    description: 'Artisanal meats and cheeses, crackers, local mustard, and fig spread; feeds 10.',
    priceCents: 10000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Platters',
    name: 'Fruit Platter',
    description: 'Mixed cut fruit with yogurt dip and caramel dip; feeds 10.',
    priceCents: 5000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Platters',
    name: 'Dessert Platter',
    description:
        'Fresh baked cookies, brownies, and assorted sweets; feeds 10.',
    priceCents: 5000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Salad',
    name: 'Southwest Chicken Salad',
    description: 'Large salad; feeds 10.',
    priceCents: 7500,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Salad',
    name: 'Thai Sweet Potato Salad (vegan)',
    description: 'Large salad; feeds 10.',
    priceCents: 7500,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Salad',
    name: 'Kale Brussel Chicken Caesar',
    description: 'Large salad; feeds 10.',
    priceCents: 7500,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Salad',
    name: 'Steakhouse Salad',
    description: 'Large salad; feeds 10.',
    priceCents: 9000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Salad',
    name: 'Garden Salad',
    description: 'Large salad; feeds 10.',
    priceCents: 5000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Sides',
    name: 'Mac and Cheese',
    description: 'Large side, 64 oz.',
    priceCents: 4500,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Sides',
    name: 'Lemon Garlic Brussel Sprouts',
    description: 'Large side, 64 oz.',
    priceCents: 4000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Sides',
    name: 'Mixed Vegetable',
    description: 'Large side, 64 oz.',
    priceCents: 3500,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Sides',
    name: 'Roast Sweet Potato',
    description: 'Large side, 64 oz.',
    priceCents: 4000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Sides',
    name: 'Cauliflower Mash',
    description: 'Large side, 64 oz.',
    priceCents: 4500,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Sides',
    name: 'Garlic Herb Red Bliss Potatoes',
    description: 'Large side, 64 oz.',
    priceCents: 4000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Sides',
    name: 'Italian Bowtie Pasta Salad',
    description: 'Large side, 64 oz.',
    priceCents: 3500,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Sides',
    name: 'Fire Roasted Pasta Salad',
    description: 'Large side, 64 oz.',
    priceCents: 4000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Sides',
    name: 'Steakhouse Potato Salad',
    description: 'Large side, 64 oz.',
    priceCents: 4500,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Sides',
    name: 'Mustard Potato Salad',
    description: 'Large side, 64 oz.',
    priceCents: 3000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Sides',
    name: 'Jalapeno Slaw',
    description: 'Large side, 64 oz.',
    priceCents: 3000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Sides',
    name: 'Udon Noodle Salad',
    description: 'Large side, 64 oz.',
    priceCents: 4500,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Sides',
    name: 'Broccoli Salad',
    description: 'Large side, 64 oz.',
    priceCents: 4500,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Large Sides',
    name: 'Crispy Cucumber Quinoa Salad',
    description: 'Large side, 64 oz.',
    priceCents: 4500,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Beverages',
    name: 'Coffee',
    description: '64 oz coffee with creamer, sweeteners, stirrers, and cups.',
    priceCents: 2500,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Beverages',
    name: 'Spindrift - Pink Lemonade - 8 pack',
    description: '8-pack.',
    priceCents: 1000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Beverages',
    name: 'Spindrift - Lemon Lime - 8 pack',
    description: '8-pack.',
    priceCents: 1000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Beverages',
    name: 'Spindrift - Orange Mango - 8 pack',
    description: '8-pack.',
    priceCents: 1000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Beverages',
    name: 'Spindrift - Half & Half - 8 pack',
    description: '8-pack.',
    priceCents: 1000,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Beverages',
    name: 'Coke - 8 pack',
    description: '8-pack.',
    priceCents: 800,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Beverages',
    name: 'Sprite - 8 pack',
    description: '8-pack.',
    priceCents: 800,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Beverages',
    name: 'Diet Coke - 8 pack',
    description: '8-pack.',
    priceCents: 800,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Beverages',
    name: 'Orange Juice (64 oz)',
    description: '64 oz.',
    priceCents: 800,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Beverages',
    name: 'Apple Juice (64 oz)',
    description: '64 oz.',
    priceCents: 800,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Beverages',
    name: 'Lemonade (64 oz)',
    description: '64 oz.',
    priceCents: 800,
    priceUnit: 'package',
  ),
  MenuListing(
    section: 'Beverages',
    name: 'Ardens Cold Pressed Green Juice',
    description: '',
    priceCents: 500,
  ),
  MenuListing(
    section: 'Beverages',
    name: 'Ardens Cold Pressed Tropical Juice',
    description: '',
    priceCents: 500,
  ),
  MenuListing(
    section: 'Beverages',
    name: 'Ardens Cold Pressed Strawberry Banana Juice',
    description: '',
    priceCents: 500,
  ),
  MenuListing(
    section: 'Appetizers',
    name: 'Bruschetta with Burrata & Coppa',
    description: 'Tomato bruschetta with burrata mozzarella, coppa, and red wine drizzle.',
    priceCents: 4250,
  ),
  MenuListing(
    section: 'Appetizers',
    name: 'Beef Tenderloin Crostini',
    description: 'Sliced beef tenderloin, caramelized onions, horseradish aioli, atop toasted crostini.',
    priceCents: 7500,
  ),
  MenuListing(
    section: 'Appetizers',
    name: 'Crab Cakes',
    description:
        'Jumbo lump crab cake, corn avocado pepper salsa, and mustard aioli.',
    priceCents: 7250,
  ),
  MenuListing(
    section: 'Appetizers',
    name: 'Chicken Satay',
    description: 'Chicken satay, toasted crushed peanuts, and Asian savory peanut sauce.',
    priceCents: 5000,
  ),
  MenuListing(
    section: 'Appetizers',
    name: 'Angus Sliders',
    description: 'Certified Angus beef sliders, kosher dill pickles, Vermont cheddar, caramelized onions, and burger sauce.',
    priceCents: 5850,
  ),
  MenuListing(
    section: 'Appetizers',
    name: 'Wings',
    description: 'Lemon pepper hot chicken wings.',
    priceCents: 4500,
  ),
  MenuListing(
    section: 'Appetizers',
    name: 'Shrimp Cocktail',
    description: 'Shrimp cocktail, spicy cocktail sauce, horseradish aioli, and shooter shot.',
    priceCents: 7500,
  ),
  MenuListing(
    section: 'Appetizers',
    name: 'Fried Chicken Sliders',
    description:
        'Fried chicken slider, kosher dill pickles, and chipotle ranch.',
    priceCents: 5850,
  ),
  MenuListing(
    section: 'Appetizers',
    name: 'Veggie Pinwheel',
    description: 'Pimento cheese, mixed peppers, kale, mushroom, caramelized onion, and spinach wrap.',
    priceCents: 3750,
  ),
  MenuListing(
    section: 'Appetizers',
    name: 'Stuffed Mushroom',
    description: 'Stuffed mushrooms with pimento cheese.',
    priceCents: 3750,
  ),
  MenuListing(
    section: 'Appetizers',
    name: 'Spring Rolls',
    description: 'Spring roll with carrot, cabbage, assorted peppers, and sweet chili sauce.',
    priceCents: 5000,
  ),
  MenuListing(
    section: 'Appetizers',
    name: 'Santa Fe Egg Roll',
    description: 'Santa Fe chicken egg roll, savory corn bean pepper ragout, and spicy aioli.',
    priceCents: 5000,
  ),
  MenuListing(
    section: 'Appetizers',
    name: 'Buffalo Chicken Pinwheel',
    description: 'Buffalo chicken pinwheel, celery, Gorgonzola cream sauce, and matchstick carrots.',
    priceCents: 4750,
  ),
  MenuListing(
    section: 'Appetizers',
    name: 'Truffle Mushroom Crostini',
    description: 'Assorted mushrooms, goat cheese, toasted crostini, truffle oil, and red wine essence.',
    priceCents: 5500,
  ),
];
