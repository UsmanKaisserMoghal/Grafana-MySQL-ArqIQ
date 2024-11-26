-- #####################################
-- # Temporary Filtered Data Selection #
-- #####################################
WITH filtered_data AS (
    SELECT 
        data_col1 AS read_time, 
        data_col2 AS device_id, 
        data_col3 AS temperature, 
        data_col4 AS humidity, 
        data_col5 AS tamper_status, 
        data_col6 AS leak_status, 
        data_col7 AS button_status
    FROM schema_name.data_table AS main_data
    -- Join device details and building metadata
    JOIN schema_name.device_details AS dev ON main_data.data_col2 = dev.device_key
    JOIN schema_name.buildings_info AS bld ON dev.building_ref = bld.building_id
    -- Filter data based on building-specific parameters
    WHERE bld.building_name IN ($building) 
        AND bld.unit_info IN ($unit)
        AND bld.room_number IN ($room)
        AND dev.installation_status IN ($installed)
        -- Filter data within the specified time range
        AND main_data.data_col1 BETWEEN $__timeFrom() AND $__timeTo()
)

-- ################################################
-- # Data Extraction for Alert Type: Temperature #
-- ################################################
SELECT 
    read_time, 
    'Temperature' AS alert_type, 
    temperature AS value
FROM filtered_data
-- Check if temperature exceeds the configured threshold
WHERE temperature > (
    SELECT temp_threshold 
    FROM schema_name.alert_config_table
)

-- ################################################
-- # Data Extraction for Alert Type: Humidity #
-- ################################################
UNION ALL
SELECT 
    read_time, 
    'Humidity' AS alert_type, 
    humidity AS value
FROM filtered_data
-- Check if humidity exceeds the configured threshold
WHERE humidity > (
    SELECT hum_threshold 
    FROM schema_name.alert_config_table
)

-- #################################################
-- # Data Extraction for Alert Type: Tampered #
-- #################################################
UNION ALL
SELECT 
    read_time, 
    'Tampered' AS alert_type, 
    -1 AS value
FROM filtered_data
-- Include entries where tampering is detected
WHERE tamper_status = 1

-- ################################################
-- # Data Extraction for Alert Type: Leaking #
-- ################################################
UNION ALL
SELECT 
    read_time, 
    'Leaking' AS alert_type, 
    -2 AS value
FROM filtered_data
-- Include entries where water leak is detected
WHERE leak_status = 1

-- ###########################################################
-- # Data Extraction for Alert Type: Button Pressed Events #
-- ###########################################################
UNION ALL
SELECT 
    read_time, 
    'Button_Pressed' AS alert_type, 
    -3 AS value
FROM filtered_data
-- Include entries where a button press event is detected
WHERE button_status = 1;
