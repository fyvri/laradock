# Additional Script for Building App Image

This directory contains additional scripts and instructions for building the `app` image. The process is structured around two key scripts: `base.sh`, and `app.sh`, each executed at specific stages of the image build process.

## 📃 Script Descriptions

1.  `base.sh`

    Located in `/tmp/`, this script runs commands after the installation of the default system packages.

2.  `app.sh`

    Found in `/var/www/html/`, this script is the final step and runs commands after the application is fully installed.

> [!IMPORTANT]
>
> Ensure every script starts with the following line:
>
> `set -euo pipefail`
>
> This enforces:
>
> - `-e`: Immediate exit if a command fails.
> - `-u`: Treating unset variables as errors.
> - `-o pipefail`: Exiting if any command in a pipeline fails.
>
> Adhering to this structure keeps the build process modular, clean, and reusable.

## 🚀 Example: Installing Packages and Dependencies

Here’s an example workflow for installing `bash`, `nano`, and `yarn`.

1.  Updating and Adding Packages in `base.sh`:

    ```sh
    #!/usr/bin/env sh
    set -euo pipefail

    apk --no-cache add bash nano yarn
    ```

    _Since `bash` is installed, it enables the use of bash scripts for further instructions._

2.  Running Additional Commands in `app.sh`:

    During application setup (`app.sh`), you can execute tasks like `yarn install` or other instructions.

    ```bash
    #!/usr/bin/env bash
    set -euo pipefail

    yarn install
    ```

## ✨ Extending the Setup with Custom Scripts

Additional scripts can be included to handle specific tasks. For example, to manage PHP extensions, you can create a `php_extensions.sh` script and link it to `base.sh`.

1.  Modifying `base.sh` to Call `php_extensions.sh`:

    ```sh
    #!/usr/bin/env sh
    set -euo pipefail

    apk --no-cache add bash imagemagick-dev
    pecl install imagick

    chmod +x "./php_extensions.sh"
    ./php_extensions.sh
    ```

2.  Content of `php_extensions.sh`:

    This script installs PHP extensions like `imagick`.

    ```bash
    #!/usr/bin/env bash
    set -euo pipefail

    docker-php-ext-enable imagick
    ```

<p align="right">[ <a href="../../../README.md">back to home</a> ]</p>
