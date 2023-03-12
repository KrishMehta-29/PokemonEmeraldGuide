CREATE USER 'appadmin'@'localhost' IDENTIFIED BY 'adminpw';
CREATE USER 'appclient'@'localhost' IDENTIFIED BY 'clientpw';
-- Can add more users or refine permissions
GRANT ALL PRIVILEGES ON 121final.* TO 'appadmin'@'localhost';
GRANT SELECT ON 121final.* TO 'appclient'@'localhost';
FLUSH PRIVILEGES;
