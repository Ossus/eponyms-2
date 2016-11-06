Eponyms Sync Gateway Channels
=============================

Sync Channels
-------------

Documents in the database are assigned to these **channels** in order to handle access control:

- "public": Eponyms approved for public display. Read-only.
- "suggestion-{user-id}": Documents suggesting an eponym or changes. Can only be created, not updated, and are added to the _admin_ and the user's suggestions channel.
- "admin": Contains suggested eponyms or changes.

User roles:

- "admin": 
- "GUEST":


Ansible
-------

To run the Ansible playbook against our local VM:

    ansible-playbook -l local playbook.yml

To run the Ansible playbook against our Digital Ocean droplet:

    ansible-playbook -l droplets playbook.yml


Links
-----

- [How to Authorize Users in Sync Gateway](http://blog.couchbase.com/2016/january/how-to-authorize-users-in-sync-gateway)
- [How to Validate Documents Types in Sync Gateway](http://blog.couchbase.com/2016/january/how-to-validate-documents-types-in-sync-gateway)
- [Augment your Sync Function with Roles in Couchbase Sync Gateway](http://blog.couchbase.com/2016/january/augment-your-sync-function-with-roles-in-couchbase-sync-gateway)
