Eponyms Documents
=================

- "main": Main document containing an Eponym
- "media": Media belonging to a _main_ document
- "category": A tag name and human-readable name for a category
- "suggestion": A document suggesting a change to any document


Authored
--------

This is the “superclass” document model from which all other documents inherit.

```json
{
    "id": "…",
    "type": "document-type",
    "author": "author-username",
    "date": "2016-11-creation-date",
    "dateUpdated": "2016-12-last-update"
}
```


Main
----

The main document describing the eponym (item).
Inherits from `authored`.

```json
{
    {inherit properties from `authored`}
    "tags": ["tag1", "tag2"],
    "localized": {
        "en": {
            "title": "An Eponym",
            "text": "This is the text body for this eponym"
        },
        "de": {
            "title": "Ein Eponym",
            "text": "Dies ist die Beschreibung dieses Eponyms"
        }
    }
}
```

Tag
---

Documents containing translations for all the tags.
Inherits from `Authored`.

```json
{
    {inherit properties from `authored`}
    "tag": "tag",
    "localized": {
        "en": "A Tag",
        "de": "Der Tag"
    }
}
```

