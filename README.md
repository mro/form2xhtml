
# ✂️ form2xml

Convert HTTP multipart/form-data RFC 2388 POST dumps into xml for e.g. Atom RFC 4287.

See

* https://tools.ietf.org/html/rfc2388
* https://ec.haxx.se/http/http-multipart
* https://tools.ietf.org/html/rfc4287

## Synopsis

```sh
$ form2xml -h
$ form2xml -v
$ form2xml [enclosure prefix] < source.dump > target.xml
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
