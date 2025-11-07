# Layered Recommender System for Berlin Districts

## Project Overview

This project showcases a **real-world, multi-layered recommender system** developed during my internship at **[webeet.io](https://www.webeet.io/)**.

The system is designed to translate any natural language query (e.g., "a safe area with good transport") into a personalized, ranked list of suitable districts.

My responsibility was to design and build the **fundamental data platform and analytical engine** that makes this translation possible. I engineered the four core components that power the recommender:
1.  **ETL Pipelines** to source and process raw data.
2.  An **Optimized Database Schema** to aggregate analytical features.
3.  The **Core Tag Taxonomy**, which serves as the central "dictionary" for the entire system.
4.  A **Data-Driven Tagging Logic** to objectively score and label each district (e.g., assigning `#public_transport_hub` or `#low_crime_rate`).

This taxonomy is the key: it allows the recommender engine (developed by another team) to map a user's abstract query ("safe") to my concrete, data-driven tags (`#low_crime_rate`). It also allows the front-end to display my tag descriptions as tooltips, making the logic transparent to the end-user.

This repository serves as a portfolio piece, showcasing the data engineering pipelines, database architecture, and core analytical logic I developed.

---
## Technologies Used

* **Languages**: Python, SQL (PostgreSQL)
* **Libraries**: Pandas, GeoPandas, SQLAlchemy, NumPy
* **Database**: PostgreSQL with PostGIS extension
* **Development Environment**: Jupyter Notebook

---
## My Key Contributions

My work focused on four foundational components of the analytical engine. I was responsible for:

* **End-to-End ETL Pipelines:** Engineering complete ETL pipelines for diverse data sources (JSON APIs, OpenStreetMap).
* **Database Schema Design:** Designing and implementing the core analytical tables (`attributes`, `features`, `labels`) to optimize query performance.
* **Core Tag Taxonomy:** Developing the central "dictionary" for the recommender, defining the logic, data sources, and user-facing descriptions for every tag.
* **Analytical Tagging Logic:** Authoring and automating the complex models (hierarchical, composite) that score districts and assign the final tags.

---

### 1. Data Engineering: ETL Pipelines & Feature Engineering

#### 1.1 End-to-End ETL Pipeline (Post Offices)

I designed and implemented a complete ETL (Extract, Transform, Load) pipeline to process Berlin post office data, sourced from a JSON API response captured from the official `Deutsche Post` website. The process involved:
* Extracting and cleaning the complex, nested raw JSON data (e.g., parsing opening hours).
* Enriching it with geospatial information (district and neighborhood IDs) using **GeoPandas**.
* Loading the final, structured data into a PostgreSQL database, ensuring data integrity with foreign keys.

➡️ **For a detailed breakdown of this pipeline, see the [Post Offices README](post_offices/README.md).**

#### 1.2 Open Data ETL Pipeline (Nightclubs)

Developed an ETL pipeline to source, clean, and load Berlin nightclub data from OpenStreetMap (OSM). The process included:
* Extracting raw data using the **Overpass API** and performing initial cleaning (flattening JSON, merging columns).
* Enriching the data with geocoding (using **geopy**) and performing a spatial join (**GeoPandas**) to add `district_id` and `neighborhood_id`.
* Loading the structured data into PostgreSQL using the high-performance `copy_expert` method and adding foreign key constraints.

➡️ **For a detailed breakdown of this pipeline, see the [Nightclubs README](night_clubs/README.md).**

#### 1.3 Advanced ETL & Feature Engineering (Doctors & Clinics)

Engineered a complex ETL and feature engineering pipeline for Berlin healthcare facilities (doctors and clinics) from OSM. This pipeline involved:
* Performing advanced cleaning on raw Overpass JSON, including **manual data salvaging** (e.g., from websites), smart deduplication (aggregating specialities), and a 3-tier re-categorization of facilities.
* Developing a **feature engineering** model to assign a weighted `capacity_score` to facilities and aggregate total healthcare density scores (e.g., `total_primary_adult_score`) for each district.
* Executing a two-part load:
    * **Bulk-inserting cleaned records into `berlin_source_data.doctors`.**
    * **Integrating the aggregated feature scores into the `berlin_labels.district_features` table using `UPDATE...FROM`.**

➡️ **For a detailed breakdown of this pipeline, see the [Doctors README](doctors/README.md).**

### 2. Database Schema Design & Optimization

To improve performance and streamline the analysis, our team decided to implement a new database schema for analytical data. I was responsible for designing and implementing the key tables for this schema:
* **`district_attributes`**: A performance-optimization table that stores pre-calculated, static district metrics such as `area_sq_km`, `area_coefficient`, `inhabitants`, and `population_coefficient`. These metrics are computed directly in the database by a dedicated SQL script using PostGIS to eliminate the need for repeated, expensive calculations in downstream analytical scripts.
* **`district_features`**: A centralized, aggregated "feature table" that contains pre-counted totals for various amenities (e.g., `bank_count`, `bus_tram_stop_count`), created with a single, efficient SQL script.
* **`district_labels_new`**: The final output table, structured in a "long" format (`district_id`, `category`, `label`) to store all generated tags in a clean and scalable way.

This architectural approach moved heavy data processing from Python into the database, making the final analytical scripts significantly faster and easier to maintain.

➡️ **The SQL scripts I developed for creating these tables, along with a detailed README explaining each script, can beG found in the [`database_scripts/`](database_scripts/) directory.**

### 3. Tag Taxonomy Design

A comprehensive tag taxonomy was designed and developed for this project, creating a structured classification system with five key categories: `Economy & Real Estate`, `Community & Lifestyle`, `Green & Environment`, `Mobility`, and `Amenities & Services`.

The focus of the design was to ensure each tag is **objective, data-driven, and transparent**, clearly reflecting the metric used for its calculation. The system includes simple, direct metrics as well as more complex **hierarchical and composite tags** (e.g., `#commercial_hotspot`, `#public_transport_hub`) to provide a nuanced district profile.

➡️ **The complete list of all tags within each category, along with their detailed descriptions, data sources, and calculation logic, can be found in the [Tag Taxonomy Document](common_labels/README.md).**


### 4. Data-Driven Tagging Logic

I developed the core analytical methodology for assigning objective, data-driven tags to each district. My approach was focused on creating a robust, transparent, and scalable system that fairly compares diverse areas. The key pillars of this methodology are:

* **Strategic Normalization:** To ensure fair comparisons, thresholds were dynamically scaled using two different metrics:
    * **Area Coefficient:** Used for infrastructure density (e.g., transport hubs, nightlife venues).
    * **Population Coefficient:** Used for population-dependant services (e.g., healthcare practices, pharmacies, dentists) and per-capita rates (crime).

* **Multi-Layered Tagging Models:** Instead of simple one-to-one rules, I designed and implemented complex logic based on hierarchies and composite scoring:
    * **Hierarchical Tagging:** Implemented a priority system to assign the *single most descriptive* tag and avoid redundancy. For example, a district only receives the `#public_transport_hub` tag if it qualifies as a hub for **all three** transport types (S-Bahn, U-Bahn, and Bus/Tram), superseding the individual tags.
    * **Composite Tags & Scoring:** Created high-level "summary" tags from multiple underlying criteria. The strongest example is the `#full_spectrum_healthcare` tag, which is only assigned if a district meets 5 distinct criteria (for primary care, specialists, pharmacies, dentists, and hospitals). This model also includes a **hierarchical cleanup**, suppressing the base-level tags (like `#many_pharmacies`) if the top-tier tag is assigned.

* **Automation and Efficiency:** The entire tagging process—from reading pre-aggregated features to applying normalization, hierarchical logic, and cleanup—was automated using a series of dedicated Python scripts (e.g., `script_healthcare.ipynb`, `script_transport_full.ipynb`). These scripts efficiently load the final tags into the central `berlin_labels.district_labels_new` table.

➡️ **A detailed, step-by-step breakdown of the implemented logic for each category is available in the [Labels README](labels/README.md).**



---
## Project Status

This repository serves as a portfolio piece. Please note that direct access to the production database is not provided; a the focus is on demonstrating the methodology and code.
