### 1.5.1 - 2014-12-3

* bugfixes
  * added twilio-ruby as a gemspec dependency

### 1.5.0 - 2014-12-3

* enhancements
  * Nested managed content for arms
  * added arm_id and constraints to BitCore::Slideshow & BitCore::Tool

### 1.4.0 - 2014-12-1

* enhancements
  * Add more links to help content authors CRUD content providers. The rationale, is that content provider CRUDing was nested within content modules and access was someone limited during this enhancement.

### 1.3.0 - 2014-11-25

* enhancements
  * User login redirects to arms_path; i.e., home page for users

### 1.2.0 - 2014-11-25

* enhancements
  * Removed Tools and Provider links with updated tests
  * Improved navigation between engines
  * removed manage/groups path & it is no longer the redirect

### 1.1.1 - 2014-11-26

* updates
  * Removed code associated with PHQ email reminders (moved to think_feel_do)

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
