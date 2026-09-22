# UK Road Collision Risk Analysis

### An end-to-end data project: SQL Server data warehouse -> SQL analysis -> Power BI dashboard

This project looks at **513,801 road collisions** reported by police across Great Britain between 2021 and 2025. It is set up like a real-world piece of work for a motor insurance pricing team, aiming to answer a simple question: *where, when, and in what conditions do road accidents become severe?*

![Overview dashboard](powerbi/screenshots/01-overview.png)

---

## The key finding that changed the whole project

When you first look at the data, one trend jumps out: the rate of serious or fatal collisions went up every year, rising from **22.5% in 2021 to 26.2% in 2025**. That looks like a 17% increase in severity while the total number of accidents stayed roughly the same. The obvious headline would be: *UK roads are getting more dangerous.*

However, that headline is wrong.

Actual fatal collisions stayed almost completely flat over the same period (1,474 in 2021 down to 1,453 in 2025, consistently making up about 1.4% to 1.5% of all collisions). Because a death is recorded clearly and accurately, these two numbers disagreeing was a big warning sign that something else was going on.

The real cause was **a change in how police forces record injuries**. Over these five years, police forces moved away from relying on an officer's personal judgement on the scene to using an injury-based recording system, which naturally classifies more injuries as serious. In 2021, only 50% of collisions were recorded using this injury-based method. By 2025, that figure reached 87%.

Crucially, the serious collision rate within each individual method barely changed over time:

| Year | Injury-based recording share | Serious rate (Injury-based) | Serious rate (Officer judgement) | Overall combined rate |
|---|---|---|---|---|
| 2021 | 50% | 26.5% | 18.6% | 22.5% |
| 2025 | 87% | 27.0% | 21.4% | 26.2% |

When you do the math, the apparent increase in danger comes entirely from the shift in how data was collected, not an actual change on the roads. 

**How I handled this in the analysis:**
* I did not report any severity trends over time across the project.
* Where time trends were necessary, I used the fatal collision rate instead.
* For every other comparison, I combined all five years of data so the change in collection methods affected all groups equally.

---

## Key findings

All figures below show **serious-or-fatal rates**: out of all the collisions that happened in a specific situation, what percentage resulted in a serious injury or death. The overall average across all five years is **24.2%**.

> *Note: We look at percentages (rates) rather than total counts. Counts mainly tell you where traffic is heaviest, whereas rates show you where an accident is actually more dangerous.*

**1. Speed limits are the single biggest factor.**
A collision on a 60mph road is **8 times more likely to be fatal** than one on a 30mph road (3.84% compared to 0.87%). However, 70mph motorways break this pattern with a lower overall serious rate (24.6%) than 60mph roads (34.5%). Motorways keep traffic moving in one direction, separate lanes, and remove junctions and pedestrians. Rural 60mph roads are single carriageways with oncoming traffic, sharp turns, and unexpected hazards. **Road layout matters just as much as the speed limit.**

**2. The quietest hours are the most dangerous.**
The evening rush hour at 17:00 sees the highest number of collisions, but it actually has the lowest severity rate of the day (23.1%). By contrast, the hours between midnight and 05:00 have very few collisions, but the highest severity rate (around 30.5%). Heavy traffic causes low-speed bumps; empty roads late at night lead to higher-speed impacts.

**3. Weekend and night risks are separate, and they stack up.**

| | Daytime (06:00 to 17:00) | Evening (18:00 to 23:00) | Late Night (00:00 to 05:00) |
|---|---|---|---|
| **Weekday** | 22.4% | 25.3% | 29.8% |
| **Weekend** | 25.9% | 26.8% | **31.3%** |

Accidents are more severe on weekends across *every* time of day, including daytime. This shows the risk is not just down to late Saturday nights, but also links to leisure trips and driving on unfamiliar rural roads.

**4. Bad weather is not as dangerous as people think.**
Rainy conditions show a severity rate of 24.0%, which is actually slightly below the average. Icy or frosty roads drop even lower to 22.7%. The weather conditions with the highest severity rates are high winds in fine weather (29.7%) and fog (28.1%). Poor weather causes more total accidents to happen, but they tend to be less severe because drivers naturally slow down and pay closer attention.

**5. Darkness matters, but the type of road matters more.**
At first glance, dark unlit roads look terrifying, with a 35.0% severity rate compared to 23.2% in daylight. However, if you compare roads with the same speed limit, the picture changes. On 30mph roads, unlit darkness adds about 8 percentage points to the severity rate. But **daylight on a 60mph rural road (34.2%) is actually more dangerous than unlit darkness on a 30mph street (29.1%)**. Much of the extra danger blamed on darkness is really down to the nature of rural roads.

**6. Driver age forms a U-shape, with older drivers seeing worse outcomes.**
Drivers over 75 years old are involved in collisions with the highest severity rate (30.9%), followed by 16 to 20-year-olds (26.8%). Drivers aged 26 to 35 have the lowest rate (22.0%). This metric measures **how severe the outcome is when a crash happens, not who caused it**. Older people are physically more vulnerable to serious injury, whereas younger drivers still have a much higher overall crash rate per mile driven.

**7. Pedestrians and motorcyclists suffer the worst outcomes.**
Pedestrians account for 14% of all casualties, but make up **25% of all deaths**. Collisions involving a motorcycle over 500cc result in a serious injury or death **52.8%** of the time, compared to 21.1% for cars. Motorcyclists on these larger bikes also have a fatality rate five times higher than car occupants.

![Conditions dashboard](powerbi/screenshots/02-when-conditions.png)

---

## How the technical pipeline works

The data was built using a three-tier **Medallion architecture** inside SQL Server:

```
DfT Raw CSV Files  -->  BRONZE  -->  SILVER  -->  GOLD  -->  Power BI
                       (Raw)       (Clean)     (Star Schema)
```

| Layer | What it does | Why it is used |
|---|---|---|
| **Bronze** | Stores raw CSV data exactly as received, keeping every column as plain text | Gives an exact copy of the source data that never fails to import, making it easy to trace any figure back to the original files |
| **Silver** | Cleans, fixes data types, and replaces numeric codes with readable text labels. UK dates are parsed properly, missing values like `-1` are set to clear descriptions, and key IDs are set up | Acts as a single source of truth for all clean data, rebuilt automatically via a single database procedure |
| **Gold** | Turns the data into a star schema using SQL views (`dim_date` and three facts) | Formats the data into the exact layout Power BI needs for fast querying, without storing duplicate files |

**Scale:** 513,801 collisions, 937,265 vehicles, 652,821 casualties, totaling over 2.1 million rows. A complete clean rebuild of the silver layer takes around 70 seconds.

### Ensuring data quality

Rather than assuming the data imported correctly, every step was tested:

* **Line checks:** Verified raw file line counts against database row counts using PowerShell. They matched exactly.
* **Fan-out checks:** Checked row counts after every table join to make sure no duplicate rows were created.
* **Orphan checks:** Verified that every vehicle and casualty record correctly linked back to a real collision.
* **Date validation:** The source data provides the day of the week in a separate column. I compared the day derived from my converted date against their recorded day: **0 errors across 513,801 rows**, proving the UK date format (`dd/mm/yyyy`) was converted accurately.
* **Sanity checks:** Confirmed speed limits fell between 20 and 70mph, and geographic coordinates landed inside Great Britain.

All test scripts are kept in the `/tests` folder and can be re-run whenever the database is updated.

---

## Project structure

```
├── datasets/reference/    Department for Transport lookup files and codes
├── docs/                 Design decisions, business context, findings, and dashboard layout
├── scripts/
│   ├── 00_init/          Database setup
│   ├── 01_bronze/        Raw data structures and bulk import scripts
│   ├── 02_silver/        Data cleaning routines and stored procedures
│   ├── 03_gold/          Date dimension and analytical views for reporting
│   └── 04_eda/           Exploratory SQL analysis queries
├── tests/                Data quality and validation checks
└── powerbi/              Power BI report file (.pbix) and screenshots
```

**Recommended reading:**
* `docs/decisions.md` logs every technical design choice, why it was made, and what alternatives were considered.
* `docs/findings.md` contains the complete analytical write-up.

---

## How to run this project yourself

**What you need:** SQL Server 2017 or newer, SQL Server Management Studio (SSMS), and Power BI Desktop.

1. Download the latest 5-year CSV files (Collisions, Vehicles, Casualties) and the data guide from the [Department for Transport Road Safety Data page on GOV.UK](https://www.data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-safety-data). *(Raw files are not stored in this repository as they are up to 104 MB).*
2. Save the CSV files in `C:\sql_data\stats19\` (a clear local path your SQL Server can read).
3. Save the `2024_code_list` tab from the data guide as a CSV named `dft_code_list.csv` in that same folder.
4. Open SSMS and run the SQL scripts in this exact order:
   * `scripts/00_init/init_database.sql`
   * `scripts/01_bronze/ddl_bronze.sql`
   * `scripts/01_bronze/load_bronze.sql`
   * `scripts/02_silver/ddl_silver.sql`
   * `scripts/02_silver/proc_load_silver.sql`
   * Run the command: `EXEC silver.load_silver;`
   * `scripts/03_gold/ddl_gold.sql`
5. Run the scripts in the `tests/` folder to confirm everything built properly.
6. Open the Power BI `.pbix` file and connect it to your local `RoadSafetyDW` database.

---

## Limitations of this analysis

1. **Police data only:** This dataset only records collisions where an injury was reported to the police. Minor bumps and unreported accidents are not included, meaning total road incidents are undercounted.
2. **No traffic volume data:** This project measures severity rates *once an accident happens*, rather than the total risk per mile driven. A high severity rate on its own does not mean a road has more total accidents.
3. **Police judgements:** Injury severity is assessed by police officers rather than medical professionals, and the recording method changed during this 5-year window.
4. **Correlation vs causation:** Dark roads, lack of streetlights, 60mph limits, and driver experience often overlap. While I held variables constant where possible, these figures show strong patterns rather than direct proof of cause.
5. **Provisional data:** The most recent year of data (2025) may be revised slightly in future government releases.
6. **Missing details:** Some secondary details had high missing rates (such as vehicle age at 39% missing, and engine size at 25% missing), so they were excluded from the main breakdown.

---

## Next steps for the project

* **Combine with traffic volume data:** Integrate official traffic count data to calculate true risk per vehicle-mile, which is what insurance underwriters need.
* **Include local demographic data:** Bring in neighborhood population and income data to explore regional risk factors.
* **Build predictive models:** Apply logistic regression to isolate the exact impact of each risk factor while holding all others constant.
* **Automate updates:** Set up SQL Server Agent jobs to run the data pipeline automatically and log errors directly to an audit table.

---

## Source and licensing

**Data source:** Department for Transport, Road Safety Data (STATS19), published under the Open Government Licence v3.0.

**Project by:** Ahmad Sarosh · Glasgow, UK
