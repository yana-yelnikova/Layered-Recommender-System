## Data Source

The primary data source for this project is a JSON file containing detailed information about **Nightclubs** within Berlin.

The data was obtained from **OpenStreetMap (OSM)**, a community-driven open-data project. Since a direct download of this specific dataset is not provided, the file was acquired by querying the **Overpass API** (`https://overpass-api.de/api/interpreter`).

The query was configured to fetch all objects (`node`, `way`, and `relation`) within the Berlin boundary (Area ID `3600062422`) that are tagged with `amenity=nightclub`.

The server's response was a standard **Overpass JSON** file (which is structurally different from GeoJSON) and saved as `night_clubs_raw.geojson`. This file serves as the raw data for this project.

### Update Frequency

* The live data on the OpenStreetMap server is updated **continuously** by thousands of contributors.
* Our captured file (`night_clubs_raw.geojson`) represents a **snapshot** of the data at the moment the query was executed and will not update on its own.

### Data Type

* **Source:** The source (OSM) is **dynamic**. To get the most current data, the download script must be run again.
* **Our File:** Our `night_clubs_raw.geojson` is a **static, one-time import**.

### Relevant Data Fields

The raw Overpass JSON contains a top-level `elements` key (a list of objects). The ETL process flattens the nested `tags` object from each element, resulting in 137 "raw" columns. The most critical fields used in the ETL process are:

* **Top-Level Fields:**
    * `@id`: The unique OSM ID (e.g., `node/123456`), which is cleaned and used as the primary key `id`.
    * `longitude`, `latitude`: Pre-extracted coordinates.

* **Core "Tags" (from the flattened `tags` object):**
    * `name`: Renamed to `club_name`.
    * `addr:street`, `addr:housenumber`, `addr:postcode`: Renamed to `street`, `house_num`, and `postcode`.
    * `phone`, `contact:phone`: **Merged** into the single `phone` column.
    * `website`, `contact:website`: **Merged** into the single `website` column.
    * `email`, `contact:email`: **Merged** into the single `email` column.
    * `live_music`, `wheelchair`, `opening_hours`: Kept for feature analysis.
    * `toilets:wheelchair`, `wheelchair:description`: Renamed to `toilets_wheelchair` and `wheelchair_description`.
