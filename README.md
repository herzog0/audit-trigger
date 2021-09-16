A simple, customisable table audit system for PostgreSQL implemented using
triggers.

See:

http://wiki.postgresql.org/wiki/Audit_trigger_91plus


## update 2021-09-16
### Added "ignored columns" feature
This feature is similar to the preexisting one "excluded columns" in the
sense that it will ignore updates whose changes originated from the
argument passed. However, the new feature will NOT exclude the provided
columns from the "row_data" field in the audit table. This way, if you
care about the changes in field B but ONLY when the field A updates, you
should just ignore the column B, not exclude it.
