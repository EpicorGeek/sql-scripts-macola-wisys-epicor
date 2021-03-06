--Need to run?
SELECT COUNT(*) FROM sycdefil_Sql WHERE cd_type = 'V'
SELECT COUNT(*) FROM wspikpakmap WHERE carrier_cd = 'FED'
SELECT * FROM wspikpakmap WHERE Domestic_id IS null

--Run updates
UPDATE dbo.wsPikPakMap
SET cd_type = 'V', Domestic_id = 6, International_id = 12, ServiceType =4
WHERE carrier_cd = 'UPS'

UPDATE dbo.wsPikPakMap
SET cd_type = 'V', Domestic_id = 21, International_id = 30, ServiceType =4
WHERE carrier_cd = 'FED'

--Run inserts 
INSERT INTO wspikpakmap 
SELECT 'FED', 'V', sy_code, 21, 30, NULL, 4
FROM sycdefil_Sql
WHERE cd_type = 'V' AND sy_code NOT IN (SELECT sy_code FROM wspikpakmap WHERE carrier_cd = 'FED')

INSERT INTO wspikpakmap 
SELECT 'UPS', 'V', sy_code, 6, 12, NULL, 4
FROM sycdefil_Sql
WHERE cd_type = 'V' AND sy_code NOT IN (SELECT sy_code FROM wspikpakmap WHERE carrier_cd = 'UPS')
