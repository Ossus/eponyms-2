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
    "_id": "…",
    "type": "{document-type}",
    "audits": [{
        "author": "{author-name}",
        "date": "2016-11-creation-datetime",
        "action": "create"
    }]
}
```


Main
----

The main document describing the eponym (item).
Inherits from `authored`.

```json
{
    {inherit properties from `authored`}
    "tags": [
		"tag1",
		"tag2"
	],
    "content": {
        "en": {
            "name": "An Eponym",
            "text": "This is the text body for this eponym"
        },
        "de": {
            "name": "Ein Eponym",
            "text": "Dies ist die Beschreibung dieses Eponyms"
        }
    }
}
```

Tag
---

Documents containing translations for all a tag.

```json
{
    "_id": "tag1"
    "type": "tag",
    "content": {
        "en": "A Tag",
        "de": "Der Tag"
    }
}
```

