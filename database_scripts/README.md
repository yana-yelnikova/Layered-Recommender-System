# Analytical Database Schema Scripts

This directory contains the SQL scripts responsible for creating and populating the core analytical tables in the database. These tables are designed to pre-calculate and aggregate data, which significantly improves the performance and simplifies the logic of the downstream Python labeling scripts.


---
## 1. `district_attributes.sql`

This script is responsible for creating the **`berlin_labels.district_attributes`** table.

The purpose of this table is to store pre-calculated, static metrics for each district, eliminating the need for repeated, expensive calculations. It contains the following key metrics:

* **`area_sq_km` and `area_coefficient`**: The absolute area and a normalized coefficient to account for significant differences in the geographical size of the districts.
* **`inhabitants` and `population_coefficient`**: The total population and a normalized coefficient to account for differences in population size.

These coefficients are fundamental for the fair, scaled comparisons used in the tagging logic.

#### Area Coefficient Calculation
The `area_coefficient` is calculated based on the following formula:
> `Coefficient_district = Area_district / Area_average`

#### Population Coefficient Calculation
The `population_coefficient` is calculated based on the following formula:
> `Coefficient_population = Population_district / Population_average`

#### Final Database Schema
| Column Name | Key | Data Type | Description | Data Example |
|---|---|---|---|---|
| `district_id` | Foreign Key | `VARCHAR(20)` | Identifier for the Berlin district, references `districts`. | `11004004` |
| `area_sq_km` | | `DECIMAL` | The district's total area, calculated in sq. km using PostGIS (`ST_Area`). | `64.662978` |
| `inhabitants` | | `INTEGER` | Total population from the latest available year (`regional_statistics`). | `343081` |
| `area_coefficient` | | `DECIMAL` | Normalized area score. Calculated as `Area_district / Area_average`. | `0.871207` |
| `population_coefficient` | | `DECIMAL` | Normalized population score. Calculated as `Population_district / Population_average`. | `1.061595` |

---
## 2. `district_features.sql`

This script is responsible for creating the *base structure* of the central "feature table" at **`berlin_labels.district_features`**.

This table serves as the single source of truth for all pre-aggregated data needed by the Python labeling scripts. It contains a wide format with one row per district and columns representing the total count of various amenities (e.g., `bus_tram_stop_count`, `bank_count`, `num_gyms`, etc.). This SQL script creates the 27 base features.

**Note:** Three additional features related to healthcare (`_score` columns) are calculated in a separate Python script (from the `doctors` ETL pipeline) and are added to this table via `ALTER TABLE` and `UPDATE...FROM`.

#### Final Database Schema (Grouped by Category)

**Transport Features**
| Column Name | Data Type | Description | Data Example |
|---|---|---|---|
| `district_id` | `VARCHAR(20)` | Foreign Key to `districts` table. | `11001001` |
| `bus_tram_stop_count` | `BIGINT` | Total `COUNT(DISTINCT stop_id)` from `bus_tram_stops`. | `222` |
| `uban_station_count` | `BIGINT` | Total `COUNT(DISTINCT station)` from `ubahn`. | `32` |
| `sbahn_station_count` | `BIGINT` | Total `COUNT(DISTINCT station_id)` from `sbahn`. | `45` |

**Accessibility (Daily Convenience) Features**
| Column Name | Data Type | Description | Data Example |
|---|---|---|---|
| `bank_count` | `BIGINT` | Total `COUNT(DISTINCT bank_id)` from `banks`. | `48` |
| `post_office_count` | `BIGINT` | Total `COUNT(DISTINCT id)` from `post_offices`. | `40` |
| `supermarket_count` | `BIGINT` | Total `COUNT(DISTINCT store_id)` from `supermarkets`. | `146` |
| `mall_count` | `BIGINT` | Total `COUNT(DISTINCT id)` from `malls`. | `13` |

**Sport Features**
| Column Name | Data Type | Description | Data Example |
|---|---|---|---|
| `num_sport_clubs` | `BIGINT` | `COUNT` of records from `social_clubs_activities` where `club = 'sport'` etc. | `15` |
| `num_gyms` | `BIGINT` | Total `COUNT(DISTINCT gym_id)` from `gyms`. | `63` |
| `num_pools` | `BIGINT` | Total `COUNT(DISTINCT pool_id)` from `pools`. | `9` |

**Healthcare Features**
| Column Name | Data Type | Description | Data Example |
|---|---|---|---|
| `hospital_count` | `BIGINT` | Total `COUNT(DISTINCT hospital_id)` from `hospitals_refactored`. | `46` |
| `pharmacy_count` | `BIGINT` | Total `COUNT(DISTINCT pharmacy_id)` from `pharmacies`. | `75` |
| `dental_office_count` | `BIGINT` | Total `COUNT(DISTINCT osm_id)` from `dental_offices`. | `82` |
| `total_primary_adult_score`* | `DECIMAL` | Weighted score from `doctors` ETL. (Added via `ALTER TABLE`). | `55.8` |
| `total_pediatric_score`* | `DECIMAL` | Weighted score from `doctors` ETL. (Added via `ALTER TABLE`). | `22.2` |
| `specialist_score_total`* | `DECIMAL` | Weighted score from `doctors` ETL. (Added via `ALTER TABLE`). | `259` |

**Crime Feature**
| Column Name | Data Type | Description | Data Example |
|---|---|---|---|
| `total_crime_cases_latest_year` | `BIGINT` | `SUM(total_number_cases)` from `crime_statistics` for `MAX(year)`. | `71652` |

**Nightlife & Venue Features**
| Column Name | Data Type | Description | Data Example |
|---|---|---|---|
| `evening_venue_count_9pm_11pm` | `BIGINT` | `COUNT` from `venues` where `operating_hours_category = 'Evening (9pm-11pm)'`. | `386` |
| `late_venue_count_after_11pm` | `BIGINT` | `COUNT` from `venues` where `operating_hours_category = 'Late (After 11pm)'`. | `215` |
| `night_club_count` | `BIGINT` | Total `COUNT(DISTINCT id)` from `night_clubs`. | `43` |
| `restaurant_count` | `BIGINT` | `COUNT` from `venues` where `category = 'restaurant'`. | `903` |
| `bar_count` | `BIGINT` | `COUNT` from `venues` where `category = 'bar'`. | `236` |
| `cafe_count` | `BIGINT` | `COUNT` from `venues` where `category = 'cafe'`. | `540` |

**Infrastructure & Cultural Features**
| Column Name | Data Type | Description | Data Example |
|---|---|---|---|
| `bike_lane_count` | `BIGINT` | Total `COUNT(DISTINCT bikelane_id)` from `bike_lanes`. | `7552` |
| `total_bike_lane_km` | `DECIMAL` | `SUM(length_m)/1000` from `bike_lanes`. | `460.0345` |
| `num_culture_places` | `BIGINT` | `COUNT` from `social_clubs_activities` + `theaters`. | `181` |
| `num_art_places` | `BIGINT` | `COUNT` of art venues from `social_clubs_activities`. | `80` |
| `num_music_places` | `BIGINT` | `COUNT` of music venues from `social_clubs_activities`. | `26` |

> `*` **Note on Healthcare Scores:** The three `_score` columns are not created by the main `district_features.sql` script. They are calculated in the Python ETL pipeline for `doctors` (due to complex weighted logic) and are programmatically added to this table via the `doctors/scripts/doctors_upload_to_db.ipynb` script (`ALTER TABLE ... ADD COLUMN ...` and `UPDATE...FROM`). This separation of concerns (SQL for simple counts, Python for complex scoring) is a core part of the architecture.

### 💡 How to Contribute

If your tagging logic requires a new, calculated metric (like the count of kindergartens), you must **add the corresponding column to this central feature table**. Please update this main SQL script to include your new feature. This ensures that all calculated data is available in one consistent location for the entire project.

---
## 3. `creating_district_labels_new.sql`

This script is responsible for creating the final output table at **`berlin_labels.district_labels_new`**.

This table is designed to store the results from all individual Python labeling scripts. It uses a standardized "long" format (`district_id`, `category`, `label`) which is highly scalable. The table includes a primary key to prevent duplicate entries and a foreign key to the main `districts` table to ensure data integrity. Individual Python scripts should be configured to append their results to this central table.

#### Final Database Schema
| Column Name | Key | Data Type | Description | Data Example |
|---|---|---|---|---|
| `district_id` | Primary Key, Foreign Key | `VARCHAR(10)` | Identifier for the Berlin district. Part of a composite PK. | `11004004` |
| `category` | | `VARCHAR(50)` | The top-level category of the tag (e.g., 'Mobility'). | `Amenities & Services` |
| `label` | Primary Key | `VARCHAR(50)` | The specific, data-driven tag. Part of a composite PK. | `#high_sport_coverage` |
