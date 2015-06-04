CREATE TABLE `billables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_date` date NOT NULL DEFAULT '0000-00-00',
  `description` varchar(255) NOT NULL DEFAULT '',
  `client_id` int(11) NOT NULL DEFAULT '0',
  `invoice_id` int(11) NOT NULL DEFAULT '0',
  `amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE billables ADD INDEX invoice_idx(client_id, created_date, invoice_id);
ALTER TABLE time_entries ADD INDEX invoice_idx(client_id, entry_date, invoice_id);