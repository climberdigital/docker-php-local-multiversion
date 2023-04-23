# Docker dev environment with multiple PHP versions and per-project version isolation

This is a reasonably configured development environment for PHP devs, especially those familiar with Laravel and Laravel Valet.

Run multiple projects at once with specific PHP versions isolated to each project. Want site-01.test run on PHP 8.1, while the site-02.test is running on PHP 7.3? This Docker-based setup makes that process a breeze.

_**This is only for development and was not meant to be used in production!**_

## Installation

1. Make sure [Docker](https://www.docker.com/) is installed in your system.
2. Clone this repository somewhere on your machine. If you work under WSL2, clone it inside WSL.
3. The next steps will assume that you cloned it into **~/code** on your machine. But you can use any directory you'd like.
4. Create a directory named **projects** inside the **code** directory. That's where you will put your projects.
5. Inside the **server** directory, find and copy **nginx/default** directory to the same path as **config** directory: **nginx/config**. That's the Nginx config that your Nginx container will use.
6. Inside the **server/nginx** directory, created the **sites-enabled** directory. That directory will contain Nginx virtual hosts for your projects.
7. Inside the **server** directory, copy **docker-compose-template.yml** file as **docker-compose.yml**.
8. In the **docker-compose.yml**, replace the placeholder project names with your projects and follow the pattern in the comments there to add more projects. Each PHP container ("service") in docker-compose file needs to mount volumes of the projects that use its PHP version.
9. Build the containers for the first time. Docker will create the "apps" network for this environment:
    - ``` docker-compose up --build --detach ```

10. Edit your computer OS **hosts** file and add .test domains of your projects, following this pattern:
    - ``` 127.0.0.1   your-project-domain.test```

After that initial installation, you can launch the whole environment with ``` docker-compose up ``` and stop it with ``` docker-compose down ```, as you normally would with Docker containers.

This is what your whole **code** directory structure should look like when you set it all up:

![Docker PHP local multiversion](https://webrazrabotchik.ru/dist/img/docker-php-multiversion.png "Docker PHP local multiversion environment")

## Database management

This environment includes MySQL 5.7.37 and MySQL 8.0.28 as separate service containers, persisting data in separate volumes on the disk.

If you need to access either of those with an external tool, each service exposes its own port:
- **MySQL 5.7** exposes port **33057**
- **MySQL 8** exposes port **33080**

## Isolate projects with a specific version of PHP

Out of the box, this setup provides the ability to run PHP 7.3, PHP 7.4, PHP 8.0, and PHP 8.1 simultaneously — in isolated containers. That way, you can have your projects use a specific version of PHP and run Composer commands under it.

You can even duplicate a project running on one version of PHP and set it up with a different version, running both at the same time but in isolation from each other, which can be very useful if you want to upgrade the PHP version on your production server and need to test your app with it first.

## How to map projects to specific PHP versions?

Inside **server/nginx/config** directory you created, edit the **default.conf** file and put your own domain/php version pairs, following the existing pattern and the instructions in the comments in the file. After editing it, run **docker-compose down** and **docker-compose up** inside the **server** directory for changes to propagate.

## Composer

I've added Composer into the containers of each PHP version instead of setting it up as as separate service. That means you can use it in isolation with the **docker exec** command on a container of the specific PHP version, and Composer will run with that particular version, so you know that your dependencies are installed with the version of PHP that your project is using.

## Configuration

This environment is highly configurable, and you can add or remove services as you please. What I was aiming at by default is a bare-bones environment to quickly whip up and run plain PHP or Laravel projects, locally. You have Mailhog already available, but feel free to add Redis and other services to your **docker-compose.yml**, at will.

All the PHP versions are using the development configuration of php.ini, the files used are located in **server/php-config** directory, separated by versions. I've increased the default timeouts to 300 seconds and uploaded file sizes to 1G in all the configs.

## Adding or removing PHP versions

If you need to add a new PHP version, create a Dockerfile for it (name it according to the PHP version you'll use). You can follow the same pattern of the existing Dockerfiles, but make sure to check documentation of the container you want to import as there might be nuances in extension installation instructions, etc.

Also, make sure to lock the image you're building from in your Dockerfile FROM directive to a specific distro version like **alpine3.15** etc. to avoid build errors with Docker, like this:
- ``` FROM php:8.1.8RC1-fpm-alpine3.15 ```

When you're done with the new Dockerfile, add a separate service for the new version of PHP to your **docker-compose.yml**, following the same pattern of other version declarations there. Then just run **docker-compose down** and **docker-compose up --build --detach** inside the **server** directory.

If you don't need some of the existing versions, just comment out their declaration from **docker-compose.yml** or remove them completely so they don't eat up memory.

## Aliases

This project has a default aliases template for Laravel. It's there for reference, but, in order to use your own aliases, you need to create an **aliases.sh** file inside the **server** directory, add your aliases there, and rebuild the containers via the docker-compose command, then it will import your aliases file into the PHP containers.

In order for your aliases to work, you will have to run the **docker exec** command with an -l flag. Example:

``` docker exec -it php81 sh -l ```

## Reference

- [Docker Docs](https://docs.docker.com/)
- [Useful article](https://betterprogramming.pub/inside-docker-one-nginx-but-different-php-versions-based-on-your-hostname-2d4aca6654bd) by Michael Bladowski that shows a neat nginx configuration trick to run different PHP versions in parallel on a per-project basis with Docker.
