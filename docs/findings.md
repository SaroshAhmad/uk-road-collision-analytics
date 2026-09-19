# Findings

**Data:** DfT STATS19 police-reported injury collisions, Great Britain, 2021–2025
**Scope:** 513,801 collisions, 652,821 casualties, 937,265 vehicles
**Main measure:** the **serious-or-fatal rate** — of collisions in a given situation, the percentage that were serious or fatal
**Baseline:** **24.21%** serious or fatal; **1.47%** fatal

> Counts show where collisions happen (mostly, where the traffic is). Rates show where they are dangerous. Conclusions below rest on rates.

---

## 0. A trend that isn't real (read this before any time comparison)

The serious-or-fatal rate rose every year: 22.51% (2021) to 26.24% (2025). It is **not** a road-safety change.

- Collision volumes were flat (101,087 → 101,525) and so were deaths (1,474 → 1,453).
- Police forces moved from officer-judgement severity to injury-based recording, which classifies more injuries as serious. The injury-based share went from 50% of collisions in 2021 to 87% in 2025.
- Each method's own rate stayed roughly flat: injury-based ~27%, officer judgement ~19%.
- Weighted arithmetic reproduces the headline exactly: 2021 = (0.50 × 26.5) + (0.50 × 18.6) = 22.5%; 2025 = (0.87 × 27.0) + (0.13 × 21.4) = 26.2%.

**Consequences:** no severity trend over time is reported; where a trend is needed, the **fatal rate** is used (flat at 1.43–1.51%); every other comparison pools all five years.

---

## 1. Speed limit is the strongest single factor

| Speed limit | Collisions | Serious or fatal | Fatal |
|---|---|---|---|
| 20 | 88,096 | 19.65% | 0.47% |
| 30 | 267,325 | 22.65% | 0.87% |
| 40 | 44,750 | 25.69% | 1.80% |
| 50 | 22,666 | 28.35% | 2.89% |
| 60 | 62,703 | **34.49%** | **3.84%** |
| 70 | 28,258 | 24.62% | 3.37% |

- A collision on a 60mph road is about **8 times more likely to be fatal** than one on a 30mph road.
- **70mph is the exception**: motorways carry the highest limit but a lower serious rate than 60mph roads. Motorways separate traffic and remove junctions and pedestrians; 60mph roads are undivided rural A- and B-roads with bends, hedges and side turnings.
- **Road design matters as much as the posted limit.**

## 2. Single carriageways: most collisions and the highest rate

| Road type | Collisions | Serious or fatal |
|---|---|---|
| Single carriageway | 373,065 | **25.94%** |
| Dual carriageway | 76,119 | 22.89% |
| Slip road | 8,829 | 17.94% |
| One-way street | 11,550 | 17.75% |
| Roundabout | 31,178 | 17.21% |

Undivided roads combine oncoming traffic with higher limits. Roundabouts are the safest common layout, because everyone is slowing and turning.

## 3. The most dangerous hours are the quietest ones

| Hour | Collisions | Serious or fatal |
|---|---|---|
| 00:00–05:00 | ~29,000 | **~30.5%** |
| 08:00 | 32,860 | 19.41% |
| 17:00 (peak volume) | 44,792 | 23.14% |

Rush hour produces the most collisions and the least severe ones: congested, low-speed impacts. The small hours produce few collisions but fast ones on empty roads, with a different mix of drivers.

**A count-based chart would say "avoid 5pm". The rate says the opposite.**

## 4. Weekends and nights are separate effects, and they stack

| | Day (06–17) | Evening (18–23) | Night (00–05) |
|---|---|---|---|
| **Weekday** | 22.36% | 25.34% | 29.82% |
| **Weekend** | 25.90% | 26.77% | **31.26%** |

- Night is worse than day on weekdays (+7.5 points) and weekends (+5.4).
- Weekends are worse than weekdays **at every time of day**, including daytime (+3.5), so the weekend effect is not just Saturday nights. It points to leisure and rural driving rather than commuting.
- Worst combination: weekend nights at 31.26%, about 1.3× the baseline.

## 5. Summer is more severe than winter

| Month | Collisions | Serious or fatal |
|---|---|---|
| August | 42,591 | **26.18%** |
| July | 45,204 | 25.17% |
| November (most collisions) | 46,835 | 23.49% |
| January | 39,815 | 22.79% |

Winter produces more collisions but less severe ones. Summer brings higher speeds, more rural and leisure driving, and more motorcyclists and cyclists, who have no bodywork protecting them.

## 6. Bad weather is not the danger people assume

| Weather | Collisions | Serious or fatal |
|---|---|---|
| Fine + high winds | 4,472 | **29.74%** |
| Fog or mist | 2,128 | 28.05% |
| Raining + high winds | 5,173 | 26.77% |
| Fine, no high winds | 413,632 | 24.74% |
| Raining, no high winds | 55,834 | **24.01%** |
| Snowing, no high winds | 1,791 | 22.67% |

Road surface tells the same story: dry 24.29%, wet 25.36%, **frost or ice 22.65%**.

Rain, ice and snow make drivers slow down. Fine weather makes them confident. Adverse conditions raise the *number* of collisions but not their severity.

## 7. Darkness matters, but less than the roads that are unlit

Raw comparison:

| Light | Collisions | Serious or fatal |
|---|---|---|
| Daylight | 368,193 | 23.19% |
| Darkness, lights lit | 105,834 | 25.11% |
| Darkness, no lighting | 27,438 | **34.95%** |

Holding the speed limit constant separates the two effects:

| | Daylight | Dark, lit | Dark, unlit |
|---|---|---|---|
| **30mph** | 21.43% | 25.97% | 29.09% |
| **60mph** | 34.15% | 28.92% | **36.97%** |

- Within 30mph roads, unlit darkness adds about 8 points, so darkness has a real effect of its own.
- But the speed limit matters more: **daylight on a 60mph road (34.15%) is worse than unlit darkness on a 30mph road (29.09%)**.
- Unlit roads are mostly rural 60mph roads, so the raw 34.95% figure was largely the rural road effect, with a genuine darkness effect on top.

## 8. Driver age: a U-shape, with the older end worse

| Age band | Vehicles | Serious or fatal |
|---|---|---|
| 16–20 | 62,478 | 26.81% |
| 21–25 | 86,615 | 23.47% |
| 26–35 | 187,204 | **21.98%** (lowest) |
| 36–45 | 154,262 | 22.63% |
| 46–55 | 125,729 | 24.68% |
| 56–65 | 94,930 | 27.51% |
| 66–75 | 43,084 | 29.43% |
| Over 75 | 30,395 | **30.86%** |

Insurers price young drivers hardest, yet drivers over 75 are involved in the most severe collisions in this data. Two distinct reasons, and they are not the same thing: older people are **physically more fragile**, so the same impact produces a worse injury, and they drive proportionally more on rural roads.

**Important caveat:** this measures the severity of collisions a driver group was *involved in* — not fault, and not frequency. Young drivers still have far more collisions per mile driven. Bands under 11 are pedal cycles and similar, not motor vehicles.

## 9. Motorcycles are in a category of their own

| Vehicle type | Vehicles | Serious or fatal |
|---|---|---|
| Motorcycle over 500cc | 23,011 | **52.77%** |
| Electric motorcycle | 1,902 | 42.06% |
| Motorcycle 125–500cc | 9,590 | 37.86% |
| Goods 7.5t and over | 13,247 | 30.87% |
| Pedal cycle | 81,486 | 25.89% |
| Car | 637,681 | 21.08% |
| Taxi / private hire | 15,362 | 18.90% |

More than **one in two** collisions involving a large motorcycle is serious or fatal — about 2.5× the rate for cars. No crumple zone, no seatbelt, no shell.

## 10. Who actually gets hurt: the third-party exposure

| Casualty type | Casualties | Deaths | Fatal rate |
|---|---|---|---|
| Car occupant | 347,393 | 3,471 | 1.00% |
| **Pedestrian** | 94,398 | **1,924** | **2.04%** |
| Cyclist | 77,741 | 450 | 0.58% |
| Motorcycle 125cc and under | 41,840 | 322 | 0.77% |
| **Motorcycle over 500cc** | 22,542 | **1,120** | **4.97%** |
| Bus or coach occupant | 10,565 | 20 | 0.19% |

- **Pedestrians are 14% of casualties but 25% of all deaths.** They have no vehicle around them.
- **Large motorcycles produce 1,120 deaths from 22,542 casualties** — five times the car-occupant fatal rate.
- **Cyclists appear often but die comparatively rarely** (0.58%), because most cycle collisions happen at urban speeds.

**For a motor insurer this is the exposure that matters:** a pedestrian or motorcyclist struck by a car generates a far larger claim than a car-to-car impact.

---

## Data quality notes (not findings about roads)

- Categories recorded as "Unknown" or "unknown (self reported)" show unusually **low** severity: unknown weather 11.72%, unknown road surface 7.10%, unknown road type 8.99%. These are mostly self-reported minor collisions, where the public completes a form rather than an officer attending. They should be footnoted or excluded, not read as safe conditions.
- "Not recorded" (our label for missing data) is separate from DfT's own "Unknown" category and is very small: 12 collisions for weather, 3,527 for road surface.

## Limitations

1. **Police-reported injury collisions only.** Damage-only crashes and unreported injuries are absent.
2. **No traffic volume data.** These are severity rates *given a collision*, not risk per mile driven. A road type with a high rate is not necessarily one to avoid.
3. **Severity is police-assessed**, not medically confirmed, and the recording method changed during the period (section 0).
4. **Correlation, not causation.** Factors move together: night, unlit roads, rural 60mph limits and younger drivers overlap. Where possible, effects have been separated by holding one factor constant.
5. **2025 figures may be provisional** and subject to revision.
