import 'azalea_menu.dart';

const brickstoneCafeWebsiteUrl = 'https://brickstonecafe.com/';
const brickstoneCafeMenuUrl =
    'https://o.spoton.com/BL-2414-0A61-01F0?rwg_token=AE37R_jsNZAKPpAJ697VnlkNdyFpFfdNod72sYLyPmvJKUI-hT6D58ywObL4Tp-IiNaKRIKVdCsXmMaeAuX4qo9U_chhr29iMw%3D%3D';
const brickstoneCafeAddress = '66 Broad St NW, Atlanta, GA 30303';

// Snapshot transcribed from BrickStone's linked SpotOn pickup menu on Oct 24,
// 2026. Group prices are preserved as listed; checkout can change by options.
MenuListing _brickstoneItem(
  String section,
  String name,
  int priceCents, [
  String description = '',
]) => MenuListing(
  section: section,
  name: name,
  description: description,
  priceCents: priceCents,
  priceUnit: 'item',
);

final brickstoneCafeMenu = <MenuListing>[
  _brickstoneItem(
    'Pizzas',
    'Cheese Pizza',
    450,
    'Tomato sauce, mozzarella, and parmesan cheese.',
  ),
  _brickstoneItem(
    'Pizzas',
    'Pepperoni Pizza',
    550,
    'Beef pepperoni, tomato sauce, mozzarella, and parmesan cheese.',
  ),
  _brickstoneItem(
    'Pizzas',
    'Meat Lover’s Pizza',
    550,
    'Beef, beef pepperoni, chicken, tomato sauce, mozzarella, and parmesan cheese.',
  ),
  _brickstoneItem(
    'Pizzas',
    'Chicken Pesto Pizza',
    550,
    'Baked chicken, pesto sauce, tomato sauce, mozzarella, and parmesan cheese.',
  ),
  _brickstoneItem(
    'Pizzas',
    'Chicken Supreme Pizza',
    550,
    'Chicken, onions, green peppers, olives, tomato sauce, mozzarella, and parmesan cheese.',
  ),
  _brickstoneItem(
    'Pizzas',
    'Veggie Lover’s Pizza',
    550,
    'Mixed vegetables, tomato sauce, mozzarella, and parmesan cheese.',
  ),
  _brickstoneItem(
    'Pizzas',
    'Chicken Alfredo Pizza',
    550,
    'Alfredo sauce, baked chicken, mozzarella, and parmesan cheese.',
  ),
  _brickstoneItem(
    'Pizzas',
    'Chicken Pizza',
    550,
    'Baked chicken, tomato sauce, mozzarella, and parmesan cheese.',
  ),
  _brickstoneItem(
    'Pizzas',
    'Shrimp Alfredo Pizza',
    550,
    'Alfredo sauce, shrimp, mozzarella, and parmesan cheese.',
  ),
  _brickstoneItem(
    'Toasted Subs',
    'Chicken Pesto Sub',
    1195,
    'Baked chicken with pesto sauce (no nuts).',
  ),
  _brickstoneItem(
    'Toasted Subs',
    'Balsamic Chicken Sub',
    1195,
    'Baked chicken with balsamic sauce.',
  ),
  _brickstoneItem('Toasted Subs', 'Chicken Caesar Sub', 1195),
  _brickstoneItem(
    'Toasted Subs',
    'Chicken Parmesan Sub',
    1195,
    'Fried chicken fillet with tomato basil sauce and melted mozzarella.',
  ),
  _brickstoneItem(
    'Toasted Subs',
    'Buffalo Chicken Sub',
    1195,
    'Baked chicken tossed in buffalo sauce, mayo, lettuce, tomato, onions, and cheese.',
  ),
  _brickstoneItem(
    'Toasted Subs',
    'French Dip Sub',
    1195,
    'Roast beef, melted mozzarella, French baguette, and au jus.',
  ),
  _brickstoneItem(
    'Toasted Subs',
    'Roast Beef Melt Croissant',
    1195,
    'Roast beef on croissant with melted cheese.',
  ),
  _brickstoneItem(
    'Toasted Subs',
    'Rosemary Chicken Sub',
    1195,
    'Baked chicken with rosemary sauce.',
  ),
  _brickstoneItem(
    'Toasted Subs',
    'Grilled Chicken Sub',
    1195,
    'Grilled chicken on homemade baguette.',
  ),
  _brickstoneItem(
    'Toasted Subs',
    'Turkey Melt Sub',
    1195,
    'Smoked turkey, melted mozzarella, on homemade bread.',
  ),
  _brickstoneItem('Toasted Subs', 'Roasted Vegetables Sub', 1195),
  _brickstoneItem(
    'Cold Sandwiches',
    'Chicken Salad Sandwich',
    925,
    'Chicken, celery, mayo, secret seasoning, and baguette.',
  ),
  _brickstoneItem(
    'Cold Sandwiches',
    'Roast Beef Sandwich',
    1050,
    'Roast beef, lettuce, tomato, onion, mayo, mozzarella, and baguette.',
  ),
  _brickstoneItem(
    'Cold Sandwiches',
    'Smoked Turkey Pesto Sandwich',
    925,
    'Turkey, lettuce, tomato, onion, mayo, mozzarella, pesto (no nuts), and baguette.',
  ),
  _brickstoneItem(
    'Cold Sandwiches',
    'Smoked Turkey Sandwich',
    925,
    'Turkey, lettuce, tomato, onion, mayo, mozzarella, and baguette.',
  ),
  _brickstoneItem(
    'Pastas',
    'Chicken Burgundy Pasta',
    1279,
    'Penne with burgundy (creamy tomato) sauce, baked chicken, and parmesan.',
  ),
  _brickstoneItem(
    'Pastas',
    'Meatball Beef Burgundy Pasta',
    1275,
    'Penne with burgundy (creamy tomato) sauce, meatballs, and parmesan.',
  ),
  _brickstoneItem(
    'Pastas',
    'Shrimp Alfredo Pasta',
    1479,
    'Fettuccine with creamy alfredo sauce, shrimp, and parmesan.',
  ),
  _brickstoneItem(
    'Pastas',
    'Chicken Tomato Basil Penne Pasta',
    1150,
    'Penne with tomato basil sauce, baked chicken, and parmesan.',
  ),
  _brickstoneItem(
    'Pastas',
    'Tomato Basil Penne Pasta',
    945,
    'Penne with tomato basil sauce and parmesan.',
  ),
  _brickstoneItem(
    'Pastas',
    'Fettuccine Alfredo Pasta',
    945,
    'Fettuccine with creamy alfredo sauce and parmesan.',
  ),
  _brickstoneItem(
    'Pastas',
    'Chicken Alfredo Pasta',
    1150,
    'Fettuccine with creamy alfredo sauce, baked chicken, and parmesan.',
  ),
  _brickstoneItem('Pastas', 'Pesto Pasta Salad', 1055),
  _brickstoneItem(
    'Salads',
    'Chicken Balsamic Salad',
    1200,
    'Romaine, parmesan, croutons, baked chicken, and balsamic dressing.',
  ),
  _brickstoneItem(
    'Salads',
    'Chicken Caesar Salad',
    1200,
    'Romaine, parmesan, croutons, baked chicken, and Caesar dressing.',
  ),
  _brickstoneItem(
    'Salads',
    'Balsamic Salad',
    900,
    'Romaine, parmesan, croutons, and balsamic dressing.',
  ),
  _brickstoneItem(
    'Salads',
    'Caesar Salad',
    1150,
    'Romaine, parmesan, croutons, and Caesar dressing.',
  ),
  _brickstoneItem(
    'Soups',
    'Cream of Broccoli Soup',
    525,
    'Creamy broccoli soup with special seasonings.',
  ),
  _brickstoneItem(
    'Soups',
    'French Onion Soup',
    525,
    'Beef broth with onions, croutons, and melted mozzarella.',
  ),
  _brickstoneItem(
    'Soups',
    'Tomato Basil Soup',
    525,
    'Creamy tomato soup with cream and fresh basil.',
  ),
  _brickstoneItem(
    'Combos',
    'Brickstone Trio',
    1765,
    'Sandwich, soup, and salad.',
  ),
  _brickstoneItem(
    'Combos',
    'Sandwich & Salad Combo',
    1455,
    'Sandwich with Caesar, balsamic, or pesto pasta salad.',
  ),
  _brickstoneItem('Combos', 'Salad & Soup Combo', 1355, 'Any salad and soup.'),
  _brickstoneItem(
    'Combos',
    'Sandwich & Soup Combo',
    1455,
    'Any sandwich and soup.',
  ),
  _brickstoneItem('Combos', 'Trio Salad', 1375, 'Any three salads.'),
  _brickstoneItem('Combos', 'Pizza Pasta Drink Combo', 1099),
  _brickstoneItem('Sides', 'Side Tomato Basil Penne', 475),
  _brickstoneItem('Sides', 'Side Fettuccine Alfredo', 475),
  _brickstoneItem('Sides', 'Side Pesto Pasta', 495),
  _brickstoneItem('Sides', 'Side Burgundy', 495),
  _brickstoneItem('Sides', 'Side Balsamic Salad', 425),
  _brickstoneItem('Sides', 'Side Caesar Salad', 425),
  _brickstoneItem('Sides', 'Cheesy Garlic Bread', 250),
  _brickstoneItem('Sides', 'Garlic Bread', 150),
  _brickstoneItem('Sides', 'Side Sauce', 65),
  _brickstoneItem('Sides', 'Chips', 150),
  _brickstoneItem('Drinks', 'Water', 149),
  _brickstoneItem(
    'Drinks',
    'Canned Drinks',
    195,
    'Choose a can in the restaurant ordering menu.',
  ),
  _brickstoneItem(
    'Drinks',
    'Bottled Drinks',
    269,
    'Choose a bottle in the restaurant ordering menu.',
  ),
];

const brickstoneCafeSections = [
  'Pizzas',
  'Toasted Subs',
  'Cold Sandwiches',
  'Pastas',
  'Salads',
  'Soups',
  'Combos',
  'Sides',
  'Drinks',
];
