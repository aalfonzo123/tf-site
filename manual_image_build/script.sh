sudo apt update
sudo apt-get install apache2 php libapache2-mod-php php-mysql -y

sudo bash
echo "Page from <?php echo gethostname() ?>
" > /var/www/html/index.php

rm /var/www/html/index.html

curl localhost

# stop
# edit > boot disk > create image