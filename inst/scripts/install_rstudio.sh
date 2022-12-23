sudo apt-get -y install gdebi-core
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2022.12.0-353-amd64.deb
sudo gdebi -n rstudio-server-2022.12.0-353-amd64.deb
rm rstudio*.deb
