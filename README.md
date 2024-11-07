# concoct <img src="https://getcomposer.org/img/logo-composer-transparent.png" alt="Composer Logo" align="right" width="225"/>

[![PHP](https://img.shields.io/badge/PHP-4F5B93)][php]
[![License](https://img.shields.io/github/license/fmjstudios/concoct?label=License)](https://opensource.org/licenses/MIT)
[![CI Status](https://github.com/fmjstudios/concoct/actions/workflows/ci.yaml/badge.svg)](https://github.com/delta4x4/concoct/blob/main/.github/workflows/ci.yml)
[![Renovate](https://img.shields.io/badge/Renovate-enabled-brightgreen?logo=renovatebot&logoColor=1DDEDD)](https://renovatebot.com/)

`concoct` is [Symfony][symfony]-based PHP application which at it's core provides a dynamic self-hosted Composer
repository, with features akin to Composer's [satis][satis]. Furthermore it monitors a
user's [Envato][envato] purchases for Composer-manageable PHP packages or plugins. To achieve this `concoct` requires
an [Envato Personal Access Token][envato_token] to communicate with the Envato API. The artifacts retrieved from the
Composer-native sources like `vcs`, or from our newly added `envato` source will then be downloaded and served as part
of the Composer repository. If wanted the artifacts may also be stored within an _S3_ bucket as opposed to the local
filesystem.

[Composer][composer] is a package manager for the [PHP][php] programming language. It helps you declare, manage and
install dependencies of PHP projects. This project implements a private [Composer][composer] repository, for
dependencies which aren't installable via the public Composer repository [Packagist][packagist].

## ? TL;DR

```shell
# add to composer.json
{
    "repositories": [
        {
            "type": "composer",
            "url": "https://composer.delta4x4.net"
        }
    ]
}
```

### ?? Contributing

Refer to our [documentation for contributors][contributing] for contributing guidelines, commit message
formats and versioning tips.

### ?? Maintainers

This project is owned and maintained by [dela4x4 Geländesport und Zubehör Handles GmbH][delta4x4_github] refer to
the [`AUTHORS`][authors] or [`CODEOWNERS`][codeowners] for more information. You may also use the linked
contact details to reach out directly.

---

### ?? License

**[Proprietary][license]**

### ©? Copyright

Assets provided by [Composer &reg;][composer].

<!-- INTERNAL REFERENCES -->

<!-- File references -->

[license]: LICENSE

[authors]: .github/AUTHORS

[codeowners]: .github/CODEOWNERS

[contributing]: docs/CONTRIBUTING.md

<!-- General links -->

[delta4x4_github]: https://github.com/delta4x4

[php]: https://php.net

[symfony]: https://symfony.com

[composer]: https://getcomposer.org/

[composer_repository]: https://composer.delta4x4.net

[packagist]: https://packagist.org/

[satis]: https://github.com/composer/satis

[envato]: https://envato.com

[envato_token]: https://build.envato.com/api/#token
