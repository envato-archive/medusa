Feature: Write a file

  Scenario: Write to medusa_test.txt
    Given a target file
    When I write "MEDUSA" to the file
    Then "MEDUSA" should be written in the file

