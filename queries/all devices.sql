-- ###########################################
-- # Query to Fetch Device and Sensor Status #
-- ###########################################
SELECT 
    sensor_data.read_time AS Time,          -- Time of the data record
    sensor_data.leak_status AS Leaking,    -- Water leak status
    sensor_data.humidity_level AS Humidity, -- Humidity readings
    sensor_data.tamper_status AS Tampered, -- Tamper detection status
    sensor_data.temperature_val AS Temperature, -- Temperature readings
    device_data.installation_status AS Status, -- Installation status of the device
    sensor_data.device_identifier AS Device,   -- Unique identifier for the device
    "See Data" AS Action                      -- Static label for user actions
FROM 
    schema_name.sensor_data_table AS sensor_data
    -- Join with device details to fetch installation information
    JOIN schema_name.device_info_table AS device_data
    ON sensor_data.device_identifier = device_data.device_key
    -- Join with building metadata to fetch location-specific information
    JOIN schema_name.building_metadata_table AS building_data
    ON device_data.building_ref = building_data.building_id
WHERE
    -- ##########################################
    -- # Filters Based on Location and Status #
    -- ##########################################
    building_data.building_name IN ($building) AND   -- Filter by building names
    building_data.unit_info IN ($unit) AND           -- Filter by unit
    building_data.room_number IN ($room) AND         -- Filter by room

    -- ##########################################
    -- # Filters for Sensor and Device Status #
    -- ##########################################
    sensor_data.tamper_status IN ($tamper) AND       -- Filter by tamper status
    sensor_data.leak_status IN ($leak) AND           -- Filter by water leak status
    sensor_data.device_identifier IN ($deviceid);    -- Filter by specific device identifiers
