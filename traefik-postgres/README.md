# Nextcloud setup

To setup nextcloud with this configuration, you will have to also install the `kb-tpl-docker-traefik` project available [here](https://github.com/tmssd/kb-tpl-docker-traefik).

## Folder structure

```
app/
backups/
.env
docker-compose.yml
Dockerfile
```

## Environment

Duplicate the `.env.template` and rename it to `.env`
In the `.env` file, add below information.

```
NEXTCLOUD_ROOT=<DIRECTORY>/app
SUB_DOMAIN=
DOMAIN_NAME=
POSTGRES_PASSWORD=
REDIS_PASSWORD=
TRUSTED_PROXIES=
```

For `NEXTCLOUD_ROOT`, navigate to your desired folder, and type `pwd` to know its absolute path. Any path will do, as an example, `/home/nextcloud` or `/root/nextcloud` will both work. For the passwords, generate strong passwords.

`SUB_DOMAIN` is the sub-domain used, i.e. `cloud`
`DOMAIN_NAME` is the domain used, i.e. `example.com`

`TRUSTED_PROXIES`, for this I used the subnet from the `web` network that we created in the [kb-tpl-docker-traefik](https://github.com/tmssd/kb-tpl-docker-traefik) container. For this, run `docker network inspect web` and get the value under `Subnet`.

## Build the image & start the containers

Before running the container, make sure the external network `web` has been created and the `kb-tpl-docker-traefik` container is running (see [kb-tpl-docker-traefik documentation here](https://github.com/tmssd/kb-tpl-docker-traefik)).

Builds the containers from the `docker-compose.yml` and `Dockerfile`
Always run these commands from the main folder that contains your `docker-compose.yml` file

```
docker-compose build
docker-compose up -d
```

## Post-installation steps

1. Copy `backups` folder from the parent directory

2. Go to your nexcloud domain in your browser and set up an admin account. NOTE: username **must be** a _admin_, ohterwise an "PostgreSQL username and/or password not valid You need to enter details of an existing account." error will be displayed.

3. Modify config.php file

    Add these values to the `/var/www/html/config/config.php`

    ```
    'enable_previews' => true,
    'enabledPreviewProviders' =>
    array (
      0 => 'OC\\Preview\\TXT',
      1 => 'OC\\Preview\\MarkDown',
      2 => 'OC\\Preview\\OpenDocument',
      3 => 'OC\\Preview\\PDF',
      4 => 'OC\\Preview\\MSOffice2003',
      5 => 'OC\\Preview\\MSOfficeDoc',
      6 => 'OC\\Preview\\PDF',
      7 => 'OC\\Preview\\Image',
      8 => 'OC\\Preview\\Photoshop',
      9 => 'OC\\Preview\\TIFF',
      10 => 'OC\\Preview\\SVG',
      11 => 'OC\\Preview\\Font',
      12 => 'OC\\Preview\\MP3',
      13 => 'OC\\Preview\\Movie',
      14 => 'OC\\Preview\\MKV',
      15 => 'OC\\Preview\\MP4',
      16 => 'OC\\Preview\\AVI',
    ),
    'preview_max_x' => '512',
    'preview_max_y' => '512',
    'jpeg_quality' => '60',
    ```

4. Modify thumbnail sizes

    Default sizes for `previewgenerator` are ok but they're going to take space over time, so I changed their default size. It's also improving the gallery performance overall.

    ```
    docker exec -it nextcloud sudo -u www-data php -d memory_limit=-1 /var/www/html/occ config:app:set --value="32 256" previewgenerator squareSizes
    ```

    ```
    docker exec -it nextcloud sudo -u www-data php -d memory_limit=-1 /var/www/html/occ config:app:set --value="256 384" previewgenerator widthSizes
    ```

    ```
    docker exec -it nextcloud sudo -u www-data php -d memory_limit=-1 /var/www/html/occ config:app:set --value="256" previewgenerator heightSizes
    ```

    If you want to regenerate all previews after some time, delete the `/var/www/html/data/appdata_xxxxx/preview` folder, then run this command so that nextcloud knows they've been deleted.

    ```
    docker exec -it nextcloud sudo -u www-data php -d memory_limit=-1 /var/www/html/occ files:scan-app-data
    ```

    Then regenerate all the previews.

    ```
    docker exec -it nextcloud sudo -u www-data php -d memory_limit=-1 /var/www/html/occ preview:generate-all -vvv
    ```

## Tips

Entering the shell of the running _nextcloud_ container:

    docker exec -it nextcloud /bin/bash

Editing Nextcloud config file:

    docker exec -it nextcloud /bin/bash
    vim /var/www/html/config/config.php

Restarting _nextcloud's_ container apache2 service:

    docker exec -it nextcloud /bin/bash
    service apache2 restart

  or

    docker exec -it nextcloud /bin/bash service apache2 restart

Toggling Nextcloud maintenance mode:

    docker exec -it --user www-data nextcloud php occ maintenance:mode --on
    docker exec -it --user www-data nextcloud php occ maintenance:mode --off

Setting `default_phone_region` with the respective [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements) code of the region to allow numbers without a country code:

    docker-compose exec --user www-data nextcloud php occ config:system:set default_phone_region --value="US"

Restarting the _nextcloud_ container:

    docker-compose restart nextcloud

See _nextcloud_ container logs in real time:

    docker logs -f nextcloud
