#!/bin/bash
##
## instruction
## 
## https://devcenter.heroku.com/articles/django
##

PROJECT_NAME="$1"

virtualenv --no-site-packages .
source bin/activate
bin/pip install django==1.3
env ARCHFLAGS="-arch i386 -arch x86_64" bin/pip install psycopg2
bin/pip install gunicorn
bin/pip freeze > requirements.txt
bin/django-admin.py startproject ${PROJECT_NAME}
cat <<EOT | bin/python - ${PROJECT_NAME}/settings.py > tmpsettings.py
import sys,re

for line in open(sys.argv[1]):
    line=re.sub(r'^INSTALLED_APPS = \(','INSTALLED_APPS = (\n    \'gunicorn\',',line)
    line=re.sub(r'^TIME_ZONE = \'America/Chicago\'','TIME_ZONE = \'Asia/Tokyo\'',line)
    line=re.sub(r'^LANGUAGE_CODE = \'en-us\'','LANGUAGE_CODE = \'ja\'',line)
    sys.stdout.write(line)
EOT
mv -f tmpsettings.py ${PROJECT_NAME}/settings.py
echo "web: python ${PROJECT_NAME}/manage.py run_gunicorn -b 0.0.0.0:\$PORT" >Procfile
cat <<EOT >.gitignore
bin/
include/
lib/
build/
*.pyc
*.swp
.Python
EOT
git init
git add .
git commit -m 'initial import'

heroku create --stack cedar
git push heroku master

echo 'welcome to heroku'
echo 'to open your app...'
echo '$ heroku open'

## useful commands
# $ git remote show heroku
# $ heroku logs
# $ heroku ps
# $ heroku open
