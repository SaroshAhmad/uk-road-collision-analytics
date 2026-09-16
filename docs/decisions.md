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

---
*Upcoming decisions (to be added when we reach them): database design, data loading method, cleaning rules, data model, dashboard design.*
