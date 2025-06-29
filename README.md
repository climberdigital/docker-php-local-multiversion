# Docker dev environment for running multiple PHP versions in isolation, on a per-project basis

Run multiple projects at once with specific PHP versions isolated to each project. Want site-01.test run on PHP 8.1, while the site-02.test project is running PHP 8.4? This Docker-based setup makes that process a breeze. You can even easily test the same project with different PHP versions at the same time in parallel.

This is a reasonably configured development environment for PHP devs, especially those familiar with Laravel and Laravel Valet, or Laravel Herd.

_**This setup is NOT ready for production usage. Only use it as a development environment, or adapt it for prod as you see fit!**_

## Installation

1. Make sure [Docker](https://www.docker.com/) is installed in your system.
2. Clone this repository somewhere on your machine. If you work under WSL2, clone it somewhere inside WSL.
3. The next steps will assume that you cloned the repo inside **~/code** directory on your physical or virtual machine. You may change the directory name as you please, just make sure you follow the steps using the directory name of your choice.
4. Run `bash ~/code/server/setup.sh` in the command line. It will copy the defaults provided with the repository into your local gitignored directory and set everything up so you can configure your own environment without triggering the source control of the repo.

This is what your whole **~/code** directory structure should look like when you finish setting up your environment:


```
./
│   README.md
│   .gitignore
│
└───projects
│   │   ...
│   │
│   └───project-1
│       │   ...
│
└───server
    │   docker-compose.yml
    │   setup.sh
    │
    └───default
    │   │
    │   └───...
    │
    └───local
        │
        └───nginx
        │   │   default.conf
        │   │   nginx.conf
        │   │   php.conf
        │   │
        │   └───certs
        │   │   │   ...
        │   │
        │   └───sites-enabled
        │   │   │   ...
        │
        └───php
        │   │   ...

```

## Configuration

After running the **setup.sh** shell script, you should have a gitignored **~/code/server/local** directory and a **~/code/server/docker-compose.yml** file. These are set up from the predefined files in the **~/code/server/default** directory so you can speed up the configuration of your environment.

You can configure anything in **~/code/server/docker-compose.yml** file and the **~/code/server/local** directory as you please, and it won't trigger source control, as they're gitignored. But I advise you to stick to the following battle-tested algorithm:

1. Let's assume you want to run a Laravel 12 project under PHP 8.4 and a php-84-app.test custom domain name.
2. Init the project (or clone it) inside **~/code/projects/php-84-app** and set it up to working condition.
3. `cp ~/.code/server/default/nginx/virtual-host-template.conf ~/code/server/local/nginx/sites-enabled/php-84-app.test`
4. Edit the **~/code/server/local/nginx/sites-enabled/php-84-app.test** file, following the instructions inside.
5. Add a PHP service mapping to the **php-84-app.test** domain name inside **~/code/server/local/nginx/default.conf**, following the instructions inside.
6. Add your project as a volume to the **php_8_4** service in **~/code/server/docker-compose.yml**, following the instructions inside.
7. `cd ~/.code/server && docker-compose up --build --detach`
9. Append `127.0.0.1   php-84-app.test` record to your operating system's hosts file and save it with admin privilege.
8. If you've set up your Laravel project properly, it should now be available at the **php-84-app.test** domain in your browser, and it's running on PHP 8.4.

Repeat this process for any other project, considering the PHP version you want it to run with.

Add, configure, or remove services in your **~/code/server/docker-compose.yml** file as you see fit. I've set up Mailpit as a default e-mail testing service, but you can easily swap it out with Mailhog, or Redis with Valkey, etc.

_**Please note that the more services you add to your docker-compose.yml — the slower the initial build will be. With PHP 8.1, 8.2, 8.3, and 8.4 in the same build, it can easily take up to 10 minutes for the initial build to complete.**_

## Database management

This environment includes MySQL 5.7.44 and MySQL 8.4.5 as separate service containers, persisting data in separate volumes on the disk.

If you need to access either of those with an external tool, each service exposes its own port:
- **MySQL 5.7** exposes port **33057**
- **MySQL 8.4** exposes port **33080**

When using either of those in your .env, make sure you set your DB_HOST or similar variable value as the respective service name from your docker-compose.yml — e.g. mysql_5 or mysql_8, etc.

## Isolating specific versions of PHP per project

Out of the box, this setup provides the ability to run different versions of PHP in parallel — in isolated containers. That way, you can have your projects use a specific version of PHP and run Composer commands under that particular version, avoiding conflicts.

You can even run the same project on two different versions of PHP simultaneously. Just create separate project directories and clone the same code from repository to them. After that, run the configuration process mentioned above for each of these project copies, setting them up with different PHP versions, and you're good to go. It's very useful for manual testing during big upgrades, or for checking your projects and packages for version conflicts.

### How to map projects to specific PHP versions?

Inside **~/code/server/local/nginx/default.conf** put your own domain/PHP version pairs, following the existing pattern and the instructions in the comments inside the file. After editing it, run **docker-compose down** and **docker-compose up -d** from the **~/code/server** directory in order for the changes to propagate.

## Composer

I've added Composer into the containers of each PHP version instead of setting it up as as separate service. It means that you can just run it with **docker exec** command on a container with any specific PHP version, and Composer will run under that particular version of PHP, so you know that your dependencies are installed with the exact version of PHP that your project is using.

## Adding or removing PHP versions

You will find the predefined Dockerfiles and configs for different PHP versions inside **~/code/server/local/php** directory. You can pretty easily add any other version by creating a separate directory for it inside there and adding a specific Dockerfile for it along with a config file that you can get from the respective PHP version's GitHub repository.

A lot of times, you may run into build conflicts if you're using Alpine images for PHP in your Dockerfiles without locking them to a specific version of Alpine. Just make sure you build from a version-locked image of php-fpm, and you'll avoid the vast majority of build-stage issues and builds failing due to weird version conflicts. Look inside the existing Dockerfiles in this repo for reference.

When you've added a Dockerfile and a config file for another PHP version, add a separate service for it inside your **~/code/server/docker-compose.yml** file, following the same pattern of other version declarations there. Then just `cd ~/code/server`, then `docker-compose down`, and `docker-compose up --build --detach`.

If you don't need some of the existing versions, just remove their declaration from **~/code/server/docker-compose.yml** and clean out their mappings from the **~/code/server/local/nginx/default.conf** file, then rebuild the environment the same way.

## Running locally with HTTPS and self-signed SSL certificates

You can run your projects within this environment via HTTPS, but it's a bit tricky, even though it works pretty well and avoids the annoying browser SSL warning.

One (pretty stable) way to do it is to install [mkcert](https://github.com/FiloSottile/mkcert) globally in your OS (if you're on WSL, then install it on Windows, not inside WSL), or just run it from a compiled executable. Make sure it installs the local CA correctly in your OS when you first run `mkcert -install`.

When mkcert is ready to use (again, globally in the OS, in the same env as your browser operating), if you want to set up your local project with HTTPS, in your OS, run `mkcert put-your-custom-domain-here.test` and then copy/move the cert pair it creates into your dev environment's **~/code/server/local/nginx/certs** — even if you run it inside WSL2.

Then, instead of using the v-host config from **~/code/server/default/nginx/virtual-host-template.conf**, use the config from **~/code/server/default/nginx/virtual-host-https-template.conf** to set up a v-host for your local project inside **~/code/server/local/nginx/sites-enabled/** and make it work flawlessly via HTTPS with a self-signed certificate.

The fact that the certs are generated inside your OS and are signed with a local system-wide CA makes the browser recognise it and not flip out with that annoying warning for an unknown certificate. Most of the time it's all unnecessary for local dev, but some APIs require HTTPS, and you'll need it if you work with the JS clipboard API on the frontend.

## Shell aliases

I've set up default shell aliases that are added to each PHP container via their Dockerfiles, using **~/code/server/local/aliases.sh** file. You can either set up all your aliases inside that file for consistency among containers, or set up specific **aliases.sh** files in each PHP version's directory and utilize them in the version's Dockerfile. It's up to you, just don't forget to rebuild the images if you change the aliases.

In order for your aliases to work, you will have to run the **docker exec** command with -it and -l flag. Example:

``` docker exec -it php84 sh -l ```

## Reference

- [Docker Docs](https://docs.docker.com/)
- [Useful article](https://betterprogramming.pub/inside-docker-one-nginx-but-different-php-versions-based-on-your-hostname-2d4aca6654bd) by Michael Bladowski that shows a neat nginx configuration trick to dynamically run different PHP versions in parallel on a per-project basis with Docker.
