
ActiveRecord::Base.connection.execute <<EOF
    CREATE TABLE IF NOT EXISTS `record_checks` (
      `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
      `person_id` BIGINT(20) NOT NULL,
      `outcome` VARCHAR(255),
      `created_at`  TIMESTAMP NOT NULL,
      PRIMARY KEY (`id`),
      UNIQUE INDEX `id_UNIQUE` (`id` ASC));
EOF

