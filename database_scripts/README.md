### 1. Area Coefficient Calculation

To account for significant differences in the geographical size of the districts, a normalization coefficient was calculated.

1.  **Area Calculation**: The area of each district was calculated in square kilometers (km²) using its geospatial data.
2.  **Average Area**: The average area of all districts was determined.
3.  **Coefficient Assignment**: Each district was assigned an `area_coefficient` based on the following formula:

    $$
    \text{Coefficient}_{\text{district}} = \frac{\text{Area}_{\text{district}}}{\text{Area}_{\text{average}}}
    $$

This coefficient represents how much larger or smaller a district is compared to the average. It is used to create a scaled, fair threshold for evaluating metrics like the number of transport stops.

### 2. Population Coefficient Calculation

To account for significant differences in the population of the districts, a normalization coefficient was calculated.

* **Population Count:** The number of inhabitants for each district was sourced from the database.
* **Average Population:** The average population across all districts was determined.
* **Coefficient Assignment:** Each district was assigned a `population_coefficient` based on the following formula:

$$
\text{Coefficient}_{\text{population}} = \frac{\text{Population}_{\text{district}}}{\text{Population}_{\text{average}}}
$$

This coefficient represents how much more or less populous a district is compared to the average. It is used to create a scaled, fair threshold for evaluating metrics on a per-capita basis (e.g., the number of sports facilities per resident).


#### Database Implementation
To optimize performance, these calculations of area coefficient are performed directly in the database using PostGIS. The SQL script used to create and populate the table is located at `features/creating_district_attributes.sql`. The results are stored in a persistent table named **`berlin_source_data.district_attributes`**, which contains the `district_id`, `area_sq_km`, and `area_coefficient`, `inhabitants` and `population_coefficient` eliminating the need for repeated calculations.

### 3. Centralized Feature Table

To streamline the labeling process and improve performance, a centralized feature table has been created at **`berlin_labels.district_features`**.

This table contains pre-aggregated data for each district (e.g., the total count of bus stops, banks, etc.), eliminating the need for each script to perform these calculations on the fly. All labeling scripts should now source their data from this single, efficient table.

### How to Contribute

If your tagging logic requires a new, calculated metric (like the count of kindergartens or the total length of bike lanes), you must **add the corresponding column to this central feature table**. Please update the main SQL script responsible for creating this table to include your new feature. This ensures that all calculated data is available in one consistent location for the entire project.

The script for creating and populating this table can be found at: `features/creating_district_features.sql`

### 4. Final Tag Table

To store the final output of the labeling scripts, a dedicated table has been created at **`berlin_labels.district_labels_new`**.

This table has a standardized structure (`district_id`, `category`, `label`) and is designed to aggregate the results from all individual analysis scripts. A primary key on `(district_id, label)` prevents duplicate entries, and a foreign key links `district_id` to the main `districts` table to ensure data integrity.

The SQL script used to create this table is located at `features/creating_district_labels_new.sql`. Individual scripts should now be configured to append their results to this central table.
