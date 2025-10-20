## Detailed Tagging Logic
### 1. Transport Hub Tagging Logic

All tags discussed in this section (`#public_transport_hub`, `#bus_tram_hub`, `#uban_hub`) are part of the **Mobility** category in the overall tag taxonomy. A hierarchical logic was established to identify and assign these tags based on the quality of a district's public transport infrastructure.

1.  **Hub Identification Rule**: A district is considered a "hub" for a specific transport type if its total number of stops/stations exceeds a dynamically scaled threshold. The rule is:
    **`Actual Count > (Average Count × Area Coefficient)`**

2.  **Tagging Hierarchy**: To avoid redundancy, the following hierarchy will be applied:
    * **`#public_transport_hub`**: Assigned only if a district meets the hub criteria for **both** bus/tram **AND** U-Bahn networks.
    * **`#bus_tram_hub` / `#uban_hub`**: These more specific tags are assigned only if a district qualifies as a hub for one transport type, but not both. A district tagged as `#public_transport_hub` will not receive these secondary tags.
3. **Current Implementation Status**: The script at `labels-yelnikova/script_transport_full.ipynb` now fully implements the hub identification rule and the final tagging hierarchy. The resulting tags are formatted and appended to the central **`berlin_labels.district_labels_new`** table.

### 2. Accessibility Tagging Logic

This logic evaluates the convenience of a district for everyday life based on a core set of amenities.

* **Scoring System**: A district receives a **convenience score** from 0 to 3. It gets **1 point** for each of the three core amenity categories (banks, post offices, supermarkets) where its number of services exceeds the scaled threshold (`Actual Count > Average Count × Area Coefficient`).

* **Tagging Hierarchy**: Based on the score and the district's status as a mall hub, one of the following tags is assigned:
    * **`#commercial_hotspot` (Score: 3 + Mall Hub)**: This top-tier tag is assigned only to districts that score 3/3 on core amenities **AND** are also considered a mall hub. This tag supersedes `#highly_convenient`.
    * **`#highly_convenient` (Score: 3)**: Assigned to districts that score 3/3 on core amenities but are **not** mall hubs.
    * **`#daily_convenience` (Score: 2)**: Assigned to districts that score 2/3 on core amenities.

**Current Implementation Status**: The script at `labels-yelnikova/script_accesebility_full.ipynb` fully implements this logic. The resulting tags are formatted and appended to the central **`berlin_labels.district_labels_new`** table.

### 3. Shopping Destination Tag Logic

This is an **independent tag** designed to specifically identify major shopping hubs, which may differ from districts that are convenient for daily errands.

* **Identification Rule**: A district is considered a shopping destination based on a stricter threshold that emphasizes a significantly high concentration of shopping malls. The rule is:
    **`Mall Count > (Average Mall Count × Area Coefficient × 1.5)`**

* **Tag Assignment**: If the condition is met, the district receives the **`#shopping_destination`** tag. This tag can be assigned in addition to any other amenity tags a district may have.

**Current Implementation Status**: The script at `labels-yelnikova/script_accesebility_full.ipynb` fully implements this logic. The resulting tag is formatted and appended to the central **`berlin_labels.district_labels_new`** table.

