# Detailed Tagging Logic

### 1. Transport Hub Tagging Logic

All tags discussed in this section (`#public_transport_hub`, `#bus_tram_hub`, `#uban_hub`, `#sbahn_hub`) are part of the **Mobility & Accessibility** category. A hierarchical logic was established to identify and assign these tags based on the quality of a district's public transport infrastructure.

* **Hub Identification Rule**: A district is considered a "hub" for a specific transport type if its total number of stops/stations exceeds a dynamically scaled threshold. The rule is:
    **`Actual Count > (Average Count × Area Coefficient)`**

* **Tagging Hierarchy**: To provide the most accurate profile while avoiding redundancy, the following hierarchy is applied:
    * **`#public_transport_hub` (Top-Tier)**: Assigned only if a district meets the hub criteria for **all three** main transport types: Bus/Tram **AND** U-Bahn **AND** S-Bahn.
    * **`#bus_tram_hub` / `#uban_hub` / `#sbahn_hub` (Base Tags)**: Assigned if a district meets the hub criteria for that specific transport type. These tags **can be combined** (e.g., a district can have both `#uban_hub` and `#sbahn_hub`). However, if `#public_transport_hub` is assigned, these base tags are suppressed.

* **Current Implementation Status**: The script at `script_transport_full.ipynb` now fully implements the hub identification rule and the final tagging hierarchy. The resulting tags are formatted and appended to the central **`berlin_labels.district_labels_new`** table.

### 2. Accessibility Tagging Logic

This logic evaluates the convenience of a district for everyday life based on a core set of amenities.

* **Scoring System**: A district receives a **convenience score** from 0 to 3. It gets **1 point** for each of the three core amenity categories (banks, post offices, supermarkets) where its number of services exceeds the scaled threshold (`Actual Count > Average Count × Area Coefficient`).

* **Tagging Hierarchy**: Based on the score and the district's status as a mall hub, one of the following tags is assigned:
    * **`#commercial_hotspot` (Score: 3 + Mall Hub)**: This top-tier tag is assigned only to districts that score 3/3 on core amenities **AND** are also considered a mall hub. This tag supersedes `#highly_convenient`.
    * **`#highly_convenient` (Score: 3)**: Assigned to districts that score 3/3 on core amenities but are **not** mall hubs.
    * **`#daily_convenience` (Score: 2)**: Assigned to districts that score 2/3 on core amenities.

**Current Implementation Status**: The script at `script_accessibility_full.ipynb` fully implements this logic. The resulting tags are formatted and appended to the central **`berlin_labels.district_labels_new`** table.

### 3. Shopping Destination Tag Logic

This is an **independent tag** designed to specifically identify major shopping hubs, which may differ from districts that are convenient for daily errands.

* **Identification Rule**: A district is considered a shopping destination based on a stricter threshold that emphasizes a significantly high concentration of shopping malls. The rule is:
    **`Mall Count > (Average Mall Count × Area Coefficient × 1.5)`**

* **Tag Assignment**: If the condition is met, the district receives the **`#shopping_destination`** tag. This tag can be assigned in addition to any other amenity tags a district may have.

**Current Implementation Status**: The script at `script_accessibility_full.ipynb` fully implements this logic. The resulting tag is formatted and appended to the central **`berlin_labels.district_labels_new`** table.

### 4. Healthcare Tagging Logic

This logic evaluates the availability and density of healthcare facilities within the `Amenities & Services` category using a multi-layered, hierarchical approach.

* **Normalization**: Density calculations use the **Area Coefficient** for facilities serving a wide area (Hospitals) and the **Population Coefficient** for services tied to local demand (Practices, Pharmacies, Dentists) to ensure fair comparisons.

* **Base Tag Assignment**: Specific tags are assigned based on scores (weighted capacity) or counts, exceeding the scaled average threshold:
    * `#high_hospital_density`: Assigned if `Hospital count > (Average count × Area Coefficient)`.
    * `#many_pharmacies`: Assigned if `Pharmacy count > (Average count × Population Coefficient)`.
    * `#many_dental_clinics`: Assigned if `Dental office count > (Average count × Population Coefficient)`.
    * `#strong_primary_adult_care`: Assigned if `Adult Primary Care Score > (Average Score × Population Coefficient)`.
    * `#strong_pediatric_care`: Assigned if `Pediatric Care Score > (Average Score × Population Coefficient)`.
    * `#specialist_hub`: Assigned if `Specialist Score > (Average Score × Population Coefficient)`.
    * `#sunday_pharmacy_access`: An independent tag assigned if `Count of pharmacies open on Sunday > 0`.

* **Composite Tag Logic (Tier 2 and Tier 3)**: Higher-level tags consolidate the base tags, and a strict hierarchical cleanup is applied to simplify the final output.
    * **Tier 2: `#core_primary_care_hub`**: Indicates high density in both Adult Primary Care and Pediatric Care. **Condition:** Requires `#strong_primary_adult_care` AND `#strong_pediatric_care`.
    * **Tier 3: `#full_spectrum_healthcare` (Top-Tier)**: Indicates a district meets criteria for all five key healthcare pillars (Practices, Specialists, Pharmacies, Dentists, and Hospitals). **Condition:** Requires `#core_primary_care_hub` AND `#specialist_hub` AND `#many_pharmacies` AND `#many_dental_clinics` AND `#high_hospital_density`.

* **Hierarchical Cleanup Rule**: If a higher-level composite tag is assigned, all component tags used to calculate it are suppressed (`FALSE`) in the final output.
    * If `#core_primary_care_hub` is assigned, `#strong_primary_adult_care` and `#strong_pediatric_care` are suppressed.
    * If `#full_spectrum_healthcare` is assigned, all component tags (Tier 1 and Tier 2) are suppressed.
    
**Current Implementation Status**: The script at `script_healthcare.ipynb` fully implements this logic. The resulting tag is formatted and appended to the central **`berlin_labels.district_labels_new`** table.

### 5. Crime Rate Tagging Logic

This logic identifies districts with the lowest crime rates within the **`Community & Lifestyle`** category.

* **Identification Rule**: The overall crime rate per 100,000 inhabitants (`crime_rate_100k`) is calculated for each district using the latest available year's data (`total_crime_cases_latest_year` / `inhabitants` * 100k).
* **Threshold**: The 25th percentile of these crime rates across all districts is determined.
* **Tag Assignment**: Districts with a `crime_rate_100k` **below** this 25th percentile threshold receive the **`#low_crime_rate`** tag.

**Current Implementation Status**: The script at `script_low_crime.ipynb` fully implements this logic. The resulting tag is formatted and appended to the central **`berlin_labels.district_labels_new`** table.

### 6. Nightlife Tagging Logic

This logic assesses the density and variety of nightlife options within the **`Community & Lifestyle`** category.

* **Normalization**: All density calculations use the **Area Coefficient** to ensure fair comparisons between districts of different sizes. The threshold is `Actual Count > (Average Count × Area Coefficient)`.
* **Hierarchical Tag Assignment**: A primary tag is assigned based on a **priority system** built from two conditions (high club count, high late-venue count).
    * `#active_nightlife`: Top-tier tag assigned if the district meets the criteria for **both** `#many_clubs` AND `#many_late_venues`.
    * `#many_clubs`: Assigned if `#active_nightlife` is false, but the district meets the threshold for night clubs.
    * `#many_late_venues`: Assigned if both of the above tags are false, but the district meets the threshold for late-night (post-11pm) venues.
* **Independent Tag**:
    * `#many_evening_venues`: An independent tag assigned if the district meets the threshold for evening (9pm-11pm) venues. This tag can be combined with one of the primary hierarchical tags (e.g., a district can be tagged as `#active_nightlife` and `#many_evening_venues`).

**Current Implementation Status**: This logic is implemented in the script `script_community_and_lifestyle.ipynb`. The script processes all tags (including splitting combined tags into separate rows) and uploads them to the `berlin_labels.district_labels_new` table using a delete-then-insert method for this specific list of tags.

### 7. Dining & Drinks Tagging Logic

This logic identifies districts with a high concentration of dining and social venues, also within the **`Community & Lifestyle`** category.

* **Normalization & Threshold**: Calculations use the **Area Coefficient** but apply a **stricter threshold** (`multiplier = 1.5`) to identify only the most significant hubs. The logic is `Actual Count > (Average Count × Area Coefficient × 1.5)`.
* **Hierarchical Tag Assignment**: A single tag is assigned based on a 3-tier hierarchy, determined by how many venue types (Restaurants, Bars, Cafes) meet this stricter threshold.
    * `#dining_and_drinks_hub`: Top-tier tag. Assigned if **all three** (Restaurants, Bars, AND Cafes) meet the threshold.
    * `#good_venue_selection`: Mid-tier tag. Assigned if **any two** of the three types meet the threshold.
    * `#many_restaurants` / `#many_bars` / `#many_cafes`: Base-tier tags. Assigned if **only one** of the three types (e.g., only restaurants) meets the threshold.

**Current Implementation Status**: This logic is implemented in the same script as the nightlife tags (`script_community_and_lifestyle.ipynb`). The resulting tags are formatted and uploaded to the `berlin_labels.district_labels_new` table using the same process.
