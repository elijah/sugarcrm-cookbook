name             "sugarcrm"
maintainer       "Wyatt Walter"
maintainer_email "wwalter@sugarcrm.com"
license          "Apache 2.0"
description      "Installs/Configures SugarCRM CE"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1.3"
depends          "php"
depends          "apache2"
depends          "mysql"
depends          "openssl"
depends          "git"
depends           "database"
depends 'mysql2_chef_gem', '~> 1.0'
