# Decisions Log: UK Road Collision Risk Analytics

This file records every important decision in the project: **what** was decided, **why**, and **what else was considered**.
It is updated as the project progresses.

---

## D-001: Project topic: UK road collision risk
- **Decision:** Analyse UK road collisions from the perspective of a motor insurer's pricing team (fictional company: Northgate Motor Insurance).
- **Why:**
  - Road collisions are exactly the kind of risk that motor insurers price. The business question is realistic: which conditions make a collision more likely to be serious?
  - It connects to my current work in motor insurance, so I understand the business context.
  - Most beginner portfolios use the same few Kaggle datasets (Superstore, Titanic and similar). A real UK government dataset stands out to UK employers.
- **Alternatives considered:** UK house prices (Land Registry), NHS waiting times, and online retail sales. The online retail data is kept for Project 2.

## D-002: Data source: Department for Transport STATS19 data (GOV.UK)
- **Decision:** Use the official "Road Safety Data" published by the Department for Transport.
- **Why:**
  - It is official, trusted data collected by the police on the STATS19 form.
  - It is free and openly published.
  - It is realistic: the data is split across related tables and stored as codes that need lookups, which is how data looks inside real companies.
  - It is documented: DfT provides a data guide explaining every column and code.
- **Alternatives considered:** Pre-cleaned copies of the data on Kaggle. These were rejected because cleaning the data myself is part of what the project demonstrates.

## D-003: Scope: the "last 5 years" files
- **Decision:** Use the combined last-5-years files for collisions, vehicles and casualties. Year range: **2021–2025, confirmed with SQL (Step 12)**. Collisions per year: 2021: 101,087 · 2022: 106,004 · 2023: 104,258 · 2024: 100,927 · 2025: 101,525 (total 513,801). The 2025 figures may be provisional; check the DfT release notes before publishing findings.
- **Files received:** casualty (52.4 MB), collision (97.7 MB), vehicle (103.7 MB), and the data guide (Excel, 81 KB).
- **Why:**
  - One year is too little to spot trends. For example, is a change real, or just a one-off?
  - All years since 1979 would be too large for a laptop project, and older years use different codes.
  - Five years is a common window for business reporting.
  - The combined file means one load per table instead of five.
- **Alternatives considered:** A single year (too small), and loading each year separately (more work for no benefit here).

## D-004: Tools: SQL Server, Power BI and Excel
- **Decision:** Microsoft SQL Server (with SSMS) for storage and transformation, Power BI for dashboards, and Excel for validation checks.
- **Why:**
  - This is the Microsoft stack, which is very common in UK companies, especially banks, insurers and the public sector.
  - These tools appear in most UK data analyst job adverts.
  - All three are already installed on my laptop.
- **Alternatives considered:** MySQL or PostgreSQL. Both are fine, but SQL Server pairs most naturally with Power BI.

## D-005: Folder structure
- **Decision:** Separate folders for datasets, docs, scripts (numbered by stage), tests and Power BI.
- **Why:**
  - Anyone opening the project can understand it in seconds.
  - The numbered script folders (`00_init`, `01_bronze` and so on) show the order to run things in.
  - It mirrors how real data teams organise work.

## D-006: Raw data is not uploaded to GitHub
- **Decision:** The CSV files stay on my laptop only. The README will explain where to download them.
- **Why:**
  - GitHub blocks files over 100 MB and warns above 50 MB. The vehicle file is 103.7 MB, so GitHub would reject it outright.
  - The data is publicly available, so linking to the source is enough.
  - A repo should hold code and documentation, not large data files.

## D-007: Database name: `RoadSafetyDW`
- **Decision:** One SQL Server database called `RoadSafetyDW` holds the whole warehouse.
- **Why:**
  - "DW" means Data Warehouse, so the name states the purpose.
  - A single database keeps all layers together, which makes it easy to back up, share and explain.

## D-008: Architecture: Medallion (bronze, silver, gold schemas)
- **Decision:** Split the database into three schemas.
  - `bronze`: raw data, loaded exactly as it arrives.
  - `silver`: cleaned, typed and decoded data.
  - `gold`: a business-ready model for reporting.
- **Why:**
  - **Traceability:** raw data is always kept, so any number in the dashboard can be traced back to the source.
  - **Safe re-runs:** if a cleaning rule is wrong, silver is rebuilt from bronze without downloading anything again.
  - **Clear responsibility:** each layer has one job, which makes problems easy to locate.
  - It is a widely used industry pattern (popularised by Databricks), so employers recognise it.
- **Alternatives considered:**
  - One table per file with cleaning done in place. Rejected because raw data would be lost after cleaning.
  - Separate databases per layer. Rejected as unnecessary complexity for a project this size.

## D-009: The actual CSV files are the source of truth, not the data guide
- **Finding (Step 6):** The CSV headers do not fully match the data guide.
  - Collision: the CSV has 44 columns, but the guide lists 46 field names.
  - Some names differ, e.g. `enhanced_severity_collision` in the CSV vs `enhanced_collision_severity` in the guide, and `collision_adjusted_severity_serious` vs `collision_adjusted_serious`.
  - The guide also lists some fields under both old and new names (e.g. `..._scene_of_accident` / `..._scene_of_collision`).
  - The vehicle (32 columns) and casualty (23 columns) files match the guide's field counts, but the casualty adjusted-severity columns are also named differently.
- **Decision:** Bronze tables use the column names and order **exactly as they appear in the CSV headers**. The guide is used only to understand meanings and codes.
- **Why:** SQL Server loads CSVs by column **position**. A table built from the guide would have the wrong column count and misaligned data. Documentation can lag behind the data; the file is what actually gets loaded.

## D-010: All bronze columns are stored as text (NVARCHAR)
- **Decision:** Every bronze column uses a text data type, whatever the value looks like.
- **Why:**
  - **Leading zeros:** `collision_ref_no` can be `010287661`. Stored as a number, it would become `10287661`, a different ID.
  - **UK date format:** `date` is `dd/mm/yyyy` (e.g. `15/02/2025`). Loading it straight into a date type risks failures or day and month being swapped.
  - **Mixed values:** some columns mix codes and text, e.g. `lsoa_of_casualty` can be `E01024657` or `-1`.
  - **The load must never fail or silently change a value.** Bronze is a faithful copy; converting types is silver's job, where each conversion can be checked.
- **Alternatives considered:** Correct types in bronze. Rejected because one unexpected value would make the whole load fail, or be converted wrongly without anyone noticing.

## D-011: `-1` means missing or unknown
- **Finding:** The data guide uses code `-1` for "Data missing or out of range" (and similar labels).
- **Decision:** Keep `-1` as-is in bronze. Decide how to handle it in silver.
- **Why:** In calculations, `-1` would be wrong: an average driver age would be pulled down by every `-1`. It must be handled deliberately, not by accident.

## D-012: Table naming convention: `<layer>.<source>_<entity>`
- **Decision:** Tables are named with the source system as a prefix, e.g. `bronze.dft_collision`, `bronze.dft_vehicle`, `bronze.dft_casualty`. All names are lowercase snake_case.
- **Why:**
  - The schema (`bronze`) shows the layer and the prefix (`dft` = Department for Transport) shows where the data came from. If another source is added later (e.g. ONS population data), there is no confusion.
  - Names match the CSV style (snake_case), so they are consistent and easy to read.
  - Singular names (`collision`, not `collisions`): one row = one collision.

## D-013: Bronze text columns use `NVARCHAR(50)`
- **Decision:** Every bronze column is `NVARCHAR(50)`, except where a longer value is expected.
- **Why:**
  - All values seen so far are short (codes, IDs, dates, coordinates). 50 characters leaves plenty of room.
  - If a value is ever longer, the load **fails loudly** instead of silently cutting the value short, and we then widen that column on purpose.
  - Using one standard size keeps the script simple and readable.
- **Alternatives considered:**
  - `NVARCHAR(MAX)`. Rejected because it is slower and hides unexpected data.
  - Exact sizes per column. Rejected because true maximum lengths are unknown until the data is loaded.

## D-014: Load method: `BULK INSERT`, full load (truncate and reload)
- **Decision:** Load each CSV into its bronze table with SQL Server's `BULK INSERT`. Each run first empties the table (`TRUNCATE`) and then loads the whole file.
- **Why:**
  - **`BULK INSERT`** is built into SQL Server and designed for loading large files fast. The files are about 50–100 MB each, which is far too big for manual imports.
  - **It is repeatable:** the load is a script, so anyone can re-run it and get the same result. The SSMS Import Wizard is click-based and cannot be version-controlled.
  - **Full load:** DfT republishes the complete 5-year files, and past records can be revised. Reloading everything is simpler and safer than working out which rows changed.
  - **Truncate first:** without it, running the load twice would duplicate every row.
- **Alternatives considered:**
  - SSMS Import Flat File wizard. Rejected: not repeatable, and it guesses data types.
  - Incremental loads (new rows only). Rejected: unnecessary for a static yearly file.

## D-015: Row terminator is LF (`0x0a`)
- **Finding (Step 10):** In the first 2,000 bytes of the collision file there were 6 LF characters and 0 CR characters, so the file uses **Unix-style line endings (LF only)**.
- **Decision:** `BULK INSERT` uses `ROWTERMINATOR = '0x0a'`.
- **Why:**
  - In SQL Server, `'\n'` is interpreted as CR+LF, which does not match this file.
  - `0x0a` is the exact hexadecimal code for LF.
  - A wrong terminator either breaks the load or leaves hidden characters in the last column of every row.

## D-016: Version control with Git and GitHub
- **Decision:** The project folder is a Git repository, pushed to a public GitHub repo. Changes are committed after each completed step.
- **Why:**
  - **History:** every change (including updates to this log) is recorded, and any past version can be restored.
  - **Proof of work:** a steady commit history shows the project was built step by step, not uploaded in one go.
  - **Portfolio:** GitHub is where recruiters and hiring managers look at code.
- **What is excluded (`.gitignore`):** raw CSV files (too large, and publicly available, see D-006) and personal prep notes.
- **Where the project lives:** `C:\Projects\uk-road-collision-analytics` on the Windows drive, with Git for Windows.
  - All tools (SSMS, Power BI, Excel, Git) run on Windows, matching a typical UK corporate setup.
  - Running Git through the Parallels shared folder (`C:\Mac\Home\...`) was rejected: it causes permission, ownership and performance problems, and invites Git being run from both Mac and Windows on the same folder.
- **Note:** Git was set up after Step 12, so the first commit contains all work up to that point.

## D-017: How the bronze load is verified
- **Decision:** A load only counts as successful after independent checks, saved in `tests/test_bronze_load.sql`:
  1. **Reconciliation:** file line count (PowerShell) − 1 header = table row count.
  2. **Year coverage:** every table covers 2021–2025.
  3. **Hidden characters:** no CR (`CHAR(13)`) in the last column of any table.
  4. **Visual check:** sample rows show values in the right columns.
  5. **Sanity check:** the ratios between tables are realistic.
- **Why:** "rows affected" is SQL Server reporting on itself. A load can finish without errors and still be wrong (rows missing, values shifted or corrupted). Each check catches a different kind of failure.
- **Results (Step 13):**

| Table | File lines | Rows loaded | Per collision |
|---|---|---|---|
| collision | 513,802 | 513,801 | 1 |
| vehicle | 937,266 | 937,265 | ≈ 1.82 |
| casualty | 652,822 | 652,821 | ≈ 1.27 |

  - All tables cover 2021–2025, and the per-year counts add up to the totals.
  - Hidden CR count: 0 in all three tables.
- **Status:** Bronze layer complete and verified.

## D-018: Profiling findings — collision table (Step 14)
- **Grain confirmed:** 513,801 rows, 513,801 distinct `collision_index` values. One row per collision, and `collision_index` can be the primary key in silver.
- **Critical columns:** no blanks in `collision_index`, `date`, `time` or `collision_severity`. 53 rows (0.01%) have no `longitude`/`latitude`.
- **Missing codes (`-1`):** `junction_detail` 19,982 (3.9%); `road_surface_conditions` 3,527 (0.7%); `light_conditions` 34; `weather_conditions` 12; `urban_or_rural_area` 8; `speed_limit` 3; `road_type` 0.
- **Severity split:** Fatal 7,553 (1.5%), Serious 116,813 (22.7%), Slight 389,435 (75.8%).
- **Urban/rural:** Urban 345,314 (67.2%), Rural 168,429 (32.8%), Unallocated 50, missing 8.
- **Decisions that follow:**
  - Missing data is low enough that no column needs to be dropped for incompleteness.
  - `-1` will become NULL in silver, with the label "Unknown" where a column is used as a dimension, so missing data is visible instead of silently counted as a real category.
  - The 53 rows without coordinates are kept: they are valid collisions and only affect map visuals.
  - Because fatal collisions are only 1.5% of rows, analysis will report **rates (percentage serious or fatal)** as well as counts, since raw counts would simply follow wherever traffic is heaviest.

## D-019: Profiling findings — vehicle and casualty tables (Step 15)
- **Grain confirmed:** vehicle 937,265 rows = 937,265 distinct `collision_index` + `vehicle_reference`; casualty 652,821 rows = 652,821 distinct `collision_index` + `casualty_reference`. Both composite keys are unique.
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
  - `age_of_vehicle` and `engine_capacity_cc` are **not used as analysis dimensions**: with 25–39% missing, any pattern would say more about which vehicles get matched to records than about risk. They are kept in silver, flagged as unreliable.
  - Driver age and sex **are** used, but always with an explicit "Unknown" category, and rates are calculated on known values with the unknown share stated.
  - Casualty-level fields are reliable enough to use directly.

## D-020: Silver layer rules
Applied to every silver table.
1. **Decode codes into labels.** Coded columns are joined to `bronze.dft_code_list` on table + field + code, using `LEFT JOIN` so no row is ever lost. Verified on the collision table: the join left the row count unchanged at 513,801, so there is no fan-out.
2. **Proper data types.** Dates become `DATE`, times `TIME`, whole numbers `INT`, coordinates `DECIMAL`. IDs stay text (D-010).
3. **UK dates converted explicitly** with style 103 (`dd/mm/yyyy`), never left to SQL Server's default interpretation.
4. **`-1` becomes NULL** in numeric columns, and the label `'Unknown'` in descriptive columns, so missing data is visible rather than counted as a real value.
5. **Redundant columns are dropped:** easting/northing (latitude and longitude carry the same location), `collision_ref_no` (contained within `collision_index`), and the `_historic` columns (superseded by the current code versions).
6. **Keys are enforced:** each silver table gets a primary key, so duplicates cannot enter unnoticed.
7. **Full rebuild:** silver is always truncated and rebuilt from bronze, so re-running gives the same result.

## D-021: The `_historic` columns are dropped
- **Decision:** Silver keeps only the current-code columns (`junction_detail`, `vehicle_manoeuvre`, `carriageway_hazards` and so on) and drops their `_historic` versions.
- **Why:**
  - DfT changed the code lists in 2024 and provides both versions during the transition.
  - Keeping both would mean the same fact appears twice in two coding systems, which invites double counting and confusion.
  - The current codes are the ones the 2024 code list decodes, so they translate cleanly.
- **Alternative considered:** converting the old codes to new ones using the guide's conversion sheet and merging the two. Rejected: the current columns are already populated for all years, so the conversion adds work without adding data.
- **Trade-off to state openly:** if any current-code column turned out to be sparsely populated in earlier years, this choice would cost data. Checked during profiling and confirmed as populated throughout.

## D-022: "Not recorded" and "Unknown" are kept apart
- **Problem found (Step 21):** after the first silver load, 14,578 collisions showed unknown weather, but profiling had found only 12 `-1` values. The cause: DfT's own code `9` for `weather_conditions` is labelled "Unknown", and our transformation had turned `-1` into the same word. Two different meanings were collapsing into one.
- **Decision:**
  - `-1` becomes **`Not recorded`** — no value ever reached the dataset.
  - DfT's own `Unknown` (and `unknown (self reported)`) labels are left exactly as published — the police recorded that the condition was unknown.
- **Why:** they are different facts. Reporting "14,578 collisions have unknown weather" would overstate missing data by a factor of 1,200. Keeping them separate lets the report state honestly how much information is absent versus recorded as unknown.
- **Verified:** after the fix, every "Not recorded" count matches the profiling figures exactly (junction 19,982; surface 3,527; light 34; weather 12; urban/rural 8; speed limit NULL 3), and weather now shows `Unknown` 14,566 and `Not recorded` 12 as separate categories.

## D-023: Silver collision table verified (Step 21)
- Row count matches bronze: 513,801.
- **Date conversion proven correct:** the weekday calculated from the converted date matches DfT's own `day_of_week` on every row (0 mismatches), which rules out the dd/mm vs mm/dd error.
- Date range 2021-01-01 to 2025-12-31, no missing times.
- Severity distribution identical to bronze.
- Values plausible: speed limits 20–70; latitude 49.91–60.50; longitude −7.49 to 1.76 (Isles of Scilly to Shetland, i.e. within Great Britain).
- **Method note:** an index on `bronze.dft_code_list (table_name, field_name, code)` was added because the load joins that table 18 times.

## D-024: Silver layer complete, rebuilt by a stored procedure
- **Tables:** `silver.collision` (513,801), `silver.vehicle` (937,265), `silver.casualty` (652,821). Each has a primary key and matches its bronze source row for row.
- **Decision:** the whole silver layer is rebuilt by one stored procedure, `silver.load_silver`, rather than by running scripts by hand.
- **Why:**
  - One command rebuilds everything in the right order, so the process cannot be run half-finished or out of sequence.
  - It prints progress and per-table timings (collision 23s, vehicle 29s, casualty 17s; 69s in total), which makes slow steps visible.
  - `TRY...CATCH` reports which statement failed and why, instead of dumping a raw error.
  - It lives in the database, so it can be scheduled later (e.g. by SQL Server Agent) with no changes.
- **Alternative considered:** keeping the plain `load_silver.sql` script. Rejected, and the file was deleted, because two copies of the same logic would drift apart. The procedure is now the single source of truth, saved as `scripts/02_silver/proc_load_silver.sql`.

## D-025: Gold layer — star schema built as views
- **Structure:** `gold.dim_date` (a real table, 1,826 days covering 2021–2025) plus three views: `gold.fact_collision` (513,801), `gold.fact_casualty` (652,821) and `gold.fact_vehicle` (937,265). Row counts verified unchanged, so the joins introduce no duplication.
- **Why a star schema:** one central table of events surrounded by small tables of labels is the shape Power BI is built for. It keeps the model simple to explain and quick to filter.
- **Why views rather than tables:** a view holds no data of its own and always reflects current silver, so there is nothing extra to reload or keep in step. Data volumes here are small enough that performance is not a concern; materialised tables would be the answer at much larger scale.
- **Why a separate date table:** it supplies month names, quarters and weekend flags, keeps months in calendar order rather than alphabetical, and includes days on which nothing happened — which a date column derived from the data alone cannot do.
- **Why 1/0 flag columns (`is_fatal`, `is_serious_or_fatal`):** summing them counts severe collisions and averaging them gives the **rate**. Rates, not counts, answer the insurer's question, because counts mostly follow traffic volume (D-018).
- **Why `INNER JOIN` in the fact views** when silver used `LEFT JOIN`: profiling proved there are no orphan vehicles or casualties (D-019), so nothing can be lost. The silver joins were against a lookup table where a match was not guaranteed.
- **Denormalisation note:** collision context (road type, weather, speed limit) is repeated inside the casualty and vehicle views. This duplicates data on purpose so those tables can be sliced without further joins — standard practice in a reporting layer, unlike in a transactional database.

---
*Upcoming decisions (to be added when we reach them): database design, data loading method, cleaning rules, data model, dashboard design.*
