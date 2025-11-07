## Data Source

The primary data source for this project is a JSON file containing detailed information about **Doctors' Offices** and **Clinics** within Berlin.

The data was obtained from **OpenStreetMap (OSM)**, a community-driven open-data project. Since a direct download of this specific dataset is not provided, the file was acquired by querying the **Overpass API** (`https://overpass-api.de/api/interpreter`).

The query was configured to fetch all objects (`node`, `way`, and `relation`) within the Berlin boundary (Area ID `3600062422`) that are tagged with either `amenity=doctors` or `amenity=clinic`.

The server's response was a standard **Overpass JSON** file (which is structurally different from GeoJSON) and saved as `doctors_and_clinics_raw.geojson`. This file serves as the raw data for this project.

### Update Frequency

* The live data on the OpenStreetMap server is updated **continuously** by thousands of contributors.
* Our captured file (`doctors_and_clinics_raw.geojson`) represents a **snapshot** of the data at the moment the query was executed and will not update on its own.

### Data Type

* **Source:** The source (OSM) is **dynamic**. To get the most current data, the download script must be run again.
* **Our File:** Our `doctors_and_clinics_raw.geojson` is a **static, one-time import**.

### Relevant Data Fields

The raw Overpass JSON contains a top-level `elements` key (a list of objects). The most critical fields used in the ETL process are:

* **Top-Level Fields:**
    * `id`: The unique OpenStreetMap ID.
    * `lat`, `lon`: Coordinates (for `node` objects).
    * `center`: A nested object with `lat` and `lon` (for `way`/`relation` objects).

* **Core "Tags" (from the nested `tags` object):**
    * `name`: The name of the facility.
    * `amenity`: The primary type (*doctors* or *clinic*).
    * `addr:street`, `addr:housenumber`, `addr:postcode`: Key address components used for matching and geocoding.
    * `healthcare:speciality` (and various `health_specialty:*` keys): These are aggregated to create the single `speciality` column.
    * `website`, `contact:website`: Merged to salvage missing contact info.
    * `wheelchair`: Used to assess accessibility.
