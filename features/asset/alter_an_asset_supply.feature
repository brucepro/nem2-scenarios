Feature: Alter an asset supply
  As Alice
  I want to alter an asset supply
  So that it represents the available amount of an item in my shop.

  Background:
    Given the mean block generation time is 15 seconds
    And the maximum asset supply is 9000000000
    And Alice has 10000000 xem in her account

  Scenario Outline: An account alters an asset supply
    Given Alice has registered a <property> asset with an initial supply of 20 units
    And she still owns 20 units
    When Alice decides to "<direction>" the asset supply in <amount> units
    Then she should receive a confirmation message
    And the balance of the asset in her account should "<direction>" in <amount> units

    Examples:
      | property         | direction | amount |
      | supply-mutable   | increase  |  5     |
      | supply-immutable | increase  |  5     |
      | supply-mutable   | decrease  |  20    |
      | supply-immutable | decrease  |  20    |

  Scenario Outline: An account tries to alter an asset supply surpassing the maximum or minimum asset supply limit
    Given Alice has registered a <property> asset with an initial supply of 20 units
    And she still owns 20 units
    When Alice decides to "<direction>" the asset supply in <amount> units
    Then she should receive the error "<error>"

    Examples:
      | property         | direction | amount      | error                          |
      | supply-mutable   | increase  | 9000000000  | Failure_Mosaic_Supply_Exceeded |
      | supply-immutable | increase  | 9000000000  | Failure_Mosaic_Supply_Exceeded |
      | supply-mutable   | decrease  | 21          | Failure_Mosaic_Supply_Negative |
      | supply-immutable | decrease  | 21         | Failure_Mosaic_Supply_Negative |

  Scenario Outline: An account tries to alter an asset supply without doing any changes
    Given Alice has registered a <property> asset with an initial supply of 20 units
    And she still owns 20 units
    When Alice decides to "<direction>" the asset supply in 0 units
    Then she should receive the error "Failure_Mosaic_Invalid_Supply_Change_Amount"

    Examples:
      | property         | direction |
      | supply-mutable   | increase  |
      | supply-immutable | increase  |
      | supply-mutable   | decrease  |
      | supply-immutable | decrease  |

  Scenario Outline: An account tries to alter the supply of a supply immutable asset, but does not own all the units
    Given Alice has registered a "supply-immutable" asset with an initial supply of 20 units
    And she still owns 10 units
    When Alice decides to "<direction>" the asset supply in 2 units
    Then she should receive the error "Failure_Mosaic_Supply_Immutable"

    Examples:
      | direction |
      | increase  |
      | decrease  |

  # Todo: Failure_Mosaic_Invalid_Supply_Change_Direction