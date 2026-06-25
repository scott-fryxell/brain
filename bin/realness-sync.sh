#!/usr/bin/env bash

# reset development repo with production
gsutil -m -o GSUtil:parallel_process_count=1 rm -r gs://realness-development.appspot.com/people
gsutil -m -o GSUtil:parallel_process_count=1 cp -R gs://realness-online.appspot.com/people/ gs://realness-development.appspot.com/

# reset on Desktop
# rm -rf ~/Desktop/realness.online
# mkdir ~/Desktop/realness.online
# mkdir ~/Desktop/realness.online/people
# gsutil -m -o GSUtil:parallel_process_count=1 cp -R gs://realness-online.appspot.com/people ~/Desktop/realness.online/
# gsutil -m -o GSUtil:parallel_process_count=1 cp -R gs://realness-.appspot.com/people ~/Desktop/realness.online/

# just copy my directory
# gsutil -m -o GSUtil:parallel_process_count=1 cp -R gs://realness-online.appspot.com/people/+16282281824 ~/Desktop/realness.online/people/

# copy to production from home directory
# gsutil -m -o GSUtil:parallel_process_count=1 rm -r gs://realness-online.appspot.com/people
# gsutil -m -o GSUtil:parallel_process_count=1 cp -R ~/Desktop/realness.online/people/ gs://realness-online.appspot.com/

# copy to development from home directory
# gsutil -m -o GSUtil:parallel_process_count=1 rm -r gs://realness-development.appspot.com/people
# gsutil -m -o GSUtil:parallel_process_count=1 cp -R ~/Desktop/realness.online/people gs://realness-development.appspot.com/

# reset just me
# gsutil -m rm -r gs://realness-development.appspot.com/people/+16282281824
# gsutil -m cp -R gs://realness-online.appspot.com/people/+16282281824 gs://realness-development.appspot.com/people

# copy my development posters to production
# gsutil -m -o GSUtil:parallel_process_count=1 cp -R gs://realness-development.appspot.com/people/+16282281824/posters gs://realness-online.appspot.com/people/+16282281824
# gsutil -m -o GSUtil:parallel_process_count=1 cp -R gs://realness-development.appspot.com/people/+16282281824/avatars gs://realness-online.appspot.com/people/+16282281824

# gsutil -m -o GSUtil:parallel_process_count=1 cp -R gs://seeq-production.appspot.com/codi/ gs://seeq-staging.appspot.com/
