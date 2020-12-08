
# ✂️ form2xml

Convert [RFC2388](https://tools.ietf.org/html/rfc2388)
multipart/[form-data](https://ec.haxx.se/http/http-multipart) dumps to a minimal
xhtml form containing the same data as the form before submission.

Comes with a CGI to catch such dumps and an xslt trafo to [Atom
RFC4287](https://tools.ietf.org/html/rfc4287).

## Synopsis

```sh
$ form2xml -h
$ form2xml -v
$ form2xml [enclosure prefix] < source.dump > target.xhtml
$ form2xml /dev/null < source.dump > target.xhtml
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
