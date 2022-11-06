
# php (php)

Installs PHP

## Example Usage

```json
"features": {
    "ghcr.io/shyim/devcontainers-features/php:0": {
        "version": "latest"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select or enter a PHP version | string | 8.1 |
| installComposer | Install PHP Composer? | boolean | true |
| extensionsExtra | - | string | zip |
| disableAllExtensions | - | boolean | false |

## Composer

By default this feature installs also Compoer. You can disable this by setting `installComposer` to `false`.

## Installing different PHP versions

If you want to install different PHP versions, you can use the following

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/shyim/devcontainers-features/php:latest": {
            "version": "8.0"
        }
    }
}
```

## Enabling additional php extensions

If you want to enable additional php extensions, you can use the following:

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/shyim/devcontainers-features/php:latest": {
            "version": "8.0",
            "extensionsExtra": "xdebug redis"
        }
    }
}
```

Following additional extensions are possible:

- `amqp`
- `apcu`
- `ast`
- `dba`
- `enchant`
- `imagick`
- `imap`
- `ldap`
- `memcache`
- `mongodb`
- `msgpack`
- `odbc`
- `pdo_dblib`
- `pdo_firebird`
- `pdo_odbc`
- `pdo_sqlsrv`
- `pspell`
- `redis`
- `shmop`
- `sqlsrv`
- `tidy`
- `xdebug`
- `yaml`
- `memcached`
- `ds`

You can also use `disableAllExtensions` to disable all extensions and enable only the ones you want.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/shyim/devcontainers-features/blob/main/src/php/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
