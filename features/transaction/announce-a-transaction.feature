Feature: Announce a transaction
  As Alice,
  I want to announce a transaction
  So that I can alter the state of the blockchain

  Background:
    Given Alice has an account in MAIN_NET
    And the maximum transaction lifetime is 1 day
    And the native currency mosaic is "xem"

  Scenario: Alice announces a valid transaction
    Given Alice defined a valid transaction
    And she signed the transaction
    When Alice announces the transaction to a "MAIN_NET" node
    Then she should receive a confirmation message

  Scenario Outline: An account tries to announce a transaction with an invalid deadline
    Given Alice defined a transaction with a deadline of <deadline> hours
    And she signed the transaction
    When Alice announces the transaction to a "MAIN_NET" node
    Then she should receive the error "<error>"

    Examples:
      | deadline | error                        |
      | 25       | Failure_Core_Future_Deadline |
      | 999      | Failure_Core_Future_Deadline |
      | 0        | Failure_Core_Past_Deadline   |
      | -1       | Failure_Core_Past_Deadline   |

  Scenario: An account tries to announce a transaction with an expired deadline
    Given Alice defined 3 hours ago a transaction with a deadline of 2 hours
    And she signed the transaction
    When Alice announces the transaction to a "MAIN_NET" node
    Then she should receive the error "Failure_Core_Past_Deadline"

  Scenario: An unconfirmed transaction deadline expires
    Given Alice announces a valid transaction
    When the transaction deadline expires while the transaction has unconfirmed status
    Then she should receive a confirmation message

  Scenario: An account tries to announce a transaction with an invalid signature
    Given Alice defined a random transaction signature
    And she announces the transaction to a "MAIN_NET" node
    Then She should receive the error "Failure_Signature_Not_Verifiable"

  Scenario: An account tries to announce an already announced transaction
    Given Alice defined a valid transaction
    And she signed the transaction
    And she announced the transaction to a "MAIN_NET" node
    When Alice announces the transaction to a "MAIN_NET" node
    Then she should receive the error "Failure_Hash_Exists"

  Scenario: An account tries to announce a transaction with an invalid network
    Given Alice defined a transaction with network "TEST_NET"
    And she signed the transaction
    When Alice announces the transaction to a "MAIN_NET" node
    Then she should receive the error "Failure_Core_Wrong_Network"

  Scenario: The nemesis account tries to announce a transaction
    Given Alice is the nemesis account
    And Alice defined a valid transaction
    And Alice signed the transaction
    When Alice announces the transaction to a "MAIN_NET" node
    Then she should receive the error "Failure_Core_Nemesis_Account_Signed_After_Nemesis_Block"

  Scenario: A multisig contract tries to announce a transaction
    Given Alice is a multisig contract
    And Alice defined a valid transaction
    And Alice signed the transaction
    When Alice announces the transaction to a "MAIN_NET" node
    Then she should receive the error "Failure_Multisig_Operation_Not_Permitted_By_Account"

  # Status errors not treated:
  # - Failure_Core_Too_Many_Transactions

  #Fee Behaviour
  Scenario: An account announced a valid transaction
    Given Alice announced a valid transaction of 10 "xem" to a "MAIN_NET" node with a "fee_multiplier" of 2
    And sets a "max_fee" of 25 "xem"
    When the node process the transaction to include it in a block
    And "effective_fee" is less than or equal to the "max_fee"
    Then the node accepts the transaction // Note: transaction::size * block::fee_multiplier should be less or equal than max_fee
    And her "xem" balance is deducted in units

  Scenario: An account announced a valid transaction and sets a max fee less than than effective fee
    Given Alice announced a valid transaction of 10 "xem" to a "MAIN_NET" node with a "fee_multiplier" of 2
    And sets a "max_fee" of 2 "xem"
    And "effective_fee" is the product of transaction size and "fee_multiplier"
    When the "effective_fee" is greater than than the set "max_fee"
    Then the transaction status will remain unannounced
    And her "xem" balance stays intact

  Scenario: An expired deadline on unconfirmed transaction
    Given Alice announced a valid transaction of 10 "xem" to a "MAIN_NET" node with a "fee_multiplier" of 1
    And sets a "max_fee" of 25 "xem"
    And the deadline expired in its unconfirmed state
    When the node process the transaction to include it in a block
    And "effective_fee" is less than or equal to the "max_fee"
    Then the node accepts the transaction // Note: transaction::size * block::fee_multiplier should be less or equal than max_fee
    And her "xem" balance is deducted in units

  Scenario: An account announced a transaction with an expired deadline
    Given Alice announced 3 hours ago a transaction of 10 "xem" to a "MAIN_NET" node with a "fee_multiplier" of 1
    And with a deadline of 2 hours
    And sets a "max_fee" of 25 "xem"
    And "effective_fee" is the product of transaction size and "fee_multiplier"
    When the transaction status is Failed due to error "Failure_Core_Past_Deadline"
    Then the "effective_fee" will not be deducted from her "xem" balance

  Scenario: An account announced a transaction with an invalid signature
    Given Alice annouced a transaction of 10 "xem" to a "MAIN_NET" node with a "fee_multiplier" of 1
    And uses an invalid or random signature
    And sets a "max_fee" of 25 "xem"
    And "effective_fee" is the product of transaction size and "fee_multiplier"
    When the transaction status is Failed due to error "Failure_Signature_Not_Verifiable"
    Then the "effective_fee" will not be deducted from her "xem" balance
