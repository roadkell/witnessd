## witnessd: file/directory event watcher for systemd ##
```
     ◟◟◟
    ⎛ಠ ಠ⎞
   _⎝ ˜ ⎠_
  /  \/   \
 //      \ \
(/       / /
 \______(_/
   ▐█▌█🭫║
   ▐█▌██║
   ▐█▌██║
   ▐█▌██║
   ▐█▌██║
  _▐█▌██║
 (___(__)
```

### What ###

Witnessd is a pair of small template units for systemd, and a script for easy installation. It uses [systemd.path](https://www.freedesktop.org/software/systemd/man/systemd.path.html) unit to activate a [systemd.service](https://www.freedesktop.org/software/systemd/man/systemd.service.html) unit whenever a file or directory changes. It uses `PathChanged=` option, so it is not activated on every write to the watched file, but it is activated when the file which was opened for writing gets closed.

Other possible options are described [here](https://www.freedesktop.org/software/systemd/man/systemd.path.html#Options). For example, `PathModified=` is similar, but additionally it is activated also on simple writes to the watched file. Edit it in `witessd@.path` if needed.

### How ###

Download repository contents, examine the script and unit files, and run
```
./witnessd-add.sh path/to/watch executable/to/invoke [arguments for the executable]
```
`witnessd-add.sh` copies the template units into users' systemd config dir (`$HOME/.config/systemd/user/` by default), instantiates them with given arguments, and enables them.

Watched path must be absolute, but it may contain variables (they'll be expanded by the script), e.g. `$HOME/somedir/`.

Executable path may contain [systemd-format specifiers](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#Specifiers), e.g. `%h/.local/bin/myscript.sh`.

### Why ###

There are existing projects like [entr](http://eradman.com/entrproject/), [Watchman](https://facebook.github.io/watchman/) and [fswatch](https://emcrisostomo.github.io/fswatch/), but they seemed like an overkill for me, especially given that all the necessary facilities are already present in systemd.

This project doesn't have dependencies beside systemd itself. There's no need for third-party software. On the downside, though, it is not cross-platform, and if fine-tuning is required, it may be necessary to dig into the systemd documentation.

### License ###

[Hippocratic License 3.0](https://github.com/roadkell/witnessd/blob/main/LICENSE.md)
