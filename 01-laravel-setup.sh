#!/bin/sh

# Laravelプロジェクト名/DB名
PROJECT=laravelapp
# DB Password
PASSWORD=P@ssw0rd

# Laravelプロジェクトを作成
docker exec -it laravel composer create-project "laravel/laravel=6.0.*" $PROJECT
docker exec -it laravel /bin/bash -c "cd /var/www/html/$PROJECT; chmod -R 777 ./storage; chmod -R 777 ./bootstrap/cache/"

# httpd.confをバックアップ後、Document Rootなどを書き換え
cp ./apache-php/httpd.conf ./apache-php/httpd.conf.bk
sed -i -e "s/DocumentRoot \"\(.*\)\"/DocumentRoot \"\/var\/www\/html\/$PROJECT\/public\"/g" ./apache-php/httpd.conf
sed -i -e "s/\<Directory \"\/var\/www\/html\">/\<Directory \"\/var\/www\/html\/$PROJECT\/public\"\>/g" ./apache-php/httpd.conf
sed -i -e "s/AllowOverride None/AllowOverride All/" ./apache-php/httpd.conf

# .envのDB設定を書き換え
docker exec -it laravel /bin/bash -c "cd /var/www/html/$PROJECT; sed -i -e \"s/DB_HOST=\(.*\)/DB_HOST=mysql/g\" .env"
docker exec -it laravel /bin/bash -c "cd /var/www/html/$PROJECT; sed -i -e \"s/DB_DATABASE=\(.*\)/DB_DATABASE=$PROJECT/g\" .env"
docker exec -it laravel /bin/bash -c "cd /var/www/html/$PROJECT; sed -i -e \"s/DB_PASSWORD=\(.*\)/DB_PASSWORD=$PASSWORD/g\" .env"

# Laravel Migrate実行
docker exec -it laravel /bin/bash -c "cd /var/www/html/$PROJECT; php artisan migrate"

# Laravelコンテナの再起動
docker restart laravel