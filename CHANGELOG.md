## 1.15.9 - 2015-01-23
 * fixed Message labelling

## 1.15.8 - 2015-01-22
 * refactored tests and fixed deprecation warnings

## 1.15.7 - 2015-01-22
 * Correct authorization for Researchers and rubocop fixes

## 1.15.6 - 2015-01-22
 * updated patient dashboard lesson and task tables

## 1.15.5 - 2015-01-22
 * rubocop changes

## 1.15.4 - 2015-01-22
 * updated the url for reply messages

## 1.15.3 - 2015-01-22
 * updated redirect when a participant resets password

## 1.15.2 - 2015-01-22
 * fixed sorting issues in patient dashboard

## 1.15.1 - 2015-01-22
 * fixed RuboCop conflict and version.rb merge conflict

## 1.15.0 - 2015-01-21
 * PHQ features are conditionally checked via config in host app

## 1.14.15 - 2015-01-21
 * fixed Addressable namespace issue

## 1.14.14 - 2015-01-21
 * updated activity viz buttons

## 1.14.13 - 2015-01-21
 * refactored/updated Message labelling

## 1.14.12 - 2015-01-21
 * Updated phq viz logic

## 1.14.11 - 2015-01-20
 * added modal popups for drilldowns in mood and emotion viz

## 1.14.10 - 2015-01-20
 * Updated activity visualization to show all past activities not just scheduled activities

## 1.14.9 - 2015-01-20
 * added host app version to footer

## 1.14.8 - 2015-01-16
 * updated view helper and spelling error

## 1.14.7 - 2015-01-16
 * updated to latest git tagger

## 1.14.6 - 2015-01-16
 * further git tagger updates for testing

## 1.14.5 - 2015-01-16
 * updated to latest git tagger gem to fix an issue with engine tagging

## 1.14.4
 * fixed Lesson title format

## 1.14.3 - 2015-01-16
 * updated git tagger gem

## 1.14.2 - 2015-01-16
 * Updated a participant's activities page with collapse links and added in visualization enhancements

## 1.14.1
 * mood/emotions viz updates

## 1.14.0
 * mood/emotions viz updates
 * removed override for Devise login redirect

## 1.13.4
 * added Report authorizations

## 1.13.3 - 2015-01-14
 * updated latest tagger gem

## 1.13.2 - 2015-01-14
 * updated date formatting

## 1.13.1 - 2015-01-14
 * updated to latest git tagger gem

### 1.13.0
  * refactored Lessons
  * updated bit_core version
  * fixed deprecation warning
  * updated git_tagger version
  * added printable option to read Lessons

### 1.12.4 / 2015-1-9
  * enhancements
    * updated lesson roadmap

### 1.12.3 / 2015-1-9
  * enhancements
    * fixed lesson grouping and slide sorting for all content

### 1.12.2 / 2015-1-8
  * enhancements
    * Added an additional test to check if unread lessons are displayed correctly on LEARN page

### 1.12.1 / 2015-1-8
  * Updated the LEARN page for participants

### 1.12.0 - 2015-1-5
  * Merged in visualization branch changes

### 1.11.0
  * added data to click event
  * added report permissions to Ability

### 1.10.12
  * fixed display of viz Content Modules on module index page
  * fixed broken specs due to date formatting

### 1.10.11
  * update ability.rb

### 1.10.10 - 2014-12-30
  * bug fixes
    * updated version because tag 1.10.9 was referencing an incorrect commit (i.e., 584be81ec6af915645e0a2ba1250f0ed13979c53)

### 1.10.9 - 2014-12-29
  * enhancements
    * merged in enhanced visualization branch that improves table display

### 1.10.8
  * moved Replay intro link
  * fixed Lesson sorting
  * memoization for nav performance
  * Lesson release week display

### 1.10.7
  * mailers now using the from email address and host specified in the environment config files

### 1.10.6
  * added method to LessonModule

### 1.10.5
  * migrated Lesson notificaiton code out

### 1.10.4
  * changed default value for participant contact preference to email

### 1.10.3
  * minor Module index refactor
  * removal of duplicate Harmful Thought form

### 1.10.2
  * fix bug that involves feed items breaking home screen for engagements

### 1.10.1
  * auto-logout is more accurate with timing

### 1.10.0

  * change Thoughts tool to only allow harmful

### 1.9.1 - 2014-12-19
  * bug fixes
    * correctly namespaced site_message controller and views within 'coach' and added specs

### 1.9.0
  * enhancements
    * all clincian functionality is now nested within groups

### 1.8.5
  * fix bug that prevented adding slides to lessons

### 1.8.4
  * refactor to complete migration of Report classes to dashboard engine

### 1.8.3
  * incorporate mobile style updates/fixes

### 1.8.2
  * fix hamburger menu tool scoping bug
  * fix nav menu and tool index scoping bugs

### 1.8.1
  * display 'read' and 'released' dates for archived lessons

### 1.8.0 - 2014-12-17
  * enhancements
    * Remove moderatoring funcationality from this engine
    * Updated ability file
    * Note: some routes and paths are still present until other engines are updated.

### 1.7.5
  * Added strong password js to user password update

### 1.7.4
  * Resolved a bug with regards to confirmation logic of public activites and thoughts

### 1.7.3
  * conditionally send SMS/email notifications to Participants about Messages

### 1.7.2
  * data table sorting for participants updated

### 1.7.1
  * fix namespace issue related to Message delivery

### 1.7.0
  * Added confirmation logic for public social networking activities and thoughts
  * Fixed logic for new lesson notifications

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
