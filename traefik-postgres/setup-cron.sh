#! /bin/bash
echo 'This script will install following cronjobs for nextcloud:'
echo ''
echo '- Default Nextcloud background jobs'
echo '- Scan Nextcloud files'
echo '- Generate previews'
echo '- PostgresSQL backup and backups cleanup'
echo ''
echo 'Creating cron...'

# write out current crontab
crontab -l > temp_cron

cat cronjobs >> temp_cron

# install new cron file && remove
crontab temp_cron && rm temp_cron

echo 'Done!'
echo 'Do `crontab -l` to verify.'

