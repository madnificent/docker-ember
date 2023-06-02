# docker-ember

Docker and tooling for using ember-cli in a reproducable way.

<br>

## Getting Started
### Installation

#### On Linux
Assuming you have docker set up correctly, simply clone this repository and add the bin folder to your path.
```bash
git clone https://github.com/madnificent/docker-ember.git
echo "export PATH=\$PATH:`pwd`/docker-ember/bin" >> ~/.bashrc
source ~/.bashrc
```
#### On Mac
We suggest to use brew installation scripts to account for specific issues related to docker for mac.
See: https://github.com/mu-semtech/homebrew-scripts


### Configuration
You can configure the Ember version in `~/.config/edi/settings` using the `VERSION` variable.
```bash
VERSION="3.15.1"
```

#### Configuring on Linux

By default `ed*` commands run as root in the docker container, this means newly created files will be owned as root as well. To avoid this you can use user namespaces to map the container's root user to your own user. This requires some minimal configuration.

*Note*: on ubuntu 16.04 your user needs to part of the docker group so that it has access to `/var/run/docker.sock`

Assuming systemd and access to the `id` command the following steps should suffice:

1. **Create the correct mapping in `/etc/subuid` and `/etc/subgid`**
    ```bash
    echo "$( whoami ):$(id -u):65536" |  sudo tee -a /etc/subuid
    echo "$( whoami ):$(id -g):65536" |  sudo tee -a /etc/subgid
    ```

2. **Adjust ExecStart of docker daemon to include `--userns-remap=ns1`.**
    For systemd you can use the following command:
    ```bash
    systemctl edit docker.service
    ```

    The config file might look this:
    ```conf
    [Service]
    ExecStart=
    ExecStart=/usr/bin/dockerd --userns-remap="your-user-name"
    ```

More information on user namespaces is available [in the docker documentation](https://docs.docker.com/engine/security/userns-remap/).

#### Configuring on Mac

Mac uses a login shell when launching the default terminal app, which slightly changes the desired setup.  Sharing the ssh-agent socket currently doesn't work, and thus requires a workaround.

1. **Make your shell read .bashrc**

    Docker for Mac creates files under the right username automatically.  Mac does use a login shell when launching the default terminal app, rather than an interactive shell.  These shells don't read the standard ~/.bashrc file, but rather the ~/.bash\_profile file.  Make sure the following is present in your ~/.bash\_profile so ~/.bashrc is always read.

    ```bash
    if [ -f ~/.bashrc ]; then
    source ~/.bashrc
    fi
    ```

2. **Support the ssh-agent**

    The ssh-agent's socket can't be shared with Docker for Mac at the time of writing.  A common workaround is to use a Docker container in which a new ssh-agent is ran.  We advise the use of the https://github.com/10eTechnology/docker-ssh-agent-forward and have integrated this in the supplied scripts.  On mac, this solution is assumed to be installed.

#### NPM upgrades
It's important to note that since NPM v7 peer dependencies are installed by default when executing `npm install`. As of v3.27 the `docker-ember` image contains NPM >= v7.x. Using this version may lead to resolution conflict errors on peer dependencies in existing projects. NPM provides a [`--legacy-peer-deps` flag](https://docs.npmjs.com/cli/v7/using-npm/config#legacy-peer-deps) to make `npm install` behave like in previous versions, not installing peer dependencies by default. This can help teams to gradually fix the peer dependency version conflicts in their project.

The `--legacy-peer-deps` flag can be enabled project-wide by adding `legacy-peer-deps=true` to `.npmrc`. In that case it's import to copy that file inside your project's Docker build before running `npm install`.

Example Dockerfile:
```dockerfile
FROM madnificent/ember
COPY package.json .
COPY .npmrc .   # <--- this line must be added
RUN npm install
```

### Creating a new app using Docker
All commands (except for `ember serve` which deserves special attention), can be ran through the *edi* command.

Let’s create a new project:
```bash
edi ember new my-edi-app
```
This will generate a new application.  Once all dependencies have been installed, we can move into the application folder, and start the ember server:
```bash
cd my-edi-app
eds
```

You will see the application running.  Moving your browser to *http://localhost:4200*, you will see the `ember-welcome-page`.  Yay! It works \\o/

Let’s remove the welcome-page.  As instructed, we’ll remove the `{{welcome-page}}` component from the build.  Open your favorite editor, and update the contents of *application.hbs* to contain the following instead.
```hbs
<h1>My first edi app</h1>

{{outlet}}
```

We can generate new routes with the ember application still running.  Open a new terminal and open the *my-edi-app* folder.  Then generate the route:
```bash
edi ember generate route hello-link
```

Edit the *app/templates/hello-link.hbs* template so it contains the following
```hbs
<p>Hello!  This is some nested content from my first page.  <LinkTo @route='index'>Go back</LinkTo></p>
```

and add a link to *app/templates/application.hbs*
```hbs
<h1>My first edi app</h1>
<p><LinkTo @route='hello-link'>Hello</LinkTo></p>

{{outlet}}
```

Boom, we have generated files which we can edit.  Lastly, we’ll install the *ember-cli-sass* addon as an example.

```bash
edi ember install ember-cli-sass
```

Now **restart eds** to ensure the ember server picks up the newly installed addon, remove the old *app/styles/app.css* and add a `background-color` to *app/styles/app.scss*
```scss
body {
  background-color: green;
}
```

#### Caveats

There are some caveats with the use of edi.  First is configuring the ember version.  You can switch versions easily by editing a single file.  Next is configuring the backend to run against.

- Configuring the ember version
    You may want to have more than one ember version installed when generating new applications.  When breaking changes occur to ember-cli, or if you want to be sure to generate older applications.  Perhaps you simple don’t want to download all the versions of ember-cli.  Whatever your motives are, you can set  the version in *~/.config/edi/settings*

    If the file or folder does not exist, create it.  You can write the following content to the file to change the version:

    ```conf
    VERSION="2.11.0"
    ```

    Supported versions are the tags available at [https://hub.docker.com/r/madnificent/ember/tags/](https://hub.docker.com/r/madnificent/ember/tags/).

- Linking to a backend
    Each Docker Container is a mini virtual machine.  In this virtual machine, the name _localhost_ indicates that little virtual machine.  We have defined the name _host_ to link to the machine serving the application.  In case you’d setup a mu.semte.ch architecture backend, published on port 80 of your localhost, you could connect your development frontend to it as such:

    ```bash
    eds --proxy http://host
    ```

    It is a common oversight to try to connect to localhost from the container instead.


And you're done! Our EmberJS development has become a lot more consistent and maintainable with the use of edi.  We have used it extensively, and have been able to reproduce builds easily in the past year.

*This tutorial has been adapted from Aad Versteden's mu.semte.ch article. You can view it [here](https://mu.semte.ch/2017/03/09/developing-emberjs-with-docker/)*

### Experimental features

Some experimental features have been added which optimize the way the Docker daemon is called.  These features may behave oddly when developing addons.  It may be required to restart certain daemons after using edl, or to disable features when using edl.

#### Live daemon

Some systems take more time than necessary to spin up a new docker daemon.  For these cases, you may choose to keep a daemon alive and send commands to the daemon.  Set `EDI_USE_EDI_DAEMON` to a non-empty string to enable this feature.

Note: You will have to restart the daemon after using edl.

#### Optimize linked modules

The ember docker links locally developed node modules.  Some optimizations are possible in this regard but they break edl.

We mount all available node modules in a consistent way when you use edl.  Mounting many volumes may lead to a slow-down on some systems.  You may choose to mount only the used linked modules by setting `EDI_MOUNT_ONLY_USED_LINKED_MODULES` to a non-empty string.

When using older versions of node when developing nested node modules the builds may fail because the right node submodules are not included.  This is not the case when the symlinks are removed.  Setting both `EDI_MOUNT_ONLY_USED_LINKED_MODULES` and `EDI_MOUNT_USED_NODE_MODULES_WITHOUT_SYMLINKS` will mount the used node_modules directly.  This may also have a positive performance impact, but we did not run benchmarks.

These optimizations should be disabled when running edl as edl will not be able to find the addons to link.

#### SSH agent container

We assume you are running an SSH agent container as mentioned earlier.  If your application never reaches to the outside world using your ssh key, you may disable this feature.

On Mac, the socket of the native SSH agent can't be shared to the Docker image like we do in Linux.  We assume the necessary tooling is available on Mac to share the SSH agent.  Should you want to disable this feature, set `EDI_SSH_AGENT_CONTAINER` to an empty string.  If you want to force it to be turned on on Linux, then set it to a non-empty string.

When you disable this option, your locally running socket will be shared.  When Docker for Mac starts supporting this feature, that will be the superior option.

<hr>
<br>
<br>

## Usage (how-to)
We have 4 commands, each for a different use-case.  Run them at the
root of your project.

### ed

`ed` is your default friend.  `ed` helps you install npm & bower
dependencies, install new ember dependencies and run any other
non-interactive ember command.
```bash
    # Install a dependency
    ed ember install ember-cli-coffeescript
    # Install all current node modules
    ed npm install
    # Install bower components
    ed bower install
 ```

### eds
```bash
`eds` launches the ember server for you.

    # No nonsense ember server
    eds
    # Proxying to your localhost (note it's been renamed from localhost to host)
    eds --proxy=http://host:8080
    # Serving on a non default port
    eds --port=4000 --live-reload-port=64000
```

### edi

`edi` is the interactive version of `ed`.  It can ask you questions
and you can provide interactive answers.
```bash
    # Generate a route
    edi ember generate route epic-win
    # Release a new minor version
    edi ember release --minor
```

### edl
`edl` is your friend when developing addons. It provides a replacement for `npm link` and `npm unlink` that works in docker-ember. 
```bash
    # Create a global symlink of your addon
    cd your-ember-addon
    edl
    # Use that addon in another project
    cd your-ember-project
    edl your-ember-addon
    # Remove the global symlink of your addon
    cd your-ember-addon
    edl -u
```

*Note*: `edl` assumes `edi` is available on your PATH

### Building locally

To build locally in any capacity, run the [release](release) script using the desired ember-cli version.
Example usage: `./release 4.9.2`

Several of the files in this repo are a result of building. See the table below for which files to change:

|    File to change    |             ... for              |
| -------------------- | -------------------------------- | 
| templates/Dockerfile | for Dockerfile changes           |
| support-scripts      | for changes in multiple binaries |
| templates/bin/*      | for changes to specific binaries |

<hr>
<br>
<br>

## Explanations
Our ember-cli builds have not been as reproducable as we'd have wanted
them to be.  Tooling can differ across machines because the operating
systems are different, therefore yielding different versions of
nodejs/iojs or different versions of sass bindings.  The sass bindings
are what pushed us over the edge to try out Dockers for sharing our
build environment.

With the advent of user-namespaces in Docker, mounting volumes with
the right privileges has become
transparent. (see http://www.jrslv.com/docker-1-10/#usernamespacesindocker
for some basic info)

The arguments you need to pass to the Docker run command for it to be
useful are too cumbersome, hence we've created scripts to help you
out.