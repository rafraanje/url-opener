# URL Opener

A command-line tool that opens URLs based on pattern matching, designed to be used with keyboard shortcuts (e.g., Win+O to open URLs from selected text). It's particularly useful for quickly opening issue trackers, tickets, or other pattern-based URLs. It can also open local files. This project was created using AI assistance (Cursor).

## Features

- Open URLs based on configurable patterns
- GUI mode with text entry dialog
- Grab selected text from any window
- Configurable URL patterns via config file
- Support for regex capture groups

## Installation

The script requires a configuration file to work. Copy the example configuration:

    cp url_patterns.example.conf url_patterns.conf

Then edit `url_patterns.conf` to match your needs. The example configuration contains common patterns that you can customize, see the [Configuration](#configuration) section for more information.

### Dependencies

The script requires the following dependencies:

For basic functionality:

    bash

For GUI support (--gui option):

    # Debian/Ubuntu
    sudo apt-get install zenity

    # RedHat/CentOS
    sudo yum install zenity

For text selection grabbing (--grab option):

    # Debian/Ubuntu
    sudo apt-get install xclip

    # RedHat/CentOS
    sudo yum install xclip

## Usage

### Basic Usage

    ./open_urls.sh [options] [identifier]

### Options

- `--gui`: Opens a GUI dialog for entering/editing the identifier
- `--grab`: Uses currently selected text as the identifier (sanitized for safety)
- Both options can be combined: `--gui --grab`

### Security Features

The script includes several security measures:

- Selected text is sanitized by:
  - Removing control characters
  - Removing whitespace
  - Limiting length to 1000 characters
- File paths are validated before opening
- URL patterns must explicitly match the entire input
- Direct URLs must contain `://` to prevent command injection

### Examples

    # Basic usage
    ./open_urls.sh PROJECT-1234

    # Open GUI dialog
    ./open_urls.sh --gui

    # Open GUI with pre-filled text
    ./open_urls.sh --gui PROJECT-1234

    # Use selected text
    ./open_urls.sh --grab

    # Open GUI with selected text pre-filled
    ./open_urls.sh --gui --grab

## Configuration

The script uses a configuration file `url_patterns.conf` to define URL patterns. Each line in the file contains a pattern and URL template, separated by `|`:

    # Format: pattern|url_template
    ^(PROJECT-[0-9]+)$|https://company.atlassian.net/browse/{match}
    ^([A-Za-z0-9_-]+)#([0-9]+)$|https://github.com/{group1}/issues/{group2}
    ^(PROJECT-[A-Z0-9]+)$|https://company.sentry.io/issues/{match}

    # Local files (with safety checks)
    ^([.~/]?[-_./A-Za-z0-9]+)$|file://{match}

    # Direct URLs
    ^(https?://[-_./A-Za-z0-9]+)$|{match}

### Pattern Format

- Use regular expressions for patterns
- Patterns are anchored (must match entire input)
- Use capture groups `()` if needed
- Available replacements in URL template:
  - `{match}`: The entire matched text
  - `{group1}`, `{group2}`, etc.: Captured groups

### Example Patterns

    # Jira tickets
    ^(PROJECT-[0-9]+)$|https://company.atlassian.net/browse/{match}

    # GitHub issues
    ^([A-Za-z0-9_-]+)#([0-9]+)$|https://github.com/{group1}/issues/{group2}

    # Sentry issues
    ^(PROJECT-[A-Z0-9]+)$|https://company.sentry.io/issues/{match}

### Local File Support

The script can safely open local files:
- Supports absolute and relative paths
- Expands ~ to home directory
- Prevents command injection by validating paths
- Only opens existing, readable files
- Supports common file extensions and paths containing alphanumeric characters, dots, dashes, and underscores

Examples of valid file paths:
```bash
./script.sh
~/Documents/file.txt
/etc/hosts
../relative/path/file.pdf
```


