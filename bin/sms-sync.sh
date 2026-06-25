#!/usr/bin/env bash

# gsutil -m -o GSUtil:parallel_process_count=1 cp -R gs://seeq-production.appspot.com/models/BERT_Anger_150_ven/ ~/GitHub/sms/modelsppspot.com/models/BERT_Anger_150_ven/ ~/GitHub/sms

# gsutil -m -o GSUtil:parallel_process_count=1 cp -R gs://seeq-production.appspot.com/models2/ ~/GitHub/sms

# Copy local to network
# gsutil -m -o GSUtil:parallel_process_count=2 cp -R ~/Github/sms/models gs://seeq-sms.firebasestorage.app

# gs://seeq-sms.firebasestorage.app
# gsutil -m -o GSUtil:parallel_process_count=1 cp -R gs://seeq-production.appspot.com/models/BERT_Anger_150_ven/ ~/
# gsutil -m -o GSUtil:parallel_process_count=1 cp -R gs://seeq-production.appspot.com/codi ~/Desktop
gsutil -m -o GSUtil:parallel_process_count=1 cp -R gs://seeq-production.firebasestorage.app/seeq gs://seeq-staging.firebasestorage.app/

# gsutil -m -o GSUtil:parallel_process_count=1 cp -R ~/GitHub/sms/seeq-storage gs://seeq-staging.firebasestorage.app/codi
