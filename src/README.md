# App Directory Guide

This directory serves as the designated location where all your app directories should be placed to ensure proper integration. Follow the detailed instructions provided below to seamlessly incorporate your amazing applications into the `laradock` environment.

## 📂 Adding Your App Directory

To ensure your application operates correctly within the `laradock` environment, you can clone your repository directly or move/link an existing directory.

### Clone form Repository

You can directly clone your app's repository into the required directory, but make sure that you are now in the `src/` directory. For example:

```sh
git clone --branch 10.x --single-branch git@github.com:laravel/laravel.git awesome-laravel
```

- `awesome-laravel` will be the name of the directory created.
- Ensure you replace `awesome-laravel` with a relevant name for your app.

### Link an Existing Directory

If your app is already located elsewhere on your system, you can move it into the `laradock` directory and then create a symbolic link to it for keeping the original intact.

1.  Make sure that you are now in the `src/` directory.

    ```sh
    cd ./src
    ```

2.  Move the app directory into `laradock`:

    ```sh
    SOURCE=~/Downloads/awesome-laravel
    mv "$SOURCE" ./ || { echo "Failed to move $SOURCE. Ensure the directory exists."; exit 1; }
    ```

3.  Create a symbolic link to the original location:

    ```sh
    ln -s "$(pwd)/$(basename $SOURCE)" "$(dirname "$SOURCE")/" || { echo "Failed to create symbolic link."; exit 1; }
    ```

## 🗃️ Final Directory Structure

After completing the steps above, your `laradock` directory should have the following structure:

```text
├── compose
├── docs
├── src
│   ├── awesome-laravel
│   ├── first-project
│   ├── laravel-10
│   ├── learn
│   └── test-laravel
├── .dockerignore
├── laradock.sh
├── LICENSE
└── README.md
```

## 💡 Tips for a Smooth Integration

- Custom Names: Replace `awesome-laravel` with your app's actual directory name.
- Correct Placement: Always ensure the app is under the `src/` directory to maintain compatibility with the `laradock` environment.

By following these steps, you’ll integrate your application into `laradock` effortlessly! 🚀

<p align="right">[ <a href="../README.md">back to home</a> ]</p>
