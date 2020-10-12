# typed: false
# frozen_string_literal: true

# Module that includes status-related methods for {Operation}

module OperationStatus

  # Set and save {Operation} status
  #
  # @param str [String] ("waiting", "pending", "primed", "deferred", "scheduled", "running", "done", "error")
  # @return [String] The {Operation} status
  def change_status(str)
    self.status = str
    save
    raise 'Could not change status' unless errors.empty?

    str
  end

  def start
    raise "Cannot start operation #{id} from state #{status}" unless planning?

    if on_the_fly
      change_status 'primed'
    elsif leaf? # note that this op is considered a leaf if it has no preds,
      # or if its preds are all on_the_fly leaves
      if precondition_value
        change_status 'pending'
      else
        change_status 'delayed'
      end
    else
      change_status 'waiting'
    end
  end

  def retry
    raise "Cannot restart operation #{id} because it is not in an error state" unless error? || done?

    change_status 'waiting'
    step
  end

  def deferred?
    status == 'deferred'
  end

  def delayed?
    status == 'delayed'
  end

  def done?
    status == 'done'
  end

  def error?
    status == 'error'
  end

  def pending?
    status == 'pending'
  end

  def planning?
    status == 'planning'
  end

  def primed?
    status == 'primed'
  end

  def running?
    status == 'running'
  end

  def scheduled?
    status == 'scheduled'
  end

  def unplanned?
    status == 'unplanned'
  end

  def waiting?
    status == 'waiting'
  end

  def schedule
    return if scheduled?
    raise "Cannot schedule operation #{id} from state #{status}" unless pending? || deferred? || primed?

    change_status 'scheduled'
  end

  def run
    return if running?
    raise "Cannot run operation #{id} from state #{status}" unless scheduled?

    change_status 'running'
  end

  def defer
    return if deferred?
    raise "Cannot defer operation #{id} from state #{status}" unless pending?

    change_status 'deferred'
  end

  def unbatch; end

  def step # not to be confused with def self.step in Operation.rb

    print "op #{id}: #{status}"
    if !scheduled? &&
       !running? &&
       !done? &&
       !error? &&
       ready? # in planner/operation_planner.rb

      get_items_from_predecessor

      if on_the_fly
        change_status 'primed'
      elsif deferred?
        change_status 'scheduled'
      elsif precondition_value
        change_status 'pending'
      else
        change_status 'delayed'
      end
    end
    puts " ==> #{status}"
  rescue Exception => e
    Rails.logger.info "COULD NOT STEP OPERATION #{id}: #{e}"

    # TODO: Change deferred op to scheduled
  end

  def finish
    change_status 'done' if running?
  end

  # Set the {Operation} to "error", and create a {DataAssociation} to
  # describe why the operation errored
  #
  # @param error_type [Symbol] Name of error
  # @param msg [String] Error message
  # @example Error {Operation}s with no plate colonies
  #   op.error :no_colonies, "There are no colonies for plate #{plate}"
  # @see DataAssociator#associate
  def error(error_type, msg)
    change_status 'error'
    associate error_type, msg
  end

  # Set {Operation} status to "pending" if its precondition evaluates to true;
  # sets status to "delayed" otherwise. This is particularly useful for
  # operations that are not yet ready to be run or need to be run periodically.
  #
  # @see #change_status
  def redo
    if precondition_value
      change_status 'pending'
    else
      change_status 'delayed'
    end
    # TODO: Change preds to pending? At least on_the_fly_preds/
  end

  def get_items_from_predecessor
    inputs.each do |i|

      Wire.where(to_id: i.id).each do |wire|
        if i.child_item_id && (
            i.child_item_id != wire.from.child_item_id ||
            i.row != wire.from.row ||
            i.column != wire.from.column)
          associate(
            :input_item_replaced,
            "Input #{i.name} was #{i.child_item_id} but was replaced by #{wire.from.child_item_id} " \
            '(likely when its predecessor recomputed an output)',
            nil,
            duplicates: true
          )
        end
        i.child_item_id = wire.from.child_item_id
        i.row = wire.from.row
        i.column = wire.from.column
        i.save
      end
    end
  end

end
