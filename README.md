[donate-saweria::shield]: https://img.shields.io/badge/Saweria-azisalvriyanto-orange.svg
[donate-saweria::url]: https://saweria.co/azisalvriyanto
[donate-trakteer::shield]: https://custom-icon-badges.demolab.com/badge/Trakteer-azisalvriyanto-be1e2d.svg?logo=trakteer-red
[donate-trakteer::url]: https://trakteer.id/azisalvriyanto/tip
[donate-ko-fi::shield]: https://img.shields.io/badge/Ko--fi-azisalvriyanto-FF5E5B?logo=kofi
[donate-ko-fi::url]: https://ko-fi.com/azisalvriyanto
[donate-paypal::shield]: https://img.shields.io/badge/PayPal-membasuh-informational?logo=paypal
[donate-paypal::url]: https://paypal.me/membasuh

# laradock

> _To create a simple Laravel development environment using Docker Compose, which runs `PHP-FPM` and `Nginx`, and offers high flexibility for customization to suit your project's specific needs._

>

<div align="center">
    <picture>
        <img alt="laradock" width="90%" src="./docs/demo.gif" />
    </picture>
</div>

>

`laradock`, a Docker-based solution, offers a range of configuration options that allow you to easily extend and modify the default environment. By adjusting the provided scripts and configuration files, you can fine-tune the environment to meet the requirements of your application.

Here are several examples of how you can customize the default environment to better suit your needs:

- Choose any desired port for the application, enabling you to tailor the environment to your network setup.
- Select any `PHP` version from the [official PHP image repository](https://hub.docker.com/_/php/tags?name=-fpm-alpine), giving you the flexibility to work with the `PHP` version most suitable for your app.
- Add additional packages such as `bash`, `yarn`, or others to enhance the development environment with more tools that might be needed for your workflow.
- Install custom `PHP` extensions or tools to meet the specific requirements of your application.
- Modify `Nginx` configurations to adapt the web server's behavior to the specific needs of your Laravel app, such as adjusting rewrite rules or configuring SSL.

For more detailed guidance on how to customize the Docker setup, refer to the following documentation files:

- App Image: [`compose/app/scripts/README.md`](./compose/app/scripts/README.md)
- Web Image: [`compose/web/scripts/README.md`](./compose/web/scripts/README.md)

By referencing these resources, you can easily configure the development environment to match your precise needs, ensuring a streamlined and efficient Laravel development experience.

---

> [!IMPORTANT]
>
> New features will be added over time! Right now, it **ONLY** supports **Linux**, but I’d love to expand it to macOS too. If you’re interested in helping it grow, your support could even help me save up for a MacBook 💻 to make that happen — _but only if you’re definitely able to!_ 😊 🎉
>
> [![Saweria][donate-saweria::shield]][donate-saweria::url] &nbsp; [![Trakteer][donate-trakteer::shield]][donate-trakteer::url] &nbsp; [![Ko-fi][donate-ko-fi::shield]][donate-ko-fi::url] &nbsp; [![PayPal][donate-paypal::shield]][donate-paypal::url]

## 🛠️ Installation

1.  Clone this repository:

    ```sh
    git clone git@github.com:fyvri/laradock.git && cd laradock
    ```

2.  Make the script executable:

    ```sh
    chmod +x ./laradock.sh
    ```

## 🍻 Setup

Before running `laradock`, make sure that you have installed [`Docker`](https://docs.docker.com/engine/install/) and are able to execute the `docker compose` command in your terminal.

- **App Directories**

  All of your app directories should be placed under the `src/` directory. This directory contains the collection of your Laravel apps, which will be installed and managed via `laradock`. For comprehensive guidance on how to accomplish this, please refer to the detailed steps provided [here](./src/README.md).

- **App Image**

  The `app` image serves as the core environment for running your Laravel application and is built upon the `php:${version}-fpm-alpine` image. By default, the `app` image will install the following packages:

  - `composer`
  - `curl`
  - `freetype-dev`
  - `libjpeg-turbo-dev`
  - `libzip-dev`

  Additionally, the `app` image will install several `PHP` extensions by default, including:

  - `bcmath`
  - `gd`
  - `mbstring`
  - `opcache`
  - `pdo_mysql`
  - `zip`

  However, you have the flexibility to customize the image by adding any extra packages or dependencies that your app requires. You can do this by creating custom scripts in the `compose/app/scripts/` directory. For detailed instructions on how to achieve this, please follow the steps outlined [here](./compose/app/scripts/README.md).

- **Web Image**

  The `web` image is based on the `nginx:stable-alpine` image. It comes pre-configured to run `Nginx` and apply the necessary configurations for your app. However, if you need to add extra packages or replace the default `Nginx` configuration, you are free to modify it. To learn how to customize the `web` image, refer to the instructions provided [here](./compose/web/scripts/README.md).

## 🚀 Usage

- **Basic**

  Simply, `laradock` can be run with:

  ```sh
  ./laradock.sh compose
  ```

- **Advanced**

  ```sh
  ./laradock.sh compose -n laradock -p 1337 -i laravel-10.x --php 8.1 --dev
  ```

## 🚩 Flags

This will display help for the tool. Here are all the options it supports.

```console
                                 🐳 v0.0.1
______                 ____________          ______
___  /_____ _____________ ______  /_____________  /__
__  /_  __ '/_  ___/  __ '/  __  /  __ \  ___/_  //_/
_  / / /_/ /_  /   / /_/ // /_/ // /_/ / /__ _  ,<
/_/  \__^_/ /_/    \__^_/ \__,_/ \____/\___/ /_/|_|

Usage:
   ./laradock.sh [command] [options...] <value> [--dev]

Commands:
   compose       : Compose 🚀
   help          : Show this help message 📖

Options:
   -n, --name    : Set the image name
   -p, --port    : Set the app port (default: 8000)
   -i, --input   : Set the app directory name (e.g., awesome-laravel)
       --php     : Specify the PHP version (e.g., 5.6, 7.4, 8.1, etc)
       --dev     : Build image on development

Examples:
   ./laradock.sh compose
   ./laradock.sh compose -n laravel-5.8 -p 8000 -i laravel-5.8 --php 7.2
   ./laradock.sh compose -n laravel-9.x -p 8000 -i laravel-9.x --php 8.0 --dev
```

## 👥 Contribution

If you have any ideas, [open an issue](https://github.com/fyvri/laradock/issues/new) and tell me what you think.

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

> [!WARNING]
> If you have a suggestion that would make this better, please fork the repo and create a pull request. Don't forget to give the project a star 🌟 I can't stop saying thank you!
>
> 1. Fork this project
> 2. Create your feature branch (`git checkout -b feature/awesome-feature`)
> 3. Commit your changes (`git commit -m "feat: add awesome feature"`)
> 4. Push to the branch (`git push origin feature/awesome-feature`)
> 5. Open a pull request

## 📜 License

This project is licensed under the [MIT License](./LICENSE). Feel free to use and modify it as needed.
