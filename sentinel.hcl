import "tfrun"
import "decimal"

# Safely access the real decimal string attributes
proposed_string = tfrun.cost_estimate.proposed_monthly else "99999.0"
delta_string    = tfrun.cost_estimate.delta_monthly else "99999.0"

proposed_under_limit = rule {
    decimal.new(proposed_string).less_than(2000)
}

delta_under_limit = rule {
    decimal.new(delta_string).less_than(2000)
}

# resources estimate over the budget
main = rule {
    proposed_under_limit and delta_under_limit
}
