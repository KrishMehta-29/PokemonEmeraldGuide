CREATE USER 'appadmin'@'localhost' IDENTIFIED BY 'adminpw';
CREATE USER 'appclient'@'localhost' IDENTIFIED BY 'clientpw';
-- Can add more users or refine permissions
GRANT ALL PRIVILEGES ON final.* TO 'appadmin'@'localhost';
GRANT SELECT ON final.* TO 'appclient'@'localhost';
GRANT INSERT ON final.pc TO 'appclient'@'localhost';
GRANT UPDATE ON final.player TO 'appclient'@'localhost';
GRANT EXECUTE ON final.* TO 'appclient'@'localhost';

FLUSH PRIVILEGES;
