# Power BI Dashboard Specification

**Report name:** Road Collision Risk Analysis 2021–2025
**Client (fictional):** Northgate Motor Insurance — pricing team
**Canvas:** 16:9, 1280 × 720 px
**Grid:** everything aligned to an 8 px grid; outer margin 24 px; gap between visuals 16 px

---

## 1. Visual identity

### Colour palette

| Role | Hex | Used for |
|---|---|---|
| Primary (brand) | `#123B63` | Page header bar, KPI values, single-series bars |
| Primary light | `#3E6E9E` | Secondary bars, hover states |
| Fatal | `#9B1B30` | Fatal severity only |
| Serious | `#E07A2F` | Serious severity only |
| Slight | `#A8B0BA` | Slight severity only |
| Highlight | `#C9A227` | The one number worth pointing at on a page (use sparingly) |
| Background | `#F5F6F8` | Page background |
| Card | `#FFFFFF` | Visual backgrounds |
| Border | `#E3E6EB` | Card borders, 1 px |
| Text primary | `#1A1D23` | Titles, values |
| Text secondary | `#5A6270` | Labels, axes, footnotes |
| Grid line | `#EDEFF2` | Axis grid lines |

**Sequential scale** (maps, heatmaps, conditional formatting): `#E8EEF4` → `#9DB8D2` → `#3E6E9E` → `#123B63`

**Rules**
1. Severity colours are reserved for severity. Never reuse `#9B1B30` for anything else.
2. Non-severity categorical bars are a single colour (`#123B63`), not a rainbow. Length carries the message, not hue.
3. Use `#C9A227` at most once per page, on the finding that page exists to make.
4. Red means fatal, never "bad" generally. No traffic-light conditional formatting.

### Typography — Segoe UI throughout

| Element | Size | Weight | Colour |
|---|---|---|---|
| Report title (header bar) | 20 pt | Semibold | `#FFFFFF` |
| Page subtitle | 11 pt | Regular | `#D8DEE6` |
| Visual title | 12 pt | Semibold | `#1A1D23` |
| Visual subtitle / note | 9 pt | Regular | `#5A6270` |
| KPI value | 32 pt | Semibold | `#123B63` |
| KPI label | 10 pt | Regular | `#5A6270` |
| Axis and legend | 9 pt | Regular | `#5A6270` |
| Data labels | 9 pt | Semibold | `#1A1D23` |
| Footnote | 8 pt | Regular | `#5A6270` |

### Visual styling rules
- Every visual sits on a white card: 1 px `#E3E6EB` border, 4 px rounded corners, no shadow.
- Turn off: visual borders' default shadow, gridlines on bar charts (keep light gridlines on line charts only), Y-axis labels where data labels are shown.
- Axis lines `#E3E6EB`; no vertical gridlines.
- Sort bars by value descending unless the category has a natural order (hour, month, age band, speed limit).
- Number formats: rates `0.0%`; counts with thousands separators, no decimals; large counts abbreviated (513.8K) in KPIs only.
- Tooltips: include count alongside every rate, so small samples are visible.

---

## 2. Page layout (all three pages share this frame)

```
┌──────────────────────────────────────────────────────────────┐
│ HEADER BAR  #123B63, full width, 72 px tall                  │
│ Title left, page tabs/subtitle left below, slicers right     │
├──────────────────────────────────────────────────────────────┤
│ KPI ROW  4 cards, 100 px tall (Page 1 only)                  │
├──────────────────────────────────────────────────────────────┤
│ VISUAL AREA  2 rows of cards                                 │
├──────────────────────────────────────────────────────────────┤
│ FOOTNOTE STRIP  24 px, 8 pt text                             │
└──────────────────────────────────────────────────────────────┘
```

**Slicers (top right of the header, on every page, synced):** Year, Urban/Rural, Police force. Style: dropdowns, not tiles, so they take little space.

**Footnote (every page, 8 pt, `#5A6270`):**
> Source: DfT STATS19, police-reported injury collisions, Great Britain 2021–2025. Severity rates are shown for collisions that occurred; traffic volume data is not available, so these are not rates per mile driven.

---

## 3. Page 1 — Overview

**Purpose:** the headline picture and the strongest risk factor.

**KPI row (4 cards)**
1. Collisions — 513.8K
2. Casualties — 652.8K
3. Serious or fatal rate — 24.2%
4. Fatal rate — 1.5%

**Row 1**
- **Left (wide): "Fatal rate by year"** — line chart, `#9B1B30`, Y axis starting near the data, data labels on.
  Subtitle: *Deaths are stable. The serious-injury rise reflects a change in police recording, not road safety.*
- **Right: "Severity mix"** — 100% stacked bar, single bar, Fatal / Serious / Slight in severity colours.

**Row 2**
- **Left: "Serious-or-fatal rate by speed limit"** — column chart, ordered 20→70, `#123B63`, with the 60mph column in `#C9A227`.
  Subtitle: *Collisions on 60mph roads are 8× more likely to be fatal than on 30mph roads. Motorways (70) break the pattern.*
- **Right: "Rate by road type"** — horizontal bar, sorted descending, `#123B63`.

---

## 4. Page 2 — When and in what conditions

**Purpose:** the time and conditions story, including the counter-intuitive results.

**Row 1**
- **Left (wide): "Severity by hour of day"** — combo chart: columns = collisions (`#A8B0BA`), line = serious-or-fatal rate (`#123B63`), dual axis.
  Subtitle: *The busiest hour (17:00) is the least severe; the quietest hours are the most severe.*
- **Right: "Day type × time band"** — matrix, rate values, background shading from the sequential scale.
  Highlight: weekend nights 31.3%.

**Row 2**
- **Left: "Rate by month"** — line chart, `#123B63`, months in calendar order.
  Subtitle: *Summer is more severe than winter, despite fewer collisions.*
- **Centre: "Rate by weather"** — horizontal bar, sorted descending, excludes "Unknown" and "Not recorded".
  Subtitle: *Rain, ice and snow produce more collisions but less severe ones.*
- **Right: "Rate by light condition and speed limit"** — clustered bar, 30 vs 60mph.
  Subtitle: *Darkness matters, the speed limit matters more.*

---

## 5. Page 3 — Who is involved and who is hurt

**Purpose:** the exposure picture, which is what a pricing team acts on.

**Row 1**
- **Left: "Rate by driver age band"** — column chart in age order, `#123B63`, over-75 column in `#C9A227`.
  Subtitle: *U-shaped: youngest and oldest drivers are in the most severe collisions. This measures outcome severity, not fault or frequency.*
- **Right: "Rate by vehicle type"** — horizontal bar, top 10 by rate, minimum 1,000 vehicles.
  Subtitle: *A collision involving a 500cc+ motorcycle is 2.5× as severe as one involving a car.*

**Row 2**
- **Left (wide): "Casualties and deaths by road user"** — combo: columns = casualties (`#A8B0BA`), line or markers = fatal rate (`#9B1B30`).
  Subtitle: *Pedestrians are 14% of casualties but 25% of deaths.*
- **Right: "Third-party exposure"** — a small table: road user, casualties, deaths, fatal rate, formatted with the sequential scale on the fatal-rate column.

---

## 6. DAX measures to create

```
Collisions          = COUNTROWS(fact_collision)
Casualties          = SUM(fact_collision[number_of_casualties])
Serious or Fatal    = SUM(fact_collision[is_serious_or_fatal])
Fatal Collisions    = SUM(fact_collision[is_fatal])
Serious or Fatal %  = DIVIDE([Serious or Fatal], [Collisions])
Fatal %             = DIVIDE([Fatal Collisions], [Collisions])
Baseline SF %       = CALCULATE([Serious or Fatal %], REMOVEFILTERS())
vs Baseline (pp)    = ([Serious or Fatal %] - [Baseline SF %]) * 100
Casualty Count      = COUNTROWS(fact_casualty)
Casualty Fatalities = SUM(fact_casualty[is_fatal])
Casualty Fatal %    = DIVIDE([Casualty Fatalities], [Casualty Count])
Vehicles            = COUNTROWS(fact_vehicle)
Vehicle SF %        = DIVIDE(SUM(fact_vehicle[is_serious_or_fatal]), [Vehicles])
```

Use `DIVIDE`, never `/`, so a zero denominator returns blank instead of an error. Format all `%` measures as `0.0%`.

---

## 7. What is deliberately excluded

- **No map on page 1.** Maps look impressive and say little here; geography was not one of the strongest findings, and a map of collision counts would simply show where people live.
- **No severity trend over time** beyond the fatal rate, for the reason in `findings.md` section 0.
- **No pie or donut charts.** Bars are easier to compare.
- **No "Unknown" categories charted** as if they were findings. They are footnoted instead.
- **No gauges, KPI dials, or decorative images.**
