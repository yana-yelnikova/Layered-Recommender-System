# Layered Recommender System for Berlin Districts

## Project Overview

This project showcases a **real-world, multi-layered recommender system** developed during my internship at **[webeet.io](https://www.webeet.io/)**.

This project is an AI-driven recommender system designed to simplify the complex process of choosing a district to live in Berlin. By leveraging a multi-layered analytical approach, the system translates any user query—from "quiet and family-friendly" to "vibrant nightlife and good transport"—into a personalized, ranked list of suitable districts.

This repository serves as a portfolio piece, showcasing the data engineering pipelines and core analytical logic that I was responsible for developing.

---
## My Key Contributions

My work focused on four foundational parts of the project: building data pipelines, designing the analytical database schema, creating the tag taxonomy, and developing the tagging logic.

### 1. End-to-End ETL Pipeline Development

I designed and implemented a complete ETL (Extract, Transform, Load) pipeline for processing Berlin post office data. The process involved:
* Extracting and cleaning raw JSON data.
* Enriching it with geospatial information (district and neighborhood IDs) using **GeoPandas**.
* Loading the final, structured data into a PostgreSQL database, ensuring data integrity with foreign keys.

➡️ **For a detailed breakdown of this pipeline, see the [Post Offices README](post_offices/README.md).**

### 2. Database Schema Design & Optimization

To improve performance and streamline the analysis, our team decided to implement a new database schema for analytical data. I was responsible for designing and implementing the key tables for this schema:
* **`district_attributes`**: A performance-optimization table that stores pre-calculated, static district metrics such as `area_sq_km`, `area_coefficient`, `inhabitants`, and `population_coefficient`. These metrics are computed directly in the database by a dedicated SQL script using PostGIS to eliminate the need for repeated, expensive calculations in downstream analytical scripts.
* **`district_features`**: A centralized, aggregated "feature table" that contains pre-counted totals for various amenities (e.g., `bank_count`, `bus_tram_stop_count`), created with a single, efficient SQL script.
* **`district_labels_new`**: The final output table, structured in a "long" format (`district_id`, `category`, `label`) to store all generated tags in a clean and scalable way.

This architectural approach moved heavy data processing from Python into the database, making the final analytical scripts significantly faster and easier to maintain.

➡️ **The SQL scripts I developed for creating these tables, along with a detailed README explaining each script, can be found in the [`database_scripts/`](database_scripts/) directory.**

### 3. Tag Taxonomy Design

A comprehensive tag taxonomy was designed and developed for this project, creating a structured classification system with five key categories: `Economy & Real Estate`, `Community & Lifestyle`, `Green & Environment`, `Mobility`, and `Amenities & Services`.

The focus of the design was to ensure each tag is **objective, data-driven, and transparent**, clearly reflecting the metric used for its calculation. The system includes simple, direct metrics as well as more complex **hierarchical and composite tags** (e.g., `#commercial_hotspot`, `#public_transport_hub`) to provide a nuanced district profile.

➡️ **The complete list of all tags within each category, along with their detailed descriptions, data sources, and calculation logic, can be found in the [Tag Taxonomy Document](common_labels/README.md).**

### 4. Data-Driven Tagging Logic

I developed the core analytical methodology for assigning the tags defined in the taxonomy. Key aspects include:
* Using a **normalization coefficient** based on district area to ensure fair, size-adjusted comparisons.
* Implementing this methodology to generate hierarchical tags for key categories like **Mobility** (transport hubs) and **Amenities** (convenience, shopping).
* Automating the process with Python scripts that calculate and upload the final tags to the database.

➡️ **For a detailed description of all tags and their logic, see the [Tag Taxonomy Document](common_labels/README.md).**

---
## Technologies Used

* **Languages**: Python, SQL (PostgreSQL)
* **Libraries**: Pandas, GeoPandas, SQLAlchemy, NumPy
* **Database**: PostgreSQL with PostGIS extension
* **Development Environment**: Jupyter Notebook

---
## Project Status

This repository serves as a portfolio piece. Please note that direct access to the production database is not provided; the focus is on demonstrating the methodology and code.
