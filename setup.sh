#!/bin/sh
#Elastic2.2.1
#Logstash 2.2
#kibana3.1.3
#Nginx reverse proxy kibana to port 80


sudo -E apt-get update && sudo apt-get upgrade -y

wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/logstash/2.2/debian stable main" | sudo tee -a /etc/apt/sources.list
echo 'deb http://packages.elastic.co/elasticsearch/2.x/debian stable main' | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
#echo 'deb http://packages.elastic.co/kibana/4.4/debian stable main' | sudo tee -a /etc/apt/sources.list.d/kibana-4.4.x.list


sudo -E add-apt-repository -y ppa:webupd8team/java

sudo -E apt-get update && sudo -E apt-get -y install oracle-java8-installer elasticsearch logstash nginx apache2-utils curl cifs-utils git

sudo echo 'network.host: localhost' >> /etc/elasticsearch/elasticsearch.yml
#sudo echo 'server.host: "localhost"' >> /opt/kibana/config/kibana.yml

sudo update-rc.d elasticsearch defaults 95 10
#sudo update-rc.d kibana defaults 96 9
sudo service elasticsearch restart
#sudo service kibana start
#sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.old
cd /usr/share/nginx/html

wget https://download.elasticsearch.org/kibana/kibana/kibana-3.1.1.tar.gz
tar zxvf kibana-*
rm kibana-*.tar.gz
mv kibana-* kibana

service nginx restart

# sudo echo 'server {' > /etc/nginx/sites-available/default
# sudo echo '      listen 80; ' >> /etc/nginx/sites-available/default
# sudo echo '      server_name example.com;' >> /etc/nginx/sites-available/default
# sudo echo '      location / {' >> /etc/nginx/sites-available/default
# sudo echo '          proxy_pass http://localhost:5601;' >> /etc/nginx/sites-available/default
# sudo echo '          proxy_http_version 1.1;' >> /etc/nginx/sites-available/default
# sudo echo '          proxy_set_header        Host $host;' >> /etc/nginx/sites-available/default
# sudo echo '          proxy_set_header        Referer "";' >> /etc/nginx/sites-available/default
# sudo echo '          proxy_set_header        X-Real-IP $remote_addr;' >> /etc/nginx/sites-available/default
# sudo echo '          proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;' >> /etc/nginx/sites-available/default
# sudo echo '              }' >> /etc/nginx/sites-available/default
# sudo echo '      }' >> /etc/nginx/sites-available/default

sudo mkdir /usr/local/logstash-plaso
cd /usr/local
git clone https://github.com/iandday/FELK.git
sudo ln -s /usr/local/FELK/plasol2tcsv.conf /etc/logstash/conf.d/plasol2tcsv.conf

sudo service nginx restart
sudo service logstash restart


echo "Install complete, ingestion folder located at /usr/local/logstash-plaso"
echo "  Create a subdirectory with the casename and place relevant Plaso CSV files inside to be ingested"
echo "  All records will be tagged with the case directory name as well as the CSV filename"
