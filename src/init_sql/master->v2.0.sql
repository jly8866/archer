CREATE TABLE `aliyun_access_key` (
  `id`        INT(11)      NOT NULL AUTO_INCREMENT,
  `ak`        VARCHAR(50)  NOT NULL,
  `secret`    VARCHAR(100) NOT NULL,
  `is_enable` INT(11)      NOT NULL,
  `remark`    VARCHAR(50)  NOT NULL,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE `aliyun_rds_config` (
  `id`               INT(11)      NOT NULL AUTO_INCREMENT,
  `rds_dbinstanceid` VARCHAR(100) NOT NULL,
  `cluster_name`     VARCHAR(50)  NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_cluster_name` (`cluster_name`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

ALTER TABLE `data_masking_columns`
  DROP COLUMN `cluster_id`,
  ADD INDEX `idx_cluster_name` (`cluster_name`);

ALTER TABLE `data_masking_rules`
  ADD COLUMN `hide_group` INT(11) NOT NULL
  AFTER `rule_regex`,
  ADD UNIQUE INDEX `uniq_rule_type` (`rule_type`);

ALTER TABLE `query_log`
  DROP COLUMN `cluster_id`;

ALTER TABLE `query_privileges`
  ADD COLUMN `priv_type` INT(11) NOT NULL
  AFTER `limit_num`,
  DROP COLUMN `cluster_id`,
  MODIFY COLUMN `valid_date` DATE NOT NULL
  AFTER `table_name`;

ALTER TABLE `query_privileges_apply`
  ADD COLUMN `db_list` LONGTEXT NOT NULL
  AFTER `user_name`,
  ADD COLUMN `priv_type` INT(11) NOT NULL
  AFTER `limit_num`,
  DROP COLUMN `cluster_id`,
  DROP COLUMN `db_name`,
  MODIFY COLUMN `valid_date` DATE NOT NULL
  AFTER `table_list`;

ALTER TABLE `sql_master_config`
  ADD UNIQUE INDEX `uniq_cluster_name` (`cluster_name`);

ALTER TABLE `sql_slave_config`
  DROP COLUMN `cluster_id`,
  ADD UNIQUE INDEX `uniq_cluster_name` (`cluster_name`);

ALTER TABLE `sql_workflow`
  ADD COLUMN `is_manual` INT(11) NOT NULL
  AFTER `execute_result`,
  ADD COLUMN `audit_remark` LONGTEXT NULL
  AFTER `is_manual`;

ALTER TABLE `workflow_audit`
  ADD UNIQUE INDEX `idx_workflow_id_type` (`workflow_id`, `workflow_type`);

ALTER TABLE `workflow_audit_setting`
  ADD UNIQUE INDEX `uniq_workflow_type` (`workflow_type`);
