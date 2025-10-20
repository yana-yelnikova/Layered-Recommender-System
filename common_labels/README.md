# 🏙️ Berlin District Tag Taxonomy

This document defines the structured taxonomy of tags used to describe Berlin districts within the Layered Recommender System project. The goal is to create objective, data-driven, and transparent labels that reflect measurable characteristics of each district.

For each tag, the description and the main database tables used for its calculation are provided. Where the implementation is already complete, the specific preliminary logic used is also detailed.

---
## 📁 Database Overview

The tag definitions rely on data sourced from various tables within the project's PostgreSQL database. The main district-related tables available at the time of writing this taxonomy include:

`banks`, `bus_tram_stops`, `crime_statistics`, `dental_offices`, `districts`, `districts_pop_stat`, `gyms`, `hospitals`, `kindergartens`, `land_prices`, `long_term_listings`, `malls`, `milieuschutz_protection_zones`, `neighborhoods`, `parks`, `pharmacies`, `playgrounds`, `pools`, `post_offices`, `regional_statistics`, `rent_stats_per_neighborhood`, `sbahn`, `schools`, `short_term_listings`, `social_clubs_activities`, `supermarkets`, `theaters`, `ubahn`, `universities`, `venues`, `veterinary_clinics`.



---

## 💼 Category 1 — Economy & Real Estate

| Label | Description | Main Tables | Preliminary Logic |
|--------|--------------|--------------|-------------------|
| `#affordable_rent` | Districts with below-average rent | `rent_stats_per_neighborhood`, `long_term_listings` | |
| `#moderate_rent` | Balanced rent prices | `rent_stats_per_neighborhood`, `long_term_listings` |  |
| `#luxury_rent` | Indicates that the average rent in the district is in the top price segment compared to the rest of the city. | `rent_stats_per_neighborhood`, `long_term_listings` | |


---

## 🎭 Category 2 — Community & Lifestyle

| Label | Description | Main Tables | Preliminary Logic |
|--------|--------------|--------------|-------------------|
| `#active_nightlife` | Lively area with many bars, clubs, and restaurants | `venues`, `social_clubs_activities`, (`night_clubs` should be added to DB) |  |
| `#student_hub` | Concentration of students and universities | `universities`, `rent_stats_per_neighborhood` | |
| `#diverse_dining` | High concentration of restaurants, cafes| `venues` |  |
| `#cultural_hub` | Cultural density: museums, galleries, art spaces, theaters| `social_clubs_activities`, `theaters` (WiP), (`museum` should be added to DB) | |
| `#historic` | Districts with heritage sites or protected buildings | `milieuschutz_protection_zones` | |
| `#high_short_term_rentals` | High density of short-term rentals | `short_term_listings`|  |
| `#art_district` | Coworking and artistic community areas | `social_clubs_activities` |  |
| `#family_friendly` | Safe and calm areas with parks, schools, playgrounds | `schools`, `parks`, `playgrounds`, `kindergartens`, `crime_statistics` | |
| `#many_playgrounds` | High density of playgrounds. | `playgrounds` |  |
| `#pet_friendly` | Pet services and open spaces | `vet_clinics`, `parks`, `social_clubs_activities` |  |
| `#low_crime_rate` | Low crime rate districts | `crime_statistics` |  |

---

## 🌳 Category 3 — Green & Environment

| Label | Description | Main Tables | Preliminary Logic |
|--------|--------------|--------------|-------------------|
| `#green_space`| High percentage of total green space (parks, forests, etc.). |`parks`, `regional_statistics`|  |
| `#lots_of_parks` | High park density. | `parks` |  |
| `#large_forest_areas`| Presence of large, natural forest areas. | `regional_statistics`|  |
| `#quiet_neighborhood` | Residential area with low noise levels, confirmed by low population density and a high share of natural space. | `regional_statistics`, `districts_pop_stat` |  |
| `#low_population_density`| Low population density, creating a feeling of spaciousness.| `districts_pop_stat` |  |
| `#waterside_living` | Proximity to a river, lake, or canal. | `regional_statistics` |  |
| `#healthy_environment` | Assigned to districts with a good combination of positive environmental factors.  | (Derived) | It requires the district to have **at least two** of the following tags: `#lots_of_parks`, `#quiet_neighborhood`, `#low_population_density`, or `#waterside_living`. |
| `#peak_wellbeing` | A top-tier tag for districts that offer an exceptionally healthy and safe living environment.  | (Derived) | It requires **at least three** of the environmental tags listed above, **plus** the `#low_crime_rate` tag. |

---

## 🚇 Category 4 — Mobility & Accessibility

| Label | Description | Main Tables | Preliminary Logic |
|--------|--------------|--------------|-------------------|
| `#bike_friendly` | High number of bike paths and bike stations | `social_clubs_activities`, `bikelans` (WiP)| |
| `#car_friendly` | Characterized by infrastructure that makes private vehicle use convenient. This typically includes better availability of public parking and easy access to major highways or arterial roads. | `parking (Note: This table is not yet in the database)` |  |
| `#public_transport_hub` |  A top-tier connection point where multiple modes of public transport (e.g., U-Bahn, Bus, Tram) intersect, offering excellent connectivity across the city. This tag identifies the best-connected districts.| `ubahn`, `bus_tram_stops` | `A district receives this tag only if it qualifies as a hub for both bus/tram AND U-Bahn networks simultaneously. The rule for each is: Actual Count > (Average Count × Area Coefficient).` |
| `#uban_hub` |  A district with a significantly high density of U-Bahn stations, characterized by excellent subway access and often the intersection of multiple lines for easy transfers.| `ubahn` | `A district receives this tag if its uban_station_count > (average_station_count × area_coefficient), but it does not also qualify as a #bus_tram_hub.` |
| `#bus_tram_hub` | A district with a significantly high density of bus and tram stops, serving as a key interchange for numerous surface-level transport lines. | `bus_tram_stops` | `A district receives this tag if its bus_tram_stop_count > (average_stop_count × area_coefficient), but it does not also qualify as an #uban_hub.` |
| `#commuter_zone` | Describes a residential district, often on the outskirts, that offers excellent and fast transport connections (e.g., via S-Bahn, Regionalbahn, or highway) to the city center. It's ideal for commuters who work centrally but prefer to live in a quieter area.|  | |
| `#remote` | Identifies a district that is not only geographically distant but also poorly connected to the city center. Travel to and from the area is generally inconvenient and time-consuming due to a lack of fast or frequent transport links. |  |  |

---

## 🏥 Category 5 — Amenities & Services

| Label | Description | Main Tables | Preliminary Logic |
|--------|--------------|--------------|-------------------|
| `#high_sport_coverage` | District with a **high overall density** of sports facilities (gyms, pools, and clubs). Indicates strong infrastructure and accessibility to sports. | `pools`, `social_clubs_activities`, `gyms` | `(num_pools + num_gyms + num_sport_clubs) / area_km2 > 50th percentile AND (num_pools + num_gyms + num_sport_clubs) / (inhabitants / 1000) > 50th percentile` |
| `#various_sport_activities` | District with a **large variety of sports types and clubs**, reflecting diverse opportunities for residents to engage in different sports. | `social_clubs_activities` | `num_sport_clubs / area_km2 > 50th percentile AND num_sport_clubs / (inhabitants / 1000) > 50th percentile` |
| `#gyms_accessible` | District with **high gym availability** per km² and per population, meaning gyms are easily accessible to residents. | `gyms` | `num_gyms / area_km2 > 50th percentile AND num_gyms / (inhabitants / 1000) > 50th percentile` |
| `#pools_accessible` | District with **high gym availability** per km² and per population, meaning gyms are easily accessible to residents. | `pools` | `num_pools / area_km2 > 50th percentile AND num_pools / (inhabitants / 1000) > 50th percentile` |
| `#low_sport_coverage` | District below median levels across all sporty metrics, indicating **limited access** to sport infrastructure. | `pools`, `social_clubs_activities`, `gyms` | If **none** of the above sporty labels apply. |
| `#excellent_healthcare_access`| A top-tier tag assigned only to districts offering comprehensive medical coverage.| (Derived) | It requires the district to have **all three** of the following: a hospital nearby, a high density of pharmacies, AND a high density of dental clinics. This tag supersedes the individual healthcare tags below.  |
| `#hospitals_nearby` | Indicates that a district contains or is in close proximity to a hospital. This tag is assigned if the district does not qualify for the top-tier `#excellent_healthcare_access` tag. | `hospitals` |
| `#many_pharmacies` | Characterizes a district with a high, size-adjusted density of pharmacies. This tag is assigned if the district does not qualify for the top-tier `#excellent_healthcare_access` tag. | `pharmacies` |
| `#many_dental_clinics`| Characterizes a district with a high, size-adjusted density of dental clinics. This tag is assigned if the district does not qualify for the top-tier `#excellent_healthcare_access` tag. | `dental_offices` |
| `#daily_convenience` | Assigned to districts that offer a good level of convenience for everyday life by being well-serviced in at least two of the three core amenity categories. | `banks`, `post_offices`, `supermarkets` | A district receives this tag if it achieves an amenity score of exactly 2. A district gets 1 point for each category (banks, post offices, supermarkets) where its `Actual Count > (Average Count × Area Coefficient)` |
| `#highly_convenient` | Identifies districts that are exceptionally well-serviced across all three core amenities. This tag is **not assigned** if the district also qualifies for the top-tier `#commercial_hotspot` tag. | `banks`, `post_offices`, `supermarkets` | A district receives this tag if it achieves a **convenience score of exactly 3** but is not considered a mall hub. |
| `#commercial_hotspot` | A top-tier tag for districts that excel in both daily convenience and as major retail centers. This tag is hierarchical and **supersedes** `#highly_convenient`. | `banks`, `post_offices`, `supermarkets`, `malls` | A district receives this tag only if it achieves a **convenience score of 3 AND** is also a "mall hub" (`Mall Count > Average Count × Area Coefficient`). |
| `#shopping_destination`| An **independent tag** that specifically identifies major shopping hubs with a significantly high concentration of malls. | `malls` | A district receives this tag if its mall count exceeds a **stricter threshold**: `Mall Count > (Average Mall Count × Area Coefficient × 1.5)`. This tag can be assigned alongside other amenity tags. |

