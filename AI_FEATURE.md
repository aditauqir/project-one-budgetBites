# Lunch Lens

Lunch Lens gives a price estimate when someone plans or logs a meal. It looks at the last three eligible prices for that meal and picks the middle one. The estimate gives the user an idea of what the meal might cost.

## Methodology

1. It uses confirmed purchases for the same saved meal. Prices are stored in US cents, with the purchase date and receipt ID.

2. Plans, other meals, negative amounts, later purchases, and the purchase being edited don't count. The rule accepts zero as a price.

3. It takes the three newest eligible purchases. If two have the same time, the receipt ID decides their order. It sorts their prices and picks the middle one, called the median. With fewer than three, there is no estimate.

4. We compare it with the **last observed price**, which is the newest eligible price. The app keeps that value for comparison but shows the median and the three prices on screen.

5. The calculation is in [`estimateLunch`](lib/logic/lunch_lens.dart), and the explanation and hide/show control are in [`LunchLens`](lib/widgets/lunch_lens.dart).

## Why median?

We first had a mean of three prices. We changed it to the median because one expensive or cheap purchase can throw the mean off. After we entered a $25 purchase alongside $16.25 and $16.50, the median was $16.50. The mean of those prices would be $19.25. The median can be slow to catch up when prices really change. The last price reacts faster, but it can also pick up a one-time outlier.

## Example cases and baseline comparison

We ran the Flutter app on the Android emulator using the existing Chicken Bibimbap demo history. We then entered $16.25, $25.00 and $16.00 as three more test purchases, in that order. These are app test entries, not actual customer receipts. Before each new entry, we recorded the estimate and compared it with the next entered price. Prices below are oldest to newest, so the last input is the last-price baseline. Error is the difference from the next entered price.

| Case | Three eligible prices | Median suggestion | Last-price baseline | Next entered price | Median error | Baseline error |
|---|---|---:|---:|---:|---:|---:|
| Normal price | $15.50, $16.00, $16.50 | $16.00 | $16.50 | $16.25 | $0.25 | $0.25 |
| Price jumps | $16.00, $16.50, $16.25 | $16.25 | $16.25 | $25.00 | $8.75 | $8.75 |
| After a high outlier | $16.50, $16.25, $25.00 | $16.50 | $25.00 | $16.00 | $0.50 | $9.00 |
| Fewer than three: Beef Taco | $4.50, $6.00 | No suggestion | $6.00 | Not scored | Not scored | Not scored |
| No purchases | None | No suggestion | None | Not scored | Not scored | Not scored |

Across the **three scored test entries**, the average absolute error was **$3.17** for the median and **$6.00** for the last price, rounded to cents. Both methods missed the sudden jump to $25 by $8.75. After that outlier, the median was closer to the next $16 entry. This is a small demo sequence entered for the test, so it doesn't show which method is better for real purchases.

## Control, offline use, and limitations

The user can change the price to what they actually paid and hide or show Lunch Lens. It won't save anything on its own. The screen shows the three prices it used, since the next price might be different.

The math runs on the phone using saved purchases, with no network request. SQLite stores purchases and SharedPreferences stores settings. For the offline check, turn on airplane mode, reopen the app, and look at a saved meal and its Lunch Lens result.

It needs three eligible purchases for the same meal. It doesn't account for store changes, deals, inflation, or other reasons a price goes up or down. Next, we could compare the median and last price with later real purchases before changing the rule.

The existing [`test/lunch_lens_test.dart`](test/lunch_lens_test.dart) has cases from the old mean rule. Some expected values still need updating for the median, so we can't use that file as passing test evidence for the current rule yet.
