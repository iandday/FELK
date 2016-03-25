#!/bin/sh
#Configure a Ubuntu 14.04 LTS server as an ELK stack for forensicating with plaso
#Will install and configure:
#    Elasticsearch 1.2.4
#    Logstash 2.2.2-1
#    Kibana 3.1.0
#    Nginx 

esURL="https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.2.4.deb"
kibanaURL="https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz"
logstashURL="https://download.elastic.co/logstash/logstash/packages/debian/logstash_2.2.2-1_all.deb"
ip=$(ip -f inet -o addr show eth0|cut -d\  -f 7 | cut -d/ -f 1)

sudo apt-get update && sudo apt-get install -y default-jre-headless git-core nginx

cd /tmp 
wget $esURL 
dpkg -i elastic*.deb
update-rc.d elasticsearch defaults 95 10
sudo /etc/init.d/elasticsearch restart
cd /usr/share/elasticsearch/bin
./plugin install royrusso/elasticsearch-HQ
rm /tmp/elasticsearch-1.2.4.deb

cd /usr/share/nginx/html
rm index.html
wget $kibanaURL
tar xzf kibana-3.1.0.tar.gz -C /usr/share/nginx/html --strip 1
rm kibana-3.1.0.tar.gz

cd /tmp
wget $logstashURL
dpkg -i logstash*.deb
rm logstash*.deb
sudo service logstash start

cd ~/
git clone https://github.com/iandday/FELK
cd FELK
sudo cp plasol2tcsv.conf /etc/logstash/conf.d/
sudo cp plasol2tcsv.json /usr/share/nginx/html/app/dashboards/plasol2tcsv.json
sudo service logstash restart

echo "Installation complete"
echo ""
echo "Elasticsearch HQ Dashboard accessible at http://$ip:9200/_plugin/HQ/"
echo "Kibana interface accessible at http://$ip"
echo "Plaso l2tcsv dashboard accessible at http://$ip/index.html#/dashboard/file/plasol2tcsv.json"
echo "  Load l2tcsv file for viewing by substituting file name in the below command:"
echo "    cat timeline.csv | nc 127.0.0.1 18005"
