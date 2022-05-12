# Local PHP environment with Docker and PHP version isolation
When the great [Laravel Valet](https://github.com/laravel/valet) was updated to version 3, it introduced a simple and convenient way to isolate PHP versions on a per-project basis. It's a treat to work with, with only one caveat: it's only available on macOS.

The Windows, WSL, and Linux forks of Valet don't support this feature, and there seem to be no plans to change it, at least in the foreseeable future. I work on 2 machines with 3 systems: macOS, Windows, and Linux (Ubuntu). Managing different development setups on all of these is a pain, and it cripples the workflow.

So, I decided to improvise with Docker and create a portable, containerized dev environment that would at least be somewhat similar to Laravel Valet. The result is not nearly as seamless, but it's light on the resources, it's easily configurable, and it gets the job done.

## Installation

1. Make sure [Docker](https://www.docker.com/) is installed in your system.
2. Clone this repository somewhere on your machine.
3. The next steps will assume that you cloned it into **~/code** on your machine. But you can use any directory you'd like.
4. Start Nginx Proxy Manager:
    - ``` cd ~/code/nginx-proxy-manager ```
    - ``` docker-compose up -d ```
    - In your browser, go to [http://127.0.0.1:81](http://127.0.0.1:81) and follow the Nginx Proxy Manager's [quick setup instructions](https://nginxproxymanager.com/guide/#quick-setup) from step #4.
5. Create a directory called **projects**:
    - ``` mkdir ~/code/projects ```
6. Put your project files (or clone its repo) into a separate directory inside "projects" you just created.
7. Inside the "server" directory, edit **/nginx/default/nginx.conf** and replace the dummy project name and domain with whatever you need. Add separate server blocks there (if needed) for different projects, and update the mappings accordingly.
8. Set up **docker-compose.yml** from the template:
    - ``` cd ~/code/server ```
    - ``` cp docker-compose-template.yml docker-compose.yml ```

9. In the **docker-compose.yml**, replace the dummy project names with your project's info in the volume declaration of nginx service and of the PHP version service that the project will use.
10. Build the containers for the first time. Docker will create the "apps" network for this environment:
    - ``` docker-compose up --build --detach ```
11. In your browser, go to [http://127.0.0.1:81](http://127.0.0.1:81) and add a new proxy host for your project, using your machines local network IPv4 address as a destination IP and 8282 for port.
12. Edit your system **hosts** file and add your project's local .test domain that you used in the step #7 of this guide.
    - ``` 127.0.0.1   your-project-domain.test```

After that initial installation, you can run nginx-proxy-manager and the server separately with ``` docker-compose up ``` and ``` docker-compose down ```, as you normally would with Docker containers.

## Database management

This environment runs MySQL 5.7.37 and MySQL 8.0.28 as separate services containers, persisting data in separate volumes on the disk.

If you need to access either of those with an external tool, each service exposes its own port:
- **MySQL 5.7** exposes port **33057**
- **MySQL 8** exposes port **33080**

## Composer

Each PHP version runs as a separate container, and each of these containers has Composer available from inside the container, meaning that you can use it in isolation with the **docker exec** command.

## Configuration

This environment is highly configurable, and you can add or remove services as you please. What I was aiming at by default is a bare-bones environment to quickly whip up and run plain PHP or Laravel projects, locally. Feel free to add Redis, Mailhog, etc. to your **docker-compose.yml** if you need it.

## Reference

- [Docker Docs](https://docs.docker.com/)
- [Useful article](https://betterprogramming.pub/inside-docker-one-nginx-but-different-php-versions-based-on-your-hostname-2d4aca6654bd) by Michael Bladowski that shows a neat nginx configuration trick to run different PHP versions in parallel on a per-project basis with Docker.
