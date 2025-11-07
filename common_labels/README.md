# 🏙️ Berlin District Tag Taxonomy

This document defines the structured taxonomy of tags used to describe Berlin districts within the Layered Recommender System project. The goal is to create objective, data-driven, and transparent labels that reflect measurable characteristics of each district.

For each tag, the description and the main database tables used for its calculation are provided. Where the implementation is already complete, the specific preliminary logic used is also detailed.

---
## 📁 Database Overview
Main district-related tables reviewed:

`banks`, `bike_lanes`, `bus_tram_stops`, `crime_statistics`, `dental_offices`, `district_level_aggregated`, `districts`, `districts_pop_stat`, `doctors`, `gyms`, `hospitals`, `kindergartens`, `land_prices`, `long_term_listings`, `malls`, `milieuschutz_protection_zones`, `neighborhoods`, `night_clubs`, `parks`, `pharmacies`, `playgrounds`, `pools`, `post_offices`, `regional_statistics`, `rent_stats_per_neighborhood`, `sbahn`, `schools`, `short_term_listings`, `social_clubs_activities`, `supermarkets`,  `theaters`, `ubahn`, `universities`, `venues`, `veterinary_clinics`.

*New tables are under development.*

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
| `#active_nightlife` | Top-tier nightlife hub. Has a high count of **both** night clubs AND late-night (post 11pm) venues. | (Derived) | It requires the district to have two of the following: `many_clubs` AND `many_late_venues` |
| `#many_clubs` | High count of night clubs. (Used hierarchically if `#active_nightlife` is False). | `night_clubs` | `Actual Count > (Average Count × Area Coefficient)` |
| `#many_late_venues` | High count of late-night (post 11pm) venues. (Used hierarchically if other nightlife tags are False). | `venues` | `Actual Count > (Average Count × Area Coefficient)` |
| `#many_evening_venues` | **Independent Tag.** High count of evening (9pm-11pm) venues. Can be combined with other tags. | `venues` | `Actual Count > (Average Count × Area Coefficient)` |
| `#dining_and_drinks_hub` | Top-tier dining hub. High count of **all three**: restaurants, bars, AND cafes. | (Derived) | It requires the district to have all three of the following: `many_restaurants` AND `many_bars` AND `many_cafes` |
| `#good_venue_selection` | Strong dining & social scene. High count of **any two** of the three venue types (Rest, Bar, Cafe). | (Derived) | It requires the district to have two of the following: `many_restaurants`, `many_bars`, `many_cafes`  |
| `#many_restaurants` | High count of restaurants. (Used hierarchically if **only** this one condition is met). | `venues` | `Actual Count > (Average Count × Area Coefficient * 1.5)` |
| `#many_bars` | High count of bars. (Used hierarchically if **only** this one condition is met). | `venues` | `Actual Count > (Average Count × Area Coefficient * 1.5)` |
| `#many_cafes` | High count of cafes. (Used hierarchically if **only** this one condition is met). | `venues` | `Actual Count > (Average Count × Area Coefficient * 1.5)` |
| `#student_hub` | Concentration of students and universities | `universities`, `rent_stats_per_neighborhood` | |
| `#diverse_dining` | High concentration of restaurants, cafes| `venues` |  |
| `#cultural_hub` | Cultural density: museums, galleries, art spaces, theaters| `social_clubs_activities`, `theaters` (WiP), (`museum` should be added to DB) | |
| `#historic` | Districts with heritage sites or protected buildings | `milieuschutz_protection_zones` | |
| `#high_short_term_rentals` | High density of short-term rentals | `short_term_listings`|  |
| `#art_district` | Districts with a high concentration of art venues — art centers, dance studios, art clubs and creative spaces | `social_clubs_activities` |`art_density = num_art_places / area_sq_km`, `art_per_1000 = num_art_places / (inhabitants / 1000)` If both values are above the median (50th percentile) → label as `art_district` Otherwise → no label |
| `#music_district` | Districts with a high concentration of music venues, studios and music schools | `social_clubs_activities` |`music_density = num_music_places / area_sq_km`, `music_per_1000 = num_music_places / (inhabitants / 1000)` If both values are above the median (50th percentile) → label as `music_district` Otherwise → no label |
| `#family_friendly` | Safe and calm areas with parks, schools, playgrounds | `schools`, `parks`, `playgrounds`, `kindergartens`, `crime_statistics` | |
| `#many_playgrounds` | High density of playgrounds. | `playgrounds` |  |
| `#pet_friendly` | Pet services and open spaces | `vet_clinics`, `parks`, `social_clubs_activities` |  |
| `#low_crime_rate` | Low crime rate districts | `crime_statistics` | Assigned if the district's overall `crime_rate_100k` (total cases / inhabitants * 100k) for the latest year in DB is **below the 25th percentile** of the rates across all districts. |

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
| `#very_high_bike_infrastructure` | District with a very strong and well-developed cycling infrastructure, offering excellent coverage and accessibility for cyclists. Indicates both a dense and extensive bike network relative to population and area. | `bikelanes` | `bike_lane_score ≥ 75th percentile`|
| `#high_bike_infrastructure` | District with above-average cycling infrastructure, providing good accessibility and coverage, though not the highest citywide. | `bikelanes` | `50th percentile ≤ bike_lane_score < 75th percentile `|
| `#medium_bike_infrastructure`  | District with a moderate level of cycling infrastructure — bike lanes are present but not evenly distributed or less accessible relative to area and population. | `bikelanes` | `25th percentile ≤ bike_lane_score < 50th percentile`|
| `#low_bike_infrastructure` | District with limited cycling infrastructure, where bike lane density and accessibility are below the 25th percentile of all districts.  | `bikelanes` | `bike_lane_score < 25th percentile`|
| `#car_friendly` | Characterized by infrastructure that makes private vehicle use convenient. This typically includes better availability of public parking and easy access to major highways or arterial roads. | `parking (Note: This table is not yet in the database)` |  |
| `#public_transport_hub` | A top-tier connection point offering excellent connectivity across all modes. Assigned to districts that are hubs for **all three** main public transport types (Bus/Tram, U-Bahn, **AND** S-Bahn). Supersedes individual hub tags. | `ubahn`, `bus_tram_stops`, `sbahn` | `Hub Type Count == 3`, where `Hub Type Count` is the sum of boolean results for each transport type based on `Actual Count > (Average Count × Area Coefficient)`.                      |
| `#uban_hub`             | A district with significantly high U-Bahn access. Not assigned if `#public_transport_hub` applies.                                         | `ubahn`   | The rule for it is:  `Actual Count > (Average Count × Area Coefficient)`                                                                     |
| `#bus_tram_hub`         | A district with significantly high bus and tram access. Not assigned if `#public_transport_hub` applies.                                   | `bus_tram_stops`| The rule for it is:  `Actual Count > (Average Count × Area Coefficient)`                                                                 |
| `#sbahn_hub`            | A district with significantly high S-Bahn access. Not assigned if `#public_transport_hub` applies.                                         | `sbahn`   | The rule for it is:  `Actual Count > (Average Count × Area Coefficient)`                                                                     |                                                                                           |
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
| `#full_spectrum_healthcare` | Top-tier tag assigned only to districts meeting criteria for **all five** key healthcare pillars: Practices (Primary & Pediatric), Specialists, Hospitals, Pharmacies, and Dentists. This tag supersedes all individual healthcare density tags below. | (Derived) | Requires the district to have all five of the following: `#core_primary_care_hub` AND `#specialist_hub` AND `#high_hospital_density` AND `#many_pharmacies` AND `#many_dental_clinics` |
| `#core_primary_care_hub` | Indicates a high density of both Adult Primary Care (GPs/Internal) and Pediatric Care, normalized by population. This tag supersedes the individual Primary Care tags below. | (Derived) | Requires the district to have both of the following: `#strong_primary_adult_care` AND `#strong_pediatric_care` |
| `#high_hospital_density` | Characterizes a district with a high density of hospitals per square kilometer, indicating good access to inpatient and emergency care. | `hospitals` | `Hospital count > (Average count × Area coefficient)` |
| `#many_dental_clinics` | Characterizes a district with a high density of dental clinics, normalized by population. | `dental_offices` | `Dental office count > (Average count × Population coefficient)` |
| `#many_pharmacies` | Characterizes a district with a high density of pharmacies, normalized by population. | `pharmacies` | `Pharmacy count > (Average count × Population coefficient)` |
| `#specialist_hub` | Characterizes a district with a high weighted density of specialist capacity (e.g., MVZ, large clinics), normalized by population. | `doctors` | `Specialist Score > (Average Score × Population coefficient)` |
| `#strong_primary_adult_care` | Characterizes a district with a high weighted density of adult primary care capacity (GPs/Internal), normalized by population. | `doctors` | `Adult Primary Score > (Average Score × Population coefficient)` |
| `#strong_pediatric_care` | Characterizes a district with a high weighted density of pediatric care capacity, normalized by population. | `doctors` | `Pediatric Score > (Average Score × Population coefficient)` |
| `#sunday_pharmacy_access` | Indicates that the district has at least one pharmacy regularly open on Sundays (excluding rotating emergency pharmacies). This tag is independent. | `pharmacies` | `Count of pharmacies open on Sunday > 0` |
| `#daily_convenience` | Assigned to districts that offer a good level of convenience for everyday life by being well-serviced in at least two of the three core amenity categories. | `banks`, `post_offices`, `supermarkets` | A district receives this tag if it achieves an amenity score of exactly 2. A district gets 1 point for each category (banks, post offices, supermarkets) where its `Actual Count > (Average Count × Area Coefficient)` |
| `#highly_convenient` | Identifies districts that are exceptionally well-serviced across all three core amenities. This tag is **not assigned** if the district also qualifies for the top-tier `#commercial_hotspot` tag. | `banks`, `post_offices`, `supermarkets` | A district receives this tag if it achieves a **convenience score of exactly 3** but is not considered a mall hub. |
| `#commercial_hotspot` | A top-tier tag for districts that excel in both daily convenience and as major retail centers. This tag is hierarchical and **supersedes** `#highly_convenient`. | `banks`, `post_offices`, `supermarkets`, `malls` | A district receives this tag only if it achieves a **convenience score of 3 AND** is also a "mall hub" (`Mall Count > Average Count × Area Coefficient`). |
| `#shopping_destination`| An **independent tag** that specifically identifies major shopping hubs with a significantly high concentration of malls. | `malls` | A district receives this tag if its mall count exceeds a **stricter threshold**: `Mall Count > (Average Mall Count × Area Coefficient × 1.5)`. This tag can be assigned alongside other amenity tags. |
