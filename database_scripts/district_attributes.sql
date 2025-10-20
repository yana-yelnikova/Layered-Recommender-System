-- First, drop the table if it already exists to avoid errors on re-run
DROP TABLE IF EXISTS berlin_source_data.district_attributes_test;

-- Create the new table 'district_attributes' based on the result of a complex query
CREATE TABLE berlin_source_data.district_attributes_test AS (
    -- Use a CTE (Common Table Expression) for readability
    WITH district_areas AS (
        SELECT
            d.district_id,
            -- Transform the geometry to a metric system (EPSG:25833 for Berlin)
            -- and calculate the area in square meters using PostGIS
            ST_Area(ST_Transform(geometry, 25833)) / 1000000 AS area_sq_km,
            -- Join with population data from regional_statistics
            r.inhabitants
        FROM
            berlin_source_data.districts d
        LEFT JOIN
            berlin_source_data.regional_statistics r
        ON
            d.district_id = r.district_id 
   -- select the most recent year from the available data
        WHERE
            r.year = (
        SELECT MAX(year)
        FROM berlin_source_data.regional_statistics
    )
    )
    -- Now, select from our temporary set and calculate the coefficients
    SELECT
        district_id,
        area_sq_km,
        inhabitants,
        -- Use a window function AVG() OVER () to calculate the average value
        -- across all rows and immediately compute the coefficient for each row
        area_sq_km / (AVG(area_sq_km) OVER ()) AS area_coefficient,
        inhabitants / (AVG(inhabitants) OVER ()) AS population_coefficient
    FROM
        district_areas
);

-- Add a foreign key constraint to ensure data integrity.
-- This creates a formal link to the main 'districts' table,
-- guaranteeing that every 'district_id' in this table must also exist in the 'districts' table.
ALTER TABLE berlin_source_data.district_attributes
ADD CONSTRAINT fk_district
FOREIGN KEY (district_id)
REFERENCES berlin_source_data.districts (district_id);

-- Check that the table was created successfully
SELECT * FROM berlin_source_data.district_attributes_test;
