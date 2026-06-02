# Applications

This directory holds a **suggested application list** — apps you may want to
install on a new machine. Nothing is downloaded or installed automatically;
the setup just prints the list so you can install whatever you want manually
from each app's official source.

## What It Does

When run, `setup.sh`:

1. Asks if you want to see the list of applications
2. If yes, prints each app with a short note on what it's for
3. Exits — no downloads, no changes to your system

## Files

```
src/apps/
├── setup.sh   # Prompts and prints the list
├── apps.txt   # The app list (data only)
└── README.md  # This documentation
```

## Editing the List

Edit `apps.txt`. One app per line:

```
App Name | short use
```

- Lines starting with `#` and blank lines are ignored.
- Add a line to suggest a new app; delete a line to drop one.
- No need to touch `setup.sh`.

## Manual Usage

```bash
# Show the application list
./src/apps/setup.sh
```
