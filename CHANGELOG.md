### 1.6.9
  * template path render fix

### 1.6.8
  * markdown helper modal added

### 1.6.7
  * markdown helper modal added

### 1.6.6
  * user password change redirect fix, redux

### 1.6.5
  * user password change redirect fix, again

### 1.6.4
  * user password change redirect fix

### 1.6.3
  * change "Landing" to "Home"
  * fix Participant deletion, again
  * remove Remember me from User login

### 1.6.2
  * fixed Participant deletion
  * enabled Participant Thoughts Viz for Coach

### 1.6.1 - 2014-12-15

* enhancements
  * users are able to moderate groups
  * 'moderators' are created when a social group is created

### 1.6.0 - 2014-12-15

* enhancements
  * enabled printing of all lesson content

### 1.5.25 - 2014-12-15

* enhancements
  *  added wizard of oz flag to an arm

### 1.5.24 - 2014-12-12

* bug fix
  *  modified after update path for user password registration

### 1.5.23 - 2014-12-11

* enhancements
  * added additional authorization to User-based controllers

### 1.5.22 - 2014-12-11

* bug fixes
  * removed lesson creation from content_modules route

### 1.5.21 - 2014-12-11

* bug fixes
  * changed dependency from destroy to nullify on tasks for users

### 1.5.20 - 2014-12-11

* fixed broken video slide in lesson bug
* removed unused rails admin template

### 1.5.19 - 2014-12-11

* bug fixes
  * updated url helper methods due to breakage in tfd app

### 1.5.18 - 2014-12-11

* enhancements
  * remove Remember me for Participants
  * enable add to homescreen icon for iOS

### 1.5.16 - 2014-12-11

* bug fixes
  * updated participant sign in authorization
  * participant cannot log in if they don't have an active membership

### 1.5.15 - 2014-12-10

* bug fixes
  * updated cancan dependency to cancancan

### 1.5.14 - 2014-12-10

* bug fixes
  * updated authorization to include ONLY groups and arms that a coach is assigned to through memberships is visible
  * updated some incorrectly written validations

### 1.5.13 - 2014-12-09

* bug fixes
  * fix authorization unauthorized bug for researchers on /arms

### 1.5.12 - 2014-12-09

* enhancements
  * added authorization to many controllers and updated ability file

### 1.5.11 - 2014-12-8

* bug fixes
  * updated bit_core and bit_player

### 1.5.10 - 2014-12-8

* bug fixes
  * Added has many relation on participants for events with a destroy dependency
  * Can now destroy participants

### 1.5.9 - 2014-12-5

* bug fixes
  * Updated bit_core to allow for a lesson to be created when no lessons exist yet for an arm
  * Consequently, config for slideshows and tools can be removed

### 1.5.8 - 2014-12-5

* enhancements
  * Updated migration file to ensure backwards compatibility

### 1.5.7 - 2014-12-5

* enhancements
  * Removed reports controller
  * Updated ability file for authorization used in think_feel_do_dashboard engine

### 1.5.6 - 2014-12-4

* enhancements
  * Removed console.log calls from js files that were also showing up in specs
  * Removed excess css and improved the select option dropdowns to match bootstrap styling with the correct for and id attributes

* bugfixes
  * think_feel_do_so tests will now pass with the updates to the select option dropdowns

### 1.5.5 - 2014-12-4

* enhancements
  * lessons are now scoped within arms

### 1.5.4 - 2014-12-4

* bugfixes
  * updated user and participant strong password validations and fixtures to use stronger passwords.

### 1.5.3 - 2014-12-3

* enhancements
  * removed unnecessary migrations in spec/dummy

### 1.5.2 - 2014-12-3

* enhancements
  * removed unnecessary readme documentation

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
