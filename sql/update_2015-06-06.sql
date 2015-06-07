CREATE TABLE `projects` ( 
    `id` INT NOT NULL AUTO_INCREMENT , 
    `name` VARCHAR(255) NOT NULL DEFAULT '' , 
    `status` TINYINT(1) NOT NULL DEFAULT '0' , 
    `client_id` INT NOT NULL DEFAULT '0' , 
    `created_date` DATE NOT NULL DEFAULT '0000-00-00' , 
    `due_date` DATE NOT NULL DEFAULT '0000-00-00' , 
    `detail` TEXT NOT NULL , 
    PRIMARY KEY (`id`) 
) ENGINE = InnoDB;

CREATE TABLE `tasks` ( 
    `id` INT NOT NULL AUTO_INCREMENT , 
    `project_id` INT NOT NULL DEFAULT '0' , 
    `name` VARCHAR(255) NOT NULL DEFAULT '' , 
    `status` TINYINT(1) NOT NULL DEFAULT '0' , 
    `created_date` DATE NOT NULL DEFAULT '0000-00-00' , 
    `due_date` DATE NOT NULL DEFAULT '0000-00-00' , 
    `detail` TEXT NOT NULL , 
    PRIMARY KEY (`id`),
    KEY project_id_idx(project_id)
) ENGINE = InnoDB;