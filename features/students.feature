Feature: Perform CRUD actions on students

As a professor,
So I can keep track of student information.
I want to be able to perform CRUD actions on students.

Background: database

Given the following users exist:
| email                         | confirmed_at               |
| team_cluck_admin@gmail.com    | 2023-01-19 12:12:07.544080 |

Given the following courses exist:
| course_name | teacher                       | section | semester         |
| CSCE 411    | team_cluck_admin@gmail.com    | 501     | Spring 2023      | 
| CSCE 411    | team_cluck_admin@gmail.com    | 501     | Fall 2022        | 
| CSCE 412    | team_cluck_admin@gmail.com    | 501     | Spring 2023      | 


Given the following students exist:
| firstname | lastname  | uin       | email                 | classification | major | teacher                    | last_practice_at              | curr_practice_interval |
| Zebulun   | Oliphant  | 734826482 | zeb@tamu.edu          | U2             | CPSC  | team_cluck_admin@gmail.com | 2023-01-25 17:11:11.111111    | 120                    |
| Batmo     | Biel      | 274027450 | speedwagon@tamu.edu   | U1             | ENGR  | team_cluck_admin@gmail.com | 2023-01-25 17:11:11.111111    | 60                     |
| Ima       | Hogg      | 926409274 | piglet@tamu.edu       | U1             | ENGR  | team_cluck_admin@gmail.com | 2023-01-25 19:11:11.111111    | 240                    |
| Joe       | Mama      | 720401677 | howisjoe@tamu.edu     | U1             | ENGR  | team_cluck_admin@gmail.com | 2023-01-25 19:11:11.111111    | 120                    |
| Sheev     | Palpatine | 983650274 | senate@tamu.edu       | U2             | CPSC  | team_cluck_admin@gmail.com | 2023-01-25 19:11:11.111111    | 119                    |

Scenario: All students viewable
    When I sign in as "team_cluck_admin@gmail.com"
    And I go to the students page
    And I should see "New student"

Scenario: Search by semester
    When I sign in as "team_cluck_admin@gmail.com"
    Given I am on the upload page
    When I upload a zip file
    And I input form information
    When I click save
    Then I should see the upload was successful
    And I go to the students page
    And I select "Spring 2023" under semester
    Then I submit the form
    Then I should see "Kunal"

Scenario: Search by tag
    When I sign in as "team_cluck_admin@gmail.com"
    Given I am on the upload page
    When I upload a zip file
    And I input form information
    When I click save
    Then I should see the upload was successful
    And I go to the students page
    And I select "Spring 2023" under semester
    Then I submit the form
    Then I should see "Kunal"
    When I click show this student
    And I click "Edit this student"
    When I fill in student "create_tag" with "test"
    And I click "Update Student"
    Then I should see "test"
    When I go to the students page
    And I select "test" under tag
    Then I submit the form
    Then I should see "Kunal"


Scenario: Add and Delete a student
    When I sign in as "team_cluck_admin@gmail.com"
    And I go to the students page
    When I click "New student"
    When I fill in student "firstname" with "New"
    When I fill in student "lastname" with "Student"
    When I fill in student "email" with "newstudent@email.com"
    And I click "Create Student"
    Then I should see "Student was successfully created"
    And I should see "New Student's Profile"
    And I click "Delete this student"
    Then I should see "New student"

Scenario: Update Student Course
    When I sign in as "team_cluck_admin@gmail.com"
    Given I am on the upload page
    When I upload a zip file
    And I input form information
    When I click save
    And I go to the students page
    And I select "Spring 2023" under semester
    Then I submit the form
    And I click the first "Show this student"
    And I click "Edit this student"
    Then I should see "Edit Student Course History"
    And I fill in the first student course "final_grade" with "A"
    And I click the first "Update Grade"
    Then I should see "Student information was successfully updated."

Scenario: Delete Student Course
    When I sign in as "team_cluck_admin@gmail.com"
    Given I am on the upload page
    When I upload a zip file
    And I input form information
    When I click save
    Then I should see the upload was successful
    And I go to the students page
    And I select "Spring 2023" under semester
    Then I submit the form
    Then I should see "Kunal"
    And I click the first "Show this student"
    And I click "Edit this student"
    Then I should see "Edit Student Course History"
    And I click the first "Delete this course of student"
    Then I should see "Given student in a course is deleted."

Scenario: Add an invalid student
    When I sign in as "team_cluck_admin@gmail.com"
    And I go to the students page
    When I click "New student"
    And I click "Create Student"
    Then I should see "Student was successfully created"

Scenario: Display Students List
    When I sign in as "team_cluck_admin@gmail.com"
    And I go to the students page
    When I click "New student"
    When I fill in student "firstname" with "Test"
    When I fill in student "lastname" with "Student"
    When I fill in student "email" with "teststudent@email.com"
    And I click "Create Student"
    And I click "Back to students"
    Then I should see "Test"
    And I should see "teststudent@email.com"

Scenario: Delete a student
    When I sign in as "team_cluck_admin@gmail.com"
    And I go to the students page
    When I click "New student"
    When I fill in student "firstname" with "New"
    When I fill in student "lastname" with "Student"
    When I fill in student "email" with "newstudent@email.com"
    And I click "Create Student"
    Then I should see "Student was successfully created"
    And I go to the students page
    And I click the delete button for student "New"
    Then I should see "New student"