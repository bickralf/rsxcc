CREATE DATABASE IF NOT EXISTS prosody DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;

CREATE USER 'chatadmin'@'localhost' IDENTIFIED BY 'S3cretStuff';

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX ON prosody.* TO 'chatadmin'@'localhost';

