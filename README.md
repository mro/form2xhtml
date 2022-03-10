
# ✂️ form2xhtml

Convert [RFC2388](https://tools.ietf.org/html/rfc2388)
multipart/[form-data](https://ec.haxx.se/http/http-multipart) dumps to a minimal
xhtml form containing the same data as the webform at submission.

Comes with a `dump.cgi` in `./contrib/` to catch such dumps and an xslt trafo to [Atom
RFC4287](https://tools.ietf.org/html/rfc4287) in case.

## Synopsis

```sh
$ form2htxml -h
$ form2xhtml -V
$ form2xhtml enclosure_prefix < source.dump > target.xhtml

$ form2xhtml ./ < source.dump > target.xhtml
$ form2xhtml /dev/null < source.dump > target.xhtml
```

## Design Goals

| Quality         | very good | good | normal | irrelevant |
|-----------------|:---------:|:----:|:------:|:----------:|
| Functionality   |           |   ×  |        |            |
| Reliability     |           |      |    ×   |            |
| Usability       |           |   ×  |        |            |
| Efficiency      |           |      |    ×   |            |
| Changeability   |     ×     |      |        |            |
| Portability     |           |      |        |      ×     |

## Mirrors

see doap.rdf
