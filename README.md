Eponyms 2
=========

All new incarnation of the iOS Eponyms app.


Installation
------------

This project is built in Swift 2, runs on iOS 8 or newer and needs Xcode 7.

Clone the repository via git:

    $ git clone https://github.com/Ossus/eponyms-2.git
    $ cd eponyms-2

Now [download the CouchbaseLite framework](http://www.couchbase.com/download#cb-mobile), extract it and place `CouchbaseLite.framework` into the `Couchbase` folder.
Open `eponyms-2.xcworkspace` in Xcode and run!


Couchbase
---------

- [Document Model](./DocumentModel.md)
- [CouchbaseLite Guides](http://developer.couchbase.com/mobile/develop/guides/couchbase-lite/native-api/index.html)
- [CouchbaseLite Docs](http://cocoadocs.org/docsets/couchbase-lite-ios/)


Import from Eponyms 1.x
-----------------------

The documents will not get the same ids as the ones used in legacy Eponyms.
Hence, to migrate favorites, the names of favorite Eponyms must be exported so the new version can find them and make them a favorite.
