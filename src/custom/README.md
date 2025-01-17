# Custom Services

This directory is specifically designated for adding any services that your project may require. Services such as `MySQL`, `Redis`, or any other dependencies can be added here based on your project's specific needs. `laradock` is pre-configured to read Docker Compose files that follow a specific naming convention. These files must end with the `.docker-compose.yml` extension to be recognized and processed correctly.

## 🚀 Example: Creating a MySQL Service

If you are setting up a MySQL service, you will need to create a Docker Compose file specifically for it. The file should be named `mysql.docker-compose.yml` to adhere to the naming convention. Below is an example of how such a Docker Compose file might be structured:

```yml
volumes:
  db:
    name: ${MAIN_NAME:-laradock}.${MAIN_PROJECT_NAME:-laravel}.mysql

networks:
  default:
    name: ${MAIN_NAME:-laradock}.${MAIN_PROJECT_NAME:-laravel}
    driver: bridge

services:
  db:
    image: ${MAIN_NAME:-laradock}.${MAIN_IMAGE_NAME:-laravel}.db:latest
    container_name: ${MAIN_NAME:-laradock}.${MAIN_PROJECT_NAME:-laravel}.db
    build:
      context: ./custom
      dockerfile: ./mysql/Dockerfile
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-laradock}
      - MYSQL_USER=${MYSQL_USERNAME:-laradock}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD:-laradock}
      - MYSQL_DATABASE=${MYSQL_DATABASE:-laradock}
    volumes:
      - type: volume
        source: db
        target: /var/lib/mysql
        volume:
          nocopy: true
    networks:
      - default
```

> [!IMPORTANT]
>
> When configuring your services, it is crucial to follow the naming conventions established by `laradock`. These conventions apply to the naming of images, containers, volumes, and networks. Adhering to these conventions ensures consistency and compatibility across your project.

**Key Variables Provided**

`laradock` provides several predefined variables that you can utilize when setting up your services. These variables allow for greater flexibility and customization. Below is a list of the main variables:

- `MAIN_UID`: The user ID for the service.
- `MAIN_GID`: The group ID for the service.
- `MAIN_PROJECT_NAME`: The name of your project.
- `MAIN_PROJECT_PORT`: The port used to expose the app service.
- `MAIN_PHP_VERSION`: The version of the PHP-FPM image to be installed.

**Environment-Specific Configurations**

In addition to the predefined variables, you can also include environment-specific configurations in your Docker Compose file. These configurations can be defined in `.env`, which should be stored within the custom directory. Below is an example of what such `.env` might look like:

```env
MYSQL_ROOT_PASSWORD=mysql_password_root
MYSQL_USERNAME=mysql_username
MYSQL_PASSWORD=mysql_password
MYSQL_DATABASE=mysql_database
```

_These environment variables will be read by `Docker Compose` and subsequently utilized by your services. This approach allows for greater flexibility and customization when configuring your project's services._

## 🐳 Running with Environment

To run while specifying an environment file, you can use the following command:

```sh
laradock --env-file $(pwd)/.laradock/custom/.env ---project-name laravel compose --php 8.1 --port 8000
```

> This command will:
>
> - Use the `.env` file located in the custom directory.
> - Set the project name to `laravel`.
> - Specify PHP version `8.1`.
> - Expose the application on port `8000`.

<p align="right">[ <a href="../../README.md">back to home</a> ]</p>
