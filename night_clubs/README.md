# Berlin Open Data ETL Pipeline: Nightclubs

This project is an ETL (Extract, Transform, Load) pipeline built with Python and SQL. Its purpose is to fetch raw data on nightclubs in Berlin from OpenStreetMap (OSM), clean it, enrich it with district/neighborhood data, and finally load it into a PostgreSQL database for analysis.

## Project Workflow

The pipeline is broken down into four main stages, executed by separate Jupyter notebooks:

### 1. Extract (Download)

**Script:** [`night_clubs_download.ipynb`](scripts/night_clubs_download.ipynb)

* Connects to the Overpass API (using an efficient query with Berlin's Relation ID).
* Fetches all `amenity=nightclub` objects within the Berlin boundary.
* Saves the raw JSON response as `source/night_clubs_raw.geojson`.
* **For a detailed breakdown of the data source, fields, and acquisition method, see the [`Data Source README`](source/README.md).**
  
### 2. Clean

**Script:** [`night_clubs_data_cleaning.ipynb`](scripts/night_clubs_data_cleaning.ipynb)

* Loads the raw `night_clubs_raw.geojson` file.
* Flattens the JSON structure into a DataFrame.
* Performs initial cleaning: drops irrelevant columns, merges duplicate columns (e.g., `phone`, `website`), and handles missing values.
* Saves the first-pass cleaned data to `source/night_clubs.csv`.

### 3. Transform (Enrich)

**Script:** [`night_clubs_data_transformation.ipynb`](scripts/night_clubs_data_transformation.ipynb) 

* Loads the cleaned `night_clubs.csv`.
* **Geocoding:** Fills missing `longitude` and `latitude` by geocoding addresses (using `geopy`).
* **Reverse Geocoding:** Fills missing address columns (`street`, `postcode`) by reverse-geocoding coordinates.
* **Enrichment:** Performs a **spatial join** (`sjoin`) with the `scripts/lor_ortsteile.geojson` file to add `district_id` and `neighborhood_id`.
* **Validation:** Confirms that all coordinates fall within the Berlin boundary.
* Saves the final, enriched data as `clean/night_clubs_clean_with_distr.csv`.

### 4. Load

**Script:** [`night_clubs_upload_to_database.ipynb`](scripts/night_clubs_upload_to_database.ipynb)

* Loads the final `clean/night_clubs_clean_with_distr.csv`.
* **Define Schema:** Connects to PostgreSQL and executes the `CREATE TABLE` statement for `berlin_source_data.night_clubs`.
* **Stage Data:** Re-orders the DataFrame columns to perfectly match the SQL table schema.
* **Load Data:** Uses the high-performance `copy_expert` (`COPY ... FROM STDIN`) method to bulk-insert all rows.
* **Add Constraints:** Executes `ALTER TABLE` to add the Foreign Key constraint, linking `night_clubs.district_id` to the `districts` table.

---

## Project Structure
```text
night_clubs/
├── scripts/
│   ├── night_clubs_download.ipynb
│   ├── night_clubs_data_cleaning.ipynb
│   ├── night_clubs_data_transformation.ipynb
│   ├── night_clubs_upload_to_database.ipynb
│   └── lor_ortsteile.geojson
│
├── clean/
│   ├── night_clubs_clean.csv
│   └── night_clubs_clean_with_distr.csv
│
├── source/
│   ├── districts.csv
│   ├── neighborhoods.csv
│   ├── night_clubs_raw.geojson
│   ├── night_clubs.csv
│   └── README.md
│
└── README.md
```

---

## Final Database Schema

| Column Name | Key | Data Type | Description | Data Example |
|---|---|---|---|---|
| `id` | Primary Key | `VARCHAR(30)` | Unique identifier from OSM (e.g., 'node/12345'). | `way/36908987` |
| `district_id` | Foreign Key | `VARCHAR(20)` | Identifier for the Berlin district, references `districts`. | `11002002` |
| `neighborhood_id` | | `VARCHAR(20)` | Identifier for the Berlin neighborhood. | `202` |
| `club_name` | | `VARCHAR(255)` | The official or common name of the nightclub. | `Gretchen` |
| `city` | | `VARCHAR(50)` | City name, expected to be 'Berlin'. | `Berlin` |
| `postcode` | | `VARCHAR(10)` | The 5-digit postal code. | `10963` |
| `street` | | `VARCHAR(255)` | The name of the street. | `Obentrautstraße` |
| `house_num` | | `VARCHAR(30)` | The house number. | `19-21` |
| `phone` | | `VARCHAR(50)` | Contact phone number (merged from sources). | `+49 30 25922702` |
| `email` | | `VARCHAR(255)` | Contact email address (merged from sources). | `gretchen@gretchen-club.de` |
| `website` | | `VARCHAR(500)`| Official website URL (merged from sources). | `https://www.gretchen-club.de/` |
| `opening_hours` | | `VARCHAR(500)`| Opening hours string from OSM. | `Mo 22:00-04:00; Fr-Sa...` |
| `wheelchair` | | `VARCHAR(30)` | Wheelchair accessibility (e.g., 'yes', 'no', 'limited'). | `yes` |
| `toilets_wheelchair` | | `VARCHAR(30)` | Wheelchair accessible toilet status. | `no` |
| `wheelchair_description` | | `VARCHAR(500)`| Text description of accessibility. | `Haben für den Eingang eine...` |
| `live_music` | | `VARCHAR(30)` | Indicates if the venue features live music. | `None` |
| `longitude` | | `DECIMAL(9,6)` | The geographic longitude (WGS 84). | `13.387921` |
| `latitude` | | `DECIMAL(9,6)` | The geographic latitude (WGS 84). | `52.495564` |
