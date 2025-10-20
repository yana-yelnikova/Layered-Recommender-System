-- 1. Switch to the team role. All subsequent commands will be executed as 'data_team'.
SET ROLE data_team;

-- 2. Drop the old table. As we are now 'data_team', we have the necessary permissions.
DROP TABLE IF EXISTS berlin_labels.district_features;

-- 3. Create the new table. The owner of this table will automatically be 'data_team'.
CREATE TABLE berlin_labels.district_features AS (
    SELECT
        d.district_id,
        -- Transport columns
        COALESCE(b.bus_tram_stop_count, 0) AS bus_tram_stop_count,
        COALESCE(u.uban_station_count, 0) AS uban_station_count,
        -- Accessibility columns
        COALESCE(ba.bank_count, 0) AS bank_count,
        COALESCE(po.post_office_count, 0) AS post_office_count,
        COALESCE(su.supermarket_count, 0) AS supermarket_count,
        COALESCE(ma.mall_count, 0) AS mall_count,
        -- Sport-related features
        COALESCE(sc.num_sport_clubs, 0) AS num_sport_clubs,
        COALESCE(g.num_gyms, 0) AS num_gyms,
        COALESCE(p.num_pools, 0) AS num_pools
    FROM
        berlin_source_data.districts d
    -- Subquery for bus/tram stops
    LEFT JOIN (
        SELECT district_id, COUNT(DISTINCT stop_id) AS bus_tram_stop_count
        FROM berlin_source_data.bus_tram_stops
        GROUP BY district_id
    ) b ON d.district_id = b.district_id
    -- Subquery for U-Bahn stations
    LEFT JOIN (
        SELECT district_id, COUNT(DISTINCT station) AS uban_station_count
        FROM berlin_source_data.ubahn
        GROUP BY district_id
    ) u ON d.district_id = u.district_id
    -- Subquery for banks
    LEFT JOIN (
        SELECT district_id, COUNT(DISTINCT bank_id) AS bank_count
        FROM berlin_source_data.banks
        GROUP BY district_id
    ) ba ON d.district_id = ba.district_id
    -- Subquery for post offices
    LEFT JOIN (
        SELECT district_id, COUNT(DISTINCT id) AS post_office_count
        FROM berlin_source_data.post_offices
        GROUP BY district_id
    ) po ON d.district_id = po.district_id
    -- Subquery for supermarkets
    LEFT JOIN (
        SELECT district_id, COUNT(DISTINCT store_id) AS supermarket_count
        FROM berlin_source_data.supermarkets
        GROUP BY district_id
    ) su ON d.district_id = su.district_id
    -- Subquery for malls
    LEFT JOIN (
        SELECT district_id, COUNT(DISTINCT id) AS mall_count
        FROM berlin_source_data.malls
        GROUP BY district_id
    ) ma ON d.district_id = ma.district_id
    -- Subquery for Gyms
    LEFT JOIN (
        SELECT district_id, COUNT(DISTINCT gym_id) AS num_gyms
        FROM berlin_source_data.gyms
        GROUP BY district_id
    ) g ON d.district_id = g.district_id
    -- Subquery for Pools
    LEFT JOIN (
        SELECT district_id, COUNT(DISTINCT pool_id) AS num_pools
        FROM berlin_source_data.pools
        GROUP BY district_id
    ) p ON d.district_id = p.district_id
    -- Subquery for Sport clubs and activities
    LEFT JOIN (
        SELECT 
            district_id,
            COUNT(DISTINCT club_id) AS num_sport_clubs
        FROM berlin_source_data.social_clubs_activities
        WHERE club = 'sport' 
           OR leisure IN (
                'fitness_centre', 'sports_centre', 'stadium', 'pitch',
                'track', 'ice_rink', 'marina', 'dance'
            )
           OR sport IS NOT NULL
        GROUP BY district_id
    ) sc ON d.district_id = sc.district_id
);

-- 4. Revert to the original user role.
RESET ROLE;

-- Check the final table
SELECT * FROM berlin_labels.district_features;