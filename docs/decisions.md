# Decisions Log: UK Road Collision Risk Analytics

This file records each important project decision: **what was decided, why it was decided, and what other options were considered**.
It is updated as the project moves forward.

---

## D-001: Project topic: UK road collision risk
- **Decision:** Look at UK road collisions from the point of view of a motor insurer's pricing team. The fictional insurer is called Magle Motor Insurance.
- **Why:**
  - Motor insurers need to understand and price road collision risk. The practical question is: which conditions are linked to a collision being serious?
  - It connects to my current work in motor insurance, so the business context is familiar.
  - Many beginner portfolios use the same well-known Kaggle datasets, such as Superstore or Titanic. Using a real UK government dataset makes this project more relevant to UK employers.
- **Alternatives considered:** UK house prices (Land Registry), NHS waiting times, and online retail sales. The online retail data is kept for Project 2.

## D-002: Data source: Department for Transport STATS19 data
- **Decision:** Use the official "Road Safety Data" published by the Department for Transport.
- **Why:**
  - It is official data collected by the police using the STATS19 form.
  - It is free and publicly available.
  - It is realistic. The data is split into related tables and uses codes that have to be translated using lookup information. This is similar to how data is often stored inside real organisations.
  - The DfT also provides a guide explaining the columns and codes.
- **Alternatives considered:** Pre-cleaned copies on Kaggle were not used because cleaning the data myself is an important part of what this project is meant to demonstrate.

## D-003: Scope: the last five years of data
- **Decision:** Use the combined last-5-years files for collisions, vehicles and casualties. Year range: **2021–2025, confirmed with SQL (Step 12)**. Collisions per year: 2021: 101,087 · 2022: 106,004 · 2023: 104,258 · 2024: 100,927 · 2025: 101,525 (total 513,801). The 2025 figures may be provisional; check the DfT release notes before publishing findings.
- **Files received:** casualty (52.4 MB), collision (97.7 MB), vehicle (103.7 MB), and the data guide (Excel, 81 KB).
- **Why:**
  - One year is not enough to identify useful patterns. A change in one year could simply be a one-off.
  - Using every year since 1979 would make the project too large for a laptop, and the older data uses different codes.
  - Five years is a commonly used period for business reporting.
  - The combined files mean each table only needs to be loaded once rather than once for every year.
- **Alternatives considered:** A single year (too small), and loading each year separately (more work for no benefit here).

## D-004: Tools: SQL Server, Power BI and Excel
- **Decision:** Use Microsoft SQL Server, with SSMS, to store and prepare the data, Power BI to build dashboards, and Excel for validation checks.
- **Why:**
  - These Microsoft tools are widely used in UK organisations, particularly banks, insurers and public-sector organisations.
  - These tools are commonly mentioned in UK data analyst job adverts.
  - All three are already installed on my laptop.
- **Alternatives considered:** MySQL or PostgreSQL. Both are fine, but SQL Server pairs most naturally with Power BI.

## D-005: Folder structure
- **Decision:** Use separate folders for the datasets, documents, scripts, tests and Power BI files. The script folders are numbered by stage.
- **Why:**
  - Someone opening the project should be able to understand its structure very quickly.
  - The numbered script folders, such as `00_init` and `01_bronze`, show the order in which the steps should be run.
  - This is similar to how real data teams organise their work.

## D-006: Raw data is not uploaded to GitHub
- **Decision:** The CSV files will stay on my laptop. The README will explain where they can be downloaded from.
- **Why:**
  - GitHub blocks files larger than 100 MB and gives warnings above 50 MB. The vehicle file is 103.7 MB, so it cannot be uploaded to the repository.
  - The data is publicly available, so linking to the source is enough.
  - The repository should contain the code and documentation rather than large data files.

## D-007: Database name: `RoadSafetyDW`
- **Decision:** Use one SQL Server database called `RoadSafetyDW` for the whole data warehouse.
- **Why:**
  - "DW" means Data Warehouse, so the name makes the database's purpose clear.
  - Keeping all layers in one database makes the project easier to back up, share and explain.

## D-008: Database structure: bronze, silver and gold
- **Decision:** Split the database into three separate sections, called schemas.
  - `bronze`: the original data, loaded exactly as it arrives.
  - `silver`: cleaned data with the correct data types and readable labels.
  - `gold`: data arranged so it is ready for business reporting.
- **Why:**
  - **Traceability:** The original data is always kept, so a number shown in the dashboard can be traced back to the source.
  - **Safe re-runs:** If a cleaning rule turns out to be wrong, the silver data can be rebuilt from the bronze data without downloading the files again.
  - **Clear responsibility:** Each layer has a clear purpose, which makes problems easier to find.
  - It is a widely used industry pattern (popularised by Databricks), so employers recognise it.
- **Alternatives considered:**
  - One table per file with cleaning done directly in that table. Rejected because the original data would be lost after cleaning.
  - A separate database for each layer. Rejected because that would add unnecessary complexity for a project of this size.

## D-009: The actual CSV files are the source of truth, not the data guide
- **Finding (Step 6):** The column names in the CSV files do not completely match the data guide.
  - Collision: the CSV has 44 columns, but the guide lists 46 field names.
  - Some names differ, e.g. `enhanced_severity_collision` in the CSV vs `enhanced_collision_severity` in the guide, and `collision_adjusted_severity_serious` vs `collision_adjusted_serious`.
  - The guide also lists some fields under both old and new names (e.g. `..._scene_of_accident` / `..._scene_of_collision`).
  - The vehicle (32 columns) and casualty (23 columns) files match the guide's field counts, but the casualty adjusted-severity columns are also named differently.
- **Decision:** The bronze tables use the column names and order **exactly as they appear in the CSV files**. The guide is used to understand what the columns and codes mean.
- **Why:** SQL Server loads CSV files according to the **position of each column**. If the table were built from the guide instead, the number and order of columns could be wrong and the data could end up in the wrong places. The documentation can be behind the actual file, so the CSV file itself is treated as the source of truth.

## D-010: Store all bronze columns as text
- **Decision:** Every column in bronze is stored as text, regardless of what the value looks like.
- **Why:**
  - **Leading zeros:** `collision_ref_no` can be `010287661`. Stored as a number, it would become `10287661`, a different ID.
  - **UK date format:** `date` is `dd/mm/yyyy` (e.g. `15/02/2025`). Loading it straight into a date type risks failures or day and month being swapped.
  - **Mixed values:** some columns mix codes and text, e.g. `lsoa_of_casualty` can be `E01024657` or `-1`.
  - **The load must never fail or silently change a value.** Bronze is a faithful copy; converting types is silver's job, where each conversion can be checked.
- **Alternatives considered:** Correct types in bronze. Rejected because one unexpected value would make the whole load fail, or be converted wrongly without anyone noticing.

## D-011: `-1` means missing or unknown
- **Finding:** The data guide uses code `-1` for "Data missing or out of range" (and similar labels).
- **Decision:** Keep `-1` unchanged in bronze. Decide how it should be treated when creating silver.
- **Why:** Using `-1` in calculations would give the wrong result. For example, every `-1` would make the average driver age lower. It therefore needs to be handled deliberately.

## D-012: Table naming convention: `<layer>.<source>_<entity>`
- **Decision:** Name tables using the source system as a prefix, e.g. `bronze.dft_collision`, `bronze.dft_vehicle`, `bronze.dft_casualty`. All names use lowercase `snake_case`.
- **Why:**
  - The schema, such as `bronze`, shows which layer the table belongs to. The prefix, such as `dft` for Department for Transport, shows where the data came from. If another source is added later (e.g. ONS population data), there is no confusion.
  - Names match the CSV style (snake_case), so they are consistent and easy to read.
  - Singular names (`collision`, not `collisions`): each row represents one collision.

## D-013: Use `NVARCHAR(50)` for bronze text columns
- **Decision:** Every bronze column is `NVARCHAR(50)`, unless a longer value is expected.
- **Why:**
  - The values seen so far are short, such as codes, IDs, dates and coordinates. 50 characters gives them plenty of space.
  - If a value is longer than 50 characters, the load will fail rather than silently cutting the value off. The column can then be made wider deliberately.
  - Using one standard size keeps the script simple and easy to read.
- **Alternatives considered:**
  - `NVARCHAR(MAX)`. Rejected because it is slower and hides unexpected data.
  - Exact sizes per column. Rejected because true maximum lengths are unknown until the data is loaded.

## D-014: Load method: `BULK INSERT`, empty and reload each time
- **Decision:** Load each CSV file into its bronze table using SQL Server's `BULK INSERT`. Each run first empties the table using `TRUNCATE` and then loads the whole file.
- **Why:**
  - **`BULK INSERT`** is built into SQL Server and designed for loading large files fast. The files are about 50–100 MB each, which is far too big for manual imports.
  - **It is repeatable:** the load is a script, so anyone can re-run it and get the same result. The SSMS Import Wizard is click-based and cannot be version-controlled.
  - **Full load:** DfT republishes the complete 5-year files, and past records can be revised. Reloading everything is simpler and safer than trying to identify which individual rows have changed.
  - **Truncate first:** without it, running the load twice would duplicate every row.
- **Alternatives considered:**
  - SSMS Import Flat File wizard. Rejected: not repeatable, and it guesses data types.
  - Incremental loads (new rows only). Rejected: unnecessary for a static yearly file.

## D-015: The file uses LF line endings
- **Finding (Step 10):** In the first 2,000 bytes of the collision file there were 6 LF characters and 0 CR characters, so the file uses **Unix-style line endings (LF only)**.
- **Decision:** Use `ROWTERMINATOR = '0x0a'` in `BULK INSERT`.
- **Why:**
  - In SQL Server, `'\n'` is interpreted as CR+LF, which does not match this file.
  - `0x0a` is the hexadecimal code for LF.
  - Using the wrong line ending can either break the load or leave hidden characters at the end of every row.

## D-016: Use Git and GitHub to track changes
- **Decision:** The project folder is a Git repository and is pushed to a public GitHub repository. Changes are committed after each completed step.
- **Why:**
  - **History:** Every change, including updates to this log, is recorded, and an earlier version can be restored if needed.
  - **Proof of work:** A regular commit history shows that the project was built step by step rather than uploaded all at once.
  - **Portfolio:** GitHub gives recruiters and hiring managers a place to review the code.
- **What is excluded (`.gitignore`):** raw CSV files, because they are too large and publicly available, as explained in D-006, and personal preparation notes.
- **Where the project lives:** `C:\Projects\uk-road-collision-analytics` on the Windows drive, with Git for Windows.
  - All tools (SSMS, Power BI, Excel, Git) run on Windows, matching a typical UK corporate setup.
  - Running Git through the Parallels shared folder (`C:\Mac\Home\...`) was rejected: it causes permission, ownership and performance problems, and invites Git being run from both Mac and Windows on the same folder.
- **Note:** Git was set up after Step 12, so the first commit contains all work up to that point.

## D-017: How the bronze load is checked
- **Decision:** A load is only considered successful after separate checks have passed. These checks are saved in `tests/test_bronze_load.sql`:
  1. **Reconciliation:** file line count (PowerShell) − 1 header = table row count.
  2. **Year coverage:** every table covers 2021–2025.
  3. **Hidden characters:** no CR (`CHAR(13)`) in the last column of any table.
  4. **Visual check:** sample rows show values in the right columns.
  5. **Sanity check:** the ratios between tables are realistic.
- **Why:** The number of "rows affected" only tells us what SQL Server thinks it loaded. A load can finish without an error and still be wrong, for example because rows are missing or values have moved into the wrong columns. Each check catches a different kind of failure.
- **Results (Step 13):**

| Table | File lines | Rows loaded | Per collision |
|---|---|---|---|
| collision | 513,802 | 513,801 | 1 |
| vehicle | 937,266 | 937,265 | ≈ 1.82 |
| casualty | 652,822 | 652,821 | ≈ 1.27 |

  - All tables cover 2021–2025, and the per-year counts add up to the totals.
  - Hidden CR count: 0 in all three tables.
- **Status:** Bronze layer complete and verified.

## D-018: Profiling findings,  collision table (Step 14)
- **The level of the data was confirmed:** 513,801 rows, 513,801 distinct `collision_index` values. There is one row per collision, so `collision_index` can be used as the primary key in silver.
- **Critical columns:** no blanks in `collision_index`, `date`, `time` or `collision_severity`. 53 rows (0.01%) have no `longitude`/`latitude`.
- **Missing-value code counts (`-1`):** `junction_detail` 19,982 (3.9%); `road_surface_conditions` 3,527 (0.7%); `light_conditions` 34; `weather_conditions` 12; `urban_or_rural_area` 8; `speed_limit` 3; `road_type` 0.
- **Severity split:** Fatal 7,553 (1.5%), Serious 116,813 (22.7%), Slight 389,435 (75.8%).
- **Urban/rural:** Urban 345,314 (67.2%), Rural 168,429 (32.8%), Unallocated 50, missing 8.
- **Decisions that follow:**
  - There is not enough missing data to justify removing any column for this reason.
  - In silver, `-1` will become NULL in numeric fields. Where a field is used as a category, it will be shown as "Unknown", so missing information is visible instead of being treated as a genuine category.
  - The 53 rows without coordinates will be kept. They are still valid collision records, but they cannot be shown correctly on a map.
  - Because fatal collisions make up only 1.5% of the rows, the analysis will report **rates, meaning the percentage that are serious or fatal**, as well as counts. Counts alone would mostly reflect places where there is more traffic.

## D-019: Profiling findings,  vehicle and casualty tables (Step 15)
- **The level of the data was confirmed:** vehicle 937,265 rows = 937,265 distinct `collision_index` + `vehicle_reference`; casualty 652,821 rows = 652,821 distinct `collision_index` + `casualty_reference`. Both composite keys are unique.
- **Referential integrity:** 0 orphan vehicles and 0 orphan casualties. Every child row belongs to a collision that exists, so joins will not lose rows.
- **Vehicle missing values:**

| Column | Missing | Share |
|---|---|---|
| `age_of_vehicle` | 363,287 | 38.8% |
| `engine_capacity_cc` | 234,989 | 25.1% |
| `age_of_driver` | 142,240 | 15.2% |
| `sex_of_driver` (unknown or missing) | 122,370 | 13.1% |
| `vehicle_type` | 7,562 | 0.8% |

- **Casualty missing values:** `age_of_casualty` 14,106 (2.2%), `sex_of_casualty` unknown 6,304 (1.0%), `casualty_severity` and `casualty_class` complete.
- **Casualty severity:** Fatal 8,033, Serious 129,011, Slight 515,777.
- **Decisions that follow:**
  - `age_of_vehicle` and `engine_capacity_cc` are **not used as analysis categories**. With 25–39% missing, any apparent pattern could reflect which vehicles have information recorded rather than actual risk. They are kept in silver, flagged as unreliable.
  - Driver age and sex **are** used, but an explicit "Unknown" category is always included. Rates are calculated using known values, and the share that is unknown is also reported.
  - Casualty-level fields have enough complete information to be used directly.

## D-020: Rules for cleaning the silver layer
These rules apply to every silver table.
1. **Turn coded values into readable labels.** Coded columns are joined to `bronze.dft_code_list` on table + field + code, using `LEFT JOIN` so no row is ever lost. Verified on the collision table: the join left the row count unchanged at 513,801, so there is no fan-out.
2. **Use the correct data types.** Dates are stored as `DATE`, times as `TIME`, whole numbers as `INT`, and coordinates as `DECIMAL`. IDs remain as text, as decided in D-010.
3. **UK dates converted explicitly** with style 103 (`dd/mm/yyyy`), never left to SQL Server's default interpretation.
4. **`-1` becomes NULL** in numeric columns, and the label `'Unknown'` in descriptive columns, so missing data is visible rather than counted as a real value.
5. **Columns that are no longer needed are removed:** easting/northing (latitude and longitude carry the same location), `collision_ref_no` (contained within `collision_index`), and the `_historic` columns (superseded by the current code versions).
6. **Keys are enforced:** each silver table gets a primary key, so duplicates cannot enter unnoticed.
7. **Full rebuild:** silver is always truncated and rebuilt from bronze, so re-running gives the same result.

## D-021: Remove the `_historic` columns
- **Decision:** Silver keeps only the columns that use the current codes (`junction_detail`, `vehicle_manoeuvre`, `carriageway_hazards` and so on) and drops their `_historic` versions.
- **Why:**
  - DfT changed its code lists in 2024 and provided both the old and new versions during the changeover.
  - Keeping both versions could represent the same information twice using two different coding systems, which could cause double counting and confusion.
  - The current codes are the ones explained by the 2024 code list, so they can be translated consistently.
- **Alternative considered:** converting the old codes to new ones using the guide's conversion sheet and merging the two. Rejected: the current columns already contain data for all years, so converting the old codes would add work without adding information.
- **Trade-off to state openly:** If any current-code column had contained very little data in earlier years, this decision could have caused information to be lost. Profiling checked this and confirmed that the current columns are populated throughout.

## D-022: Keep "Not recorded" and "Unknown" separate
- **Problem found (Step 21):** after the first silver load, 14,578 collisions appeared to have unknown weather, even though profiling had found only 12 `-1` values. The reason was that DfT's own code `9` for `weather_conditions` is labelled "Unknown", while our transformation had also changed `-1` to the word "Unknown". Two different meanings had been treated as the same thing.
- **Decision:**
  - `-1` becomes **`Not recorded`**. This means no value was provided in the original data.
  - DfT's own `Unknown` and `unknown (self reported)` labels are kept exactly as published. This means the police recorded that the condition was unknown.
- **Why:** These represent two different situations. Reporting that "14,578 collisions have unknown weather" would make the amount of genuinely missing data look about 1,200 times larger than it actually is. Keeping them separate allows the report to show honestly how much information is actually missing and how much was recorded as unknown.
- **Verified:** after the fix, every "Not recorded" count matches the profiling figures exactly (junction 19,982; surface 3,527; light 34; weather 12; urban/rural 8; speed limit NULL 3), and weather now shows `Unknown` 14,566 and `Not recorded` 12 as separate categories.

## D-023: Check the silver collision table
- Row count matches bronze: 513,801.
- **The date conversion was checked and confirmed to be correct:** the weekday calculated from the converted date matches DfT's own `day_of_week` on every row (0 mismatches), which rules out accidentally reading the UK `dd/mm` dates as `mm/dd`.
- Date range 2021-01-01 to 2025-12-31, no missing times.
- Severity distribution identical to bronze.
- The values are within expected ranges: speed limits 20–70; latitude 49.91–60.50; longitude −7.49 to 1.76 (Isles of Scilly to Shetland, i.e. within Great Britain).
- **Method note:** an index was added to `bronze.dft_code_list (table_name, field_name, code)` because the load looks up this table 18 times.

## D-024: Silver layer complete and rebuilt by a stored procedure
- **Tables:** `silver.collision` (513,801), `silver.vehicle` (937,265), `silver.casualty` (652,821). Each has a primary key and matches its bronze source row for row.
- **Decision:** the whole silver layer is rebuilt by one stored procedure, `silver.load_silver`, rather than by running scripts by hand.
- **Why:**
  - One command rebuilds everything in the correct order, reducing the risk of stopping halfway through or running steps in the wrong order.
  - It shows progress and how long each table takes (collision 23s, vehicle 29s, casualty 17s; 69s in total), which makes slow steps visible.
  - `TRY...CATCH` reports which statement failed and why, rather than showing only a raw error message.
  - It is stored in the database, so it can be scheduled later, for example using SQL Server Agent, without changing the process.
- **Alternative considered:** keeping the plain `load_silver.sql` script. Rejected, and the file was deleted, because two copies of the same logic could gradually become different. The procedure is now the single source of truth, saved as `scripts/02_silver/proc_load_silver.sql`.

## D-025: Gold layer: reporting model built as views
- **Structure:** `gold.dim_date` (a real table, 1,826 days covering 2021–2025) plus three views: `gold.fact_collision` (513,801), `gold.fact_casualty` (652,821) and `gold.fact_vehicle` (937,265). Row counts verified unchanged, so the joins introduce no duplication.
- **Why a star schema:** one central table of events surrounded by small tables of labels is the shape Power BI is built for. It keeps the model simple to explain and quick to filter.
- **Why views rather than tables:** a view holds no data of its own and always reflects current silver, so there is nothing extra to reload or keep in step. The amount of data here is small enough that performance is not a concern. At a much larger scale, stored tables could be more appropriate.
- **Why a separate date table:** it supplies month names, quarters and weekend flags, keeps months in calendar order rather than alphabetical, and includes days on which nothing happened,  which a date column derived from the data alone cannot do.
- **Why 1/0 flag columns (`is_fatal`, `is_serious_or_fatal`):** summing them counts severe collisions and averaging them gives the **rate**. Rates are more useful for the insurer's question because raw counts are strongly affected by how much traffic there is, as explained in D-018.
- **Why `INNER JOIN` in the fact views** when silver used `LEFT JOIN`: profiling proved there are no orphan vehicles or casualties (D-019), so nothing can be lost. The joins in silver were different because they used a lookup table where a matching code was not guaranteed.
- **Denormalisation note:** collision context (road type, weather, speed limit) is repeated inside the casualty and vehicle views. This repeats some information deliberately so those tables can be filtered without needing more joins. This is normal for a reporting layer, even though it would not normally be done in the same way in a transactional database.

## D-026: The rise in severity is caused by a recording-method change, not a confirmed road-safety change
- **What the first results appeared to show:** the serious-or-fatal rate rose each year, from 22.51% in 2021 to 26.24% in 2025. That is a 17% relative increase, while the number of collisions stayed broadly flat.
- **Why this was investigated:** fatal collisions stayed broadly flat, from 1,474 to 1,453, representing 1.43–1.51% of collisions. Fatal outcomes are less affected by changes in how injuries are classified. Therefore, the stable fatal rate was an important reason to investigate whether the apparent rise was caused by recording methods instead of a real change in road safety.
- **What the data showed:** The data showed that police forces have been moving from severity based on an officer's judgement towards injury-based recording, using CRASH-style systems. Injury-based recording classifies more injuries as serious.

| Year | Injury-based share | Injury-based rate | Officer-judgement rate |
|---|---|---|---|
| 2021 | 50% | 26.50% | 18.59% |
| 2023 | 54% | 28.04% | 19.18% |
| 2025 | **87%** | 27.00% | 21.38% |

- **The figures support this explanation:** (0.50 × 26.5) + (0.50 × 18.6) = 22.5% for 2021, and (0.87 × 27.0) + (0.13 × 21.4) = 26.2% for 2025,  matching the observed rates. The rate within each recording method is fairly stable. What changed was the proportion of records using each method.
- **Decisions that follow:**
  1. **Do not report the overall serious-or-fatal rate as a trend over time.** If a time trend is needed, use the **fatal** rate, which is not affected by this particular recording-method change.
  2. **All other comparisons pool 2021–2025**, so the method mix applies roughly equally across categories.
  3. Explain this limitation clearly in both the README and the dashboard.
- **Why it matters:** the naive reading,  "UK roads became 17% more dangerous since 2021",  would have been wrong, and is the sort of claim a portfolio project publishes without checking.

---
*Upcoming decisions will be added as the project reaches them, including database design, data loading, cleaning rules, the data model and dashboard design.*
