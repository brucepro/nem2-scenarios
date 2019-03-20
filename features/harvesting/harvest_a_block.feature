Feature: Harvest a block
  As Alice
  I want to harvest a block
  So that I obtain the resulting fees.

  Background:
    Given the harvesting mosaic is "xem"
    And the minimum amount of "xem" necessary to be eligible to harvest is 10000

  Scenario: An account harvest a block
    Given Alice has 10000 xem in her account
    And is running a node
    When she harvests a block
    Then she should get the resulting fees

  Scenario: An remote account harvests a block
    Given Alice has 10000 xem in her account
    And Alice delegated her account importance to "Bob"
    And "Bob" is running a node
    When "Bob" harvests a block using "Alice" remote account
    Then she should get the resulting fees

  Scenario: An account tries to harvest a block without having enough harvesting mosaics
    Given Alice has 9999 xem in her account
    When she tries to harvest a block
    Then she should receive the error "Failure_Core_Block_Harvester_Ineligible"

  Scenario: Alice wants to see her resulting fees after harvesting a block
    Given Alice is running a node
    And Alice account has harvested a block
    When she checks the fees obtained
    Then Alice should be able to see the resulting fees

  Scenario: Alice wants to see her resulting fees after harvesting a block using a remote account
    Given Alice delegated her account importance to "Bob"
    And "Bob" is running the node
    And Alice has 10000 xem in her account
    When she checks the fees obtained
    Then Alice should be able to see the resulting fees
