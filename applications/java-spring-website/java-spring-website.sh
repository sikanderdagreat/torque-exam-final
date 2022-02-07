#!/usr/bin/env bash

# Stop Script on Error
set -e

# For Debugging (print env. variables into a file)  
printenv > /var/log/torque-vars-"$(basename "$BASH_SOURCE" .sh)".txt

# Update packages and Upgrade system
echo "****************************************************************"
echo "Updating System"
echo "****************************************************************"
apt-get update -y


echo "****************************************************************"
echo "Installing Java"
echo "****************************************************************"
apt-get install default-jdk -y



echo "****************************************************************"
echo "Installing Tomcat"
echo "****************************************************************"
apt-get install tomcat8 -y
apt-get install tomcat8-admin -y


echo "****************************************************************"
echo "Get the web application from github"
echo "****************************************************************"
mkdir /home/artifacts
cd /home/artifacts || exit

git clone https://github.com/QualiTorque/sample_java_spring_source.git


echo "****************************************************************"
echo "Prepare the environment configuration file that will be consumed by the servlet"
echo "****************************************************************"
mkdir /home/user/.config/torque-java-spring-sample -p

jdbc_url=jdbc:mysql://$DB_HOSTNAME/$DB_NAME
if [ "$USE_SSL" = true ]; then
    jdbc_url="${jdbc_url}?useSSL=true"
fi

bash -c "cat >> /home/user/.config/torque-java-spring-sample/app.properties" <<EOL
# Dadabase connection settings:
jdbc.url=$jdbc_url
jdbc.username=$DB_USER
jdbc.password=$DB_PASS
EOL

echo "****************************************************************"
echo "Deploy to TomCat"
echo "****************************************************************"
#remove the tomcat default ROOT web application
rm -rf /var/lib/tomcat8/webapps/ROOT

# deploy the application as the ROOT web application
cp sample_java_spring_source/artifacts/torque-java-spring-sample-1.0.0-BUILD-SNAPSHOT.war /var/lib/tomcat8/webapps/ROOT.war

systemctl start tomcat8
