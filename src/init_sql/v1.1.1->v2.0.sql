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
  UNIQUE KEY `cluster_name` (`cluster_name`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE `data_masking_columns` (
  `column_id`      INT(11)       NOT NULL AUTO_INCREMENT,
  `rule_type`      INT(11)       NOT NULL,
  `active`         INT(11)       NOT NULL,
  `table_schema`   VARCHAR(64)   NOT NULL,
  `table_name`     VARCHAR(64)   NOT NULL,
  `column_name`    VARCHAR(64)   NOT NULL,
  `column_comment` VARCHAR(1024) NOT NULL,
  `create_time`    DATETIME(6)   NOT NULL,
  `sys_time`       DATETIME(6)   NOT NULL,
  `cluster_name`   VARCHAR(50)   NOT NULL,
  PRIMARY KEY (`column_id`),
  KEY `data_masking_columns_5e2a4388` (`cluster_name`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE `data_masking_rules` (
  `id`         INT(11)      NOT NULL AUTO_INCREMENT,
  `rule_type`  INT(11)      NOT NULL,
  `rule_regex` VARCHAR(255) NOT NULL,
  `hide_group` INT(11)      NOT NULL,
  `rule_desc`  VARCHAR(100) NOT NULL,
  `sys_time`   DATETIME(6)  NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rule_type` (`rule_type`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE `query_log` (
  `id`           INT(11)     NOT NULL AUTO_INCREMENT,
  `db_name`      VARCHAR(30) NOT NULL,
  `sqllog`       LONGTEXT    NOT NULL,
  `effect_row`   BIGINT(20)  NOT NULL,
  `cost_time`    VARCHAR(10) NOT NULL,
  `username`     VARCHAR(30) NOT NULL,
  `create_time`  DATETIME(6) NOT NULL,
  `sys_time`     DATETIME(6) NOT NULL,
  `cluster_name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE `query_privileges` (
  `privilege_id` INT(11)      NOT NULL AUTO_INCREMENT,
  `user_name`    VARCHAR(30)  NOT NULL,
  `db_name`      VARCHAR(200) NOT NULL,
  `table_name`   VARCHAR(200) NOT NULL,
  `valid_date`   DATE         NOT NULL,
  `limit_num`    INT(11)      NOT NULL,
  `priv_type`    INT(11)      NOT NULL,
  `is_deleted`   INT(11)      NOT NULL,
  `create_time`  DATETIME(6)  NOT NULL,
  `sys_time`     DATETIME(6)  NOT NULL,
  `cluster_name` VARCHAR(50)  NOT NULL,
  PRIMARY KEY (`privilege_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE `query_privileges_apply` (
  `apply_id`     INT(11)     NOT NULL AUTO_INCREMENT,
  `title`        VARCHAR(50) NOT NULL,
  `user_name`    VARCHAR(30) NOT NULL,
  `db_list`      LONGTEXT    NOT NULL,
  `table_list`   LONGTEXT    NOT NULL,
  `valid_date`   DATE        NOT NULL,
  `limit_num`    INT(11)     NOT NULL,
  `priv_type`    INT(11)     NOT NULL,
  `status`       INT(11)     NOT NULL,
  `create_time`  DATETIME(6) NOT NULL,
  `sys_time`     DATETIME(6) NOT NULL,
  `cluster_name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`apply_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE `sql_slave_config` (
  `id`             INT(11)      NOT NULL AUTO_INCREMENT,
  `slave_host`     VARCHAR(200) NOT NULL,
  `slave_port`     INT(11)      NOT NULL,
  `slave_user`     VARCHAR(100) NOT NULL,
  `slave_password` VARCHAR(300) NOT NULL,
  `create_time`    DATETIME(6)  NOT NULL,
  `update_time`    DATETIME(6)  NOT NULL,
  `cluster_name`   VARCHAR(50)  NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cluster_name` (`cluster_name`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE `workflow_audit` (
  `audit_id`           INT(11)      NOT NULL AUTO_INCREMENT,
  `workflow_id`        BIGINT(20)   NOT NULL,
  `workflow_type`      INT(11)      NOT NULL,
  `workflow_title`     VARCHAR(50)  NOT NULL,
  `workflow_remark`    VARCHAR(140) NOT NULL,
  `audit_users`        VARCHAR(255) NOT NULL,
  `current_audit_user` VARCHAR(20)  NOT NULL,
  `next_audit_user`    VARCHAR(20)  NOT NULL,
  `current_status`     INT(11)      NOT NULL,
  `create_user`        VARCHAR(20)  NOT NULL,
  `create_time`        DATETIME(6)  NOT NULL,
  `sys_time`           DATETIME(6)  NOT NULL,
  PRIMARY KEY (`audit_id`),
  UNIQUE KEY `workflow_audit_workflow_id_6f1fc16d742057ca_uniq` (`workflow_id`, `workflow_type`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE `workflow_audit_detail` (
  `audit_detail_id` INT(11)      NOT NULL AUTO_INCREMENT,
  `audit_user`      VARCHAR(20)  NOT NULL,
  `audit_time`      DATETIME(6)  NOT NULL,
  `audit_status`    INT(11)      NOT NULL,
  `remark`          VARCHAR(140) NOT NULL,
  `sys_time`        DATETIME(6)  NOT NULL,
  `audit_id`        INT(11)      NOT NULL,
  PRIMARY KEY (`audit_detail_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE `workflow_audit_setting` (
  `audit_setting_id` INT(11)      NOT NULL AUTO_INCREMENT,
  `workflow_type`    INT(11)      NOT NULL,
  `audit_users`      VARCHAR(255) NOT NULL,
  `create_time`      DATETIME(6)  NOT NULL,
  `sys_time`         DATETIME(6)  NOT NULL,
  PRIMARY KEY (`audit_setting_id`),
  UNIQUE KEY `workflow_type` (`workflow_type`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

ALTER TABLE `sql_master_config`
  ADD UNIQUE INDEX `cluster_name` (`cluster_name`);

ALTER TABLE `sql_workflow`
  ADD COLUMN `is_manual` INT(11) NOT NULL
  AFTER `execute_result`,
  ADD COLUMN `audit_remark` LONGTEXT NULL
  AFTER `is_manual`;
