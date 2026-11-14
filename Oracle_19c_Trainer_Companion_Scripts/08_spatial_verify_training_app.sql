-- READ-ONLY | TRAINING_APP, after spatial setup.
SELECT table_name,column_name,srid FROM user_sdo_geom_metadata
WHERE table_name='TRAINING_SITES';
SELECT t.site_name,t.location.sdo_gtype AS gtype,
       t.location.sdo_srid AS srid,
       t.location.sdo_point.x AS longitude,
       t.location.sdo_point.y AS latitude
FROM training_sites t ORDER BY t.site_id;
SELECT index_name,status,ityp_owner,ityp_name FROM user_indexes
WHERE table_name='TRAINING_SITES';
-- Optional proximity predicate requires correct spatial index, SRID and Oracle Spatial feature availability.
