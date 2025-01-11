# Additional Script for Building Web Image

This directory contains additional scripts and instructions for building the web image. The entire process revolves around a single key script: `web.sh`, which is located in `/var/www/html/_script/` and is designed to execute a sequence of commands once the Docker image has been fully installed.

> [!IMPORTANT]
>
> Ensure script starts with the following line:
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

## 🚀 Example: Customizing `Nginx` Configuration

You might need to replace the default `Nginx` configuration files with your own custom configurations. This can be achieved by updating the `web.sh` script as shown below:

```sh
#!/usr/bin/env sh
set -euo pipefail

mv ./nginx.conf     /etc/nginx/
mv ./default.conf   /etc/nginx/conf.d/
```

_In this example, the custom configuration files (`nginx.conf` and `default.conf`) are relocated to the directories where `Nginx` expects to find them. This ensures that your web server operates using the configurations you have defined._

<p align="right">[ <a href="../../../README.md">back to home</a> ]</p>
