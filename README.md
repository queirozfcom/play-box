play-box
========

Vagrant, Puppet to setup a dev environment for Play! Framework.

### Some notes

- Play run on the JVM and, as such, needs a healthy amount of RAM to run. This is why this box is setup with 1698 MB RAM. Feel free to increase this or otherwise customize this value for your purposes.
- Username/password: `vagrant/vagrant`
- Most `activator` commands are analogous to `sbt` commands. In other words, running `activator xpto` will most likely do the same as `sbt xpto`.
- If you get stuck (fail to install dependencies or fail to compile), you can delete `~/.ivy2` and the next time you compile your project, it will start again from scratch (re-installing stuff that may have gotten corrupted or something like that).

### Some activator commands

(`activator` command will be on your `$PATH`)

- `activator new` - creates a new project
- `activator ui` (when in a project directory) - opens activator UI to view your project
- `activator eclipse` (when in a project directory) - generates eclipse files so that you can import your project into eclipse
- `activator compile` (when in a project directory) - compiles your project
- `activator run` (when in a project directory) - runs (and also compiles, if needed) your project

