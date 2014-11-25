### 1.1.0 - 2014-11-25

* enhancements
  * Add buttons to opt into Thought and Activity editing

### 1.0.2 - 2014-11-25

* enhancements
  * Added migration for orphaned groups that don't have an arm_id and added constraint on groups to require arm_id.

### 1.0.1 - 2014-11-25

* enhancements
  * Added a constraint that doesn't let null exist in arms tabel for title and is_social

### 1.0.0 - 2014-11-25

* enhancements
  * Improved navigation for users with added 'Coach Dashboard' and 'Manage Content Dashboard'
    * There is no longer a large row of admin buttons but links that are subdivided into each sub navigation
  * Added nesting navigation by scoping groups to arms (this includes adding arm_id to groups)
