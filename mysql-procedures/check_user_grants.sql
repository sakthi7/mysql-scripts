DROP PROCEDURE IF EXISTS report_user_object_privs;
DELIMITER $$

CREATE PROCEDURE report_user_object_privs(
    IN p_user VARCHAR(255),
    IN p_host VARCHAR(255)
)
BEGIN
  /*
    Reports:
      - Schema-level privileges (SCHEMA)
      - Table-level privileges (TABLE)
    Accepts specific user + host pair such as:
      CALL report_user_object_privs('t1', 'localhost');
      CALL report_user_object_privs('t1', '%');

    'table' column for SCHEMA will be 'ALL'
  */

  -- GRANTEE format:  'user'@'host'
  SET @grantee := CONCAT("'", p_user, "'@'", p_host, "'");

  WITH
  db_privs AS (
    SELECT
      'SCHEMA' AS scope,
      sp.TABLE_SCHEMA AS `database`,
      'ALL' AS `table`,
      GROUP_CONCAT(DISTINCT sp.PRIVILEGE_TYPE 
                   ORDER BY sp.PRIVILEGE_TYPE SEPARATOR ', ') AS privileges
    FROM information_schema.SCHEMA_PRIVILEGES sp
    WHERE sp.GRANTEE = @grantee
    GROUP BY sp.TABLE_SCHEMA
  ),

  tbl_privs AS (
    SELECT
      'TABLE' AS scope,
      tp.TABLE_SCHEMA AS `database`,
      tp.TABLE_NAME   AS `table`,
      GROUP_CONCAT(DISTINCT tp.PRIVILEGE_TYPE
                   ORDER BY tp.PRIVILEGE_TYPE SEPARATOR ', ') AS privileges
    FROM information_schema.TABLE_PRIVILEGES tp
    WHERE tp.GRANTEE = @grantee
    GROUP BY tp.TABLE_SCHEMA, tp.TABLE_NAME
  )

  SELECT scope, `database`, `table`, privileges
  FROM db_privs

  UNION ALL

  SELECT scope, `database`, `table`, privileges
  FROM tbl_privs

  ORDER BY scope, `database`, `table`;

END $$

DELIMITER ;

