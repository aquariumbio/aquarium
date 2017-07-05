module Krill

  # Loads code from another operation. Intended for re-usable protocol code.
  def self.load_code(op_name_or_id)
    ot = nil
    if op_name_or_id.is_a? Integer
      ot = OperationType.find_by_id(op_name_or_id)
    elsif op_name_or_id.is_a? String
      ot = OperationType.find_by_name(op_name_or_id)
    else
      raise TypeError, "Could not load header #{op_name_or_id}. Validate header identifier is an Integer or String."
    end

    if ot.nil?
      raise TypeError, "Could not find header #{op_name_or_id}. Validate that header identifier is correct."
    end
    code = ot.protocol.content
    eval(code)
  end


end